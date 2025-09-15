package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.charno.common.utils.SecurityUtils;
import org.charno.common.entity.SysUserStripeAccount;
import org.charno.reflip.entity.RfBalanceDetail;
import org.charno.reflip.service.BalanceService;
import org.charno.reflip.service.IRfBalanceDetailService;
import org.charno.reflip.service.IStripeService;
import org.charno.reflip.service.IBuyerService;
import org.charno.system.mapper.SysUserStripeAccountMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 面向用户的余额业务实现类
 */
@Service
public class BalanceServiceImpl implements BalanceService {

    private static final Logger log = LoggerFactory.getLogger(BalanceServiceImpl.class);

    @Autowired
    private IRfBalanceDetailService rfBalanceDetailService;

    @Autowired
    private SysUserStripeAccountMapper stripeAccountMapper;

    @Autowired
    private IStripeService stripeService;

    @Autowired
    @Lazy
    private IBuyerService buyerService;

    @Autowired
    private org.charno.reflip.service.IRfProductService rfProductService;

    @Override
    public BigDecimal getCurrentUserBalance() {
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal balance = rfBalanceDetailService.getCurrentBalance(userId);
        return balance != null ? balance : BigDecimal.ZERO;
    }

    @Override
    public Page<RfBalanceDetail> getCurrentUserBalanceDetailsPage(
            Page<RfBalanceDetail> page,
            String transactionType,
            LocalDateTime startTime,
            LocalDateTime endTime) {

        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return new Page<>(page.getCurrent(), page.getSize());
        }

        // 构建查询条件
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBalanceDetail::getUserId, userId);

        if (transactionType != null && !transactionType.trim().isEmpty()) {
            queryWrapper.eq(RfBalanceDetail::getTransactionType, transactionType);
        }

        if (startTime != null) {
            queryWrapper.ge(RfBalanceDetail::getTransactionTime, startTime);
        }

        if (endTime != null) {
            queryWrapper.le(RfBalanceDetail::getTransactionTime, endTime);
        }

        queryWrapper.orderByDesc(RfBalanceDetail::getTransactionTime);

        return rfBalanceDetailService.page(page, queryWrapper);
    }

    @Override
    public BigDecimal getCurrentUserAmountByType(String transactionType) {
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal amount = rfBalanceDetailService.sumAmountByUserIdAndType(userId, transactionType);
        return amount != null ? amount : BigDecimal.ZERO;
    }

    @Override
    public RfBalanceDetail getCurrentUserLatestBalanceDetail() {
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return null;
        }

        return rfBalanceDetailService.getLatestByUserId(userId);
    }

    @Override
    public boolean isUserLoggedIn() {
        return SecurityUtils.getUserId() != null;
    }

    @Override
    public Long getCurrentUserId() {
        return SecurityUtils.getUserId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean createBalanceDetailForUser(Long userId, String transactionType, BigDecimal amount,
            String description) {
        try {
            if (userId == null) {
                log.error("用户ID不能为空");
                throw new RuntimeException("用户ID不能为空");
            }

            if (amount == null || amount.compareTo(BigDecimal.ZERO) == 0) {
                log.error("交易金额不能为空或为0");
                throw new RuntimeException("交易金额不能为空或为0");
            }

            // 获取用户当前余额
            BigDecimal currentBalance = rfBalanceDetailService.getCurrentBalance(userId);
            BigDecimal balanceAfter = currentBalance.add(amount);

            // 检查余额不能为负数（除非是特殊的调整类型）
            if (balanceAfter.compareTo(BigDecimal.ZERO) < 0 &&
                    !"ADJUSTMENT".equals(transactionType)) {
                log.error("余额不足，无法完成交易: userId={}, currentBalance={}, amount={}, balanceAfter={}",
                        userId, currentBalance, amount, balanceAfter);
                throw new RuntimeException("余额不足，无法完成交易");
            }

            // 创建新的余额明细记录
            RfBalanceDetail newDetail = new RfBalanceDetail();
            newDetail.setUserId(userId);
            newDetail.setTransactionType(transactionType);
            newDetail.setAmount(amount);
            newDetail.setBalanceBefore(currentBalance);
            newDetail.setBalanceAfter(balanceAfter);
            newDetail.setDescription(description);
            newDetail.setTransactionTime(LocalDateTime.now());
            newDetail.setCreateTime(LocalDateTime.now());
            newDetail.setUpdateTime(LocalDateTime.now());
            newDetail.setIsDelete(false);

            // 调用底层服务创建记录（底层服务会自动维护双链表结构）
            boolean success = rfBalanceDetailService.createBalanceDetail(newDetail);

            if (success) {
                log.info("创建用户余额明细成功: userId={}, transactionType={}, amount={}, balanceAfter={}",
                        userId, transactionType, amount, balanceAfter);
            } else {
                log.error("创建用户余额明细失败: userId={}, transactionType={}, amount={}",
                        userId, transactionType, amount);
            }

            return success;

        } catch (Exception e) {
            log.error("创建用户余额明细时出错: userId={}, transactionType={}, amount={}",
                    userId, transactionType, amount, e);
            throw e; // 确保事务回滚
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean withdrawToStripe(BigDecimal amount) {
        try {
            // 获取当前用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                log.error("用户未登录，无法进行提现");
                throw new RuntimeException("用户未登录，无法进行提现");
            }

            // 检查提现条件
            WithdrawCheckResult checkResult = checkWithdrawEligibility(amount);
            if (!checkResult.isEligible()) {
                log.error("提现条件检查失败: userId={}, amount={}, error={}",
                        userId, amount, checkResult.getErrorMessage());
                throw new RuntimeException(checkResult.getErrorMessage());
            }

            // 查询用户的Stripe账户
            LambdaQueryWrapper<SysUserStripeAccount> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(SysUserStripeAccount::getUserId, userId);
            SysUserStripeAccount stripeAccount = stripeAccountMapper.selectOne(queryWrapper);

            // 先创建提现记录（扣除余额）
            boolean balanceSuccess = createBalanceDetailForUser(
                    userId,
                    "WITHDRAWAL", // 交易类型：提现
                    amount.negate(), // 负数表示扣除
                    "提现到Stripe账户");

            if (!balanceSuccess) {
                log.error("创建提现余额明细失败: userId={}, amount={}", userId, amount);
                throw new RuntimeException("创建提现记录失败");
            }

            // 调用Stripe服务转账
            String withdrawalId = "WITHDRAW_" + System.currentTimeMillis() + "_" + userId;
            boolean transferSuccess = stripeService.transferToSeller(
                    withdrawalId,
                    stripeAccount.getStripeAccountId(),
                    amount);

            if (!transferSuccess) {
                log.error("Stripe转账失败: userId={}, amount={}", userId, amount);
                throw new RuntimeException("转账失败，请稍后再试或联系客服");
            }

            log.info("用户提现成功: userId={}, amount={}, stripeAccountId={}",
                    userId, amount, stripeAccount.getStripeAccountId());
            return true;

        } catch (Exception e) {
            log.error("提现处理出错", e);
            throw e; // 确保事务回滚
        }
    }

    @Override
    public WithdrawCheckResult checkWithdrawEligibility(BigDecimal amount) {
        try {
            // 获取当前用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return WithdrawCheckResult.fail("用户未登录");
            }

            // 检查提现金额
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                return WithdrawCheckResult.fail("提现金额必须大于0");
            }

            // 检查余额是否充足
            BigDecimal currentBalance = getCurrentUserBalance();
            if (currentBalance.compareTo(amount) < 0) {
                return WithdrawCheckResult.fail("余额不足，当前余额: $" + currentBalance + "，提现金额: $" + amount);
            }

            // 查询用户的Stripe账户
            LambdaQueryWrapper<SysUserStripeAccount> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(SysUserStripeAccount::getUserId, userId);
            SysUserStripeAccount stripeAccount = stripeAccountMapper.selectOne(queryWrapper);

            if (stripeAccount == null) {
                return WithdrawCheckResult.fail("未绑定Stripe账户，请先完成账户设置");
            }

            // 验证Stripe账户状态
            if (!"active".equals(stripeAccount.getAccountStatus()) ||
                    !Boolean.TRUE.equals(stripeAccount.getCanReceivePayments())) {
                return WithdrawCheckResult.fail("Stripe账户状态异常，无法接收付款。账户状态: " +
                        stripeAccount.getAccountStatus() +
                        "，可接收付款: " + stripeAccount.getCanReceivePayments());
            }

            return WithdrawCheckResult.success();

        } catch (Exception e) {
            log.error("检查提现条件时出错", e);
            return WithdrawCheckResult.fail("检查提现条件时出错: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean handleRechargeSuccess(BigDecimal amount, String paymentIntentId) {
        try {
            // 获取当前用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                log.error("用户未登录，无法处理充值");
                throw new RuntimeException("用户未登录，无法处理充值");
            }

            // 验证充值金额
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                log.error("充值金额无效: userId={}, amount={}", userId, amount);
                throw new RuntimeException("充值金额无效");
            }

            // 验证支付意图ID
            if (paymentIntentId == null || paymentIntentId.trim().isEmpty()) {
                log.error("支付意图ID无效: userId={}, paymentIntentId={}", userId, paymentIntentId);
                throw new RuntimeException("支付意图ID无效");
            }

            // 创建充值记录
            String description = String.format("钱包充值 - 支付ID: %s", paymentIntentId);
            boolean success = createBalanceDetailForUser(
                    userId,
                    "DEPOSIT", // 交易类型：充值
                    amount, // 正数表示增加余额
                    description);

            if (success) {
                log.info("用户充值成功: userId={}, amount={}, paymentIntentId={}",
                        userId, amount, paymentIntentId);
                return true;
            } else {
                log.error("创建充值余额明细失败: userId={}, amount={}, paymentIntentId={}",
                        userId, amount, paymentIntentId);
                throw new RuntimeException("创建充值记录失败");
            }

        } catch (Exception e) {
            log.error("处理充值成功时出错: amount={}, paymentIntentId={}",
                    amount, paymentIntentId, e);
            throw e; // 确保事务回滚
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PurchaseResult purchaseWithBalance(Integer productId, BigDecimal amount, String productName) {
        try {
            // 获取当前用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                log.error("用户未登录，无法进行购买");
                return PurchaseResult.fail("User not logged in");
            }

            // 检查购买条件
            PurchaseCheckResult checkResult = checkBalancePurchaseEligibility(amount);
            if (!checkResult.isEligible()) {
                log.error("余额购买条件检查失败: userId={}, amount={}, error={}",
                        userId, amount, checkResult.getErrorMessage());
                return PurchaseResult.fail(checkResult.getErrorMessage());
            }

            // 查询商品信息判断是否为寄卖商品
            org.charno.reflip.entity.RfProduct product = rfProductService.getById(productId.longValue());
            if (product == null) {
                log.error("商品不存在: productId={}", productId);
                return PurchaseResult.fail("Product not found");
            }

            // 检查是否为寄卖商品
            boolean isConsignment = Boolean.TRUE.equals(product.getIsAuction());
            if (isConsignment) {
                log.error("寄卖商品需要使用专门的购买接口: productId={}", productId);
                return PurchaseResult.fail(
                        "Consignment products require delivery address information. Please use the consignment purchase interface.");
            }

            // 生成订单ID
            String orderId = "BAL_" + System.currentTimeMillis() + "_" + userId;

            // 创建购买记录（扣除余额）
            String description = String.format("购买商品: %s (订单: %s)", productName, orderId);
            boolean balanceSuccess = createBalanceDetailForUser(
                    userId,
                    "PURCHASE", // 交易类型：购买
                    amount.negate(), // 负数表示扣除
                    description);

            if (!balanceSuccess) {
                log.error("创建购买余额明细失败: userId={}, amount={}, productId={}",
                        userId, amount, productId);
                return PurchaseResult.fail("Failed to create purchase record");
            }

            log.info("用户余额购买成功: userId={}, amount={}, productId={}, orderId={}",
                    userId, amount, productId, orderId);

            // 调用普通商品购买处理逻辑（使用orderId作为paymentIntentId）
            boolean purchaseSuccess = buyerService.handlePurchaseSuccess(productId.longValue(), orderId);

            if (purchaseSuccess) {
                return PurchaseResult.success(orderId, "Purchase completed successfully");
            } else {
                log.error("商品购买处理失败: userId={}, amount={}, productId={}",
                        userId, amount, productId);
                return PurchaseResult.fail("Purchase processing failed");
            }

        } catch (Exception e) {
            log.error("余额购买处理出错: productId={}, amount={}, productName={}",
                    productId, amount, productName, e);
            return PurchaseResult.fail("Purchase processing failed: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PurchaseResult purchaseWithBalanceForConsignment(Integer productId, BigDecimal amount, String productName,
            String deliveryAddress, String deliveryPhone, String deliveryName) {
        try {
            // 获取当前用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                log.error("用户未登录，无法进行购买");
                return PurchaseResult.fail("User not logged in");
            }

            // 检查购买条件
            PurchaseCheckResult checkResult = checkBalancePurchaseEligibility(amount);
            if (!checkResult.isEligible()) {
                log.error("余额购买条件检查失败: userId={}, amount={}, error={}",
                        userId, amount, checkResult.getErrorMessage());
                return PurchaseResult.fail(checkResult.getErrorMessage());
            }

            // 验证寄卖商品必要参数
            if (deliveryAddress == null || deliveryAddress.trim().isEmpty() ||
                    deliveryPhone == null || deliveryPhone.trim().isEmpty() ||
                    deliveryName == null || deliveryName.trim().isEmpty()) {
                log.error("寄卖商品购买缺少必要的收货信息: productId={}", productId);
                return PurchaseResult.fail("Delivery address, phone and name are required for consignment products");
            }

            // 查询商品信息验证是否为寄卖商品
            org.charno.reflip.entity.RfProduct product = rfProductService.getById(productId.longValue());
            if (product == null) {
                log.error("商品不存在: productId={}", productId);
                return PurchaseResult.fail("Product not found");
            }

            // 验证确实是寄卖商品
            boolean isConsignment = Boolean.TRUE.equals(product.getIsAuction());
            if (!isConsignment) {
                log.error("普通商品不应使用寄卖购买接口: productId={}", productId);
                return PurchaseResult.fail("This product is not a consignment item");
            }

            // 生成订单ID
            String orderId = "BAL_" + System.currentTimeMillis() + "_" + userId;

            // 创建购买记录（扣除余额）
            String description = String.format("购买寄卖商品: %s (订单: %s)", productName, orderId);
            boolean balanceSuccess = createBalanceDetailForUser(
                    userId,
                    "PURCHASE", // 交易类型：购买
                    amount.negate(), // 负数表示扣除
                    description);

            if (!balanceSuccess) {
                log.error("创建购买余额明细失败: userId={}, amount={}, productId={}",
                        userId, amount, productId);
                return PurchaseResult.fail("Failed to create purchase record");
            }

            log.info("用户余额购买寄卖商品成功: userId={}, amount={}, productId={}, orderId={}",
                    userId, amount, productId, orderId);

            // 调用寄卖商品购买处理逻辑（使用orderId作为paymentIntentId）
            boolean purchaseSuccess = buyerService.handleConsignmentPurchaseSuccess(
                    productId.longValue(), orderId, deliveryAddress, deliveryPhone, deliveryName);

            if (purchaseSuccess) {
                return PurchaseResult.success(orderId, "Consignment purchase completed successfully");
            } else {
                log.error("寄卖商品购买处理失败: userId={}, amount={}, productId={}",
                        userId, amount, productId);
                return PurchaseResult.fail("Consignment purchase processing failed");
            }

        } catch (Exception e) {
            log.error("寄卖商品余额购买处理出错: productId={}, amount={}, productName={}",
                    productId, amount, productName, e);
            return PurchaseResult.fail("Consignment purchase processing failed: " + e.getMessage());
        }
    }

    @Override
    public PurchaseCheckResult checkBalancePurchaseEligibility(BigDecimal amount) {
        try {
            // 获取当前用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return PurchaseCheckResult.fail("User not logged in", BigDecimal.ZERO);
            }

            // 检查购买金额
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                return PurchaseCheckResult.fail("Purchase amount must be greater than 0", BigDecimal.ZERO);
            }

            // 获取当前余额
            BigDecimal currentBalance = getCurrentUserBalance();

            // 检查余额是否充足
            if (currentBalance.compareTo(amount) < 0) {
                return PurchaseCheckResult.fail(
                        String.format("Insufficient balance. Current: $%.2f, Required: $%.2f",
                                currentBalance.doubleValue(), amount.doubleValue()),
                        currentBalance);
            }

            return PurchaseCheckResult.success(currentBalance);

        } catch (Exception e) {
            log.error("检查余额购买条件时出错", e);
            return PurchaseCheckResult.fail("Failed to check purchase eligibility: " + e.getMessage(), BigDecimal.ZERO);
        }
    }
}