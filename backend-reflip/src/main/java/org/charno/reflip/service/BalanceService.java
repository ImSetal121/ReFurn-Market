package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.reflip.entity.RfBalanceDetail;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 面向用户的余额业务接口
 * 通过SecurityUtils获取当前请求用户，提供余额相关服务
 */
public interface BalanceService {

    /**
     * 获取当前请求用户的余额
     * 
     * @return 当前用户余额，如果用户未登录或无余额记录返回0
     */
    BigDecimal getCurrentUserBalance();

    /**
     * 分页查询当前请求用户的余额明细
     * 
     * @param page            分页对象
     * @param transactionType 交易类型筛选（可选）
     * @param startTime       开始时间筛选（可选）
     * @param endTime         结束时间筛选（可选）
     * @return 分页的余额明细记录
     */
    Page<RfBalanceDetail> getCurrentUserBalanceDetailsPage(
            Page<RfBalanceDetail> page,
            String transactionType,
            LocalDateTime startTime,
            LocalDateTime endTime);

    /**
     * 获取当前请求用户指定交易类型的总金额
     * 
     * @param transactionType 交易类型
     * @return 该类型的总金额
     */
    BigDecimal getCurrentUserAmountByType(String transactionType);

    /**
     * 获取当前请求用户的最新一条余额明细记录
     * 
     * @return 最新的余额明细记录，如果没有记录返回null
     */
    RfBalanceDetail getCurrentUserLatestBalanceDetail();

    /**
     * 检查当前用户是否已登录
     * 
     * @return true-已登录，false-未登录
     */
    boolean isUserLoggedIn();

    /**
     * 获取当前登录用户ID
     * 
     * @return 用户ID，未登录时返回null
     */
    Long getCurrentUserId();

    /**
     * 为指定用户创建余额明细记录（按照双链表特性）
     * 此方法会自动维护双链表结构，计算余额变化
     * 
     * @param userId          用户ID
     * @param transactionType 交易类型
     * @param amount          交易金额（正数表示增加，负数表示减少）
     * @param description     交易描述
     * @return 创建是否成功
     */
    boolean createBalanceDetailForUser(Long userId, String transactionType, BigDecimal amount, String description);

    /**
     * 提现到Stripe账户
     * 从用户余额中扣除指定金额并转账到用户绑定的Stripe账户
     * 
     * @param amount 提现金额
     * @return 提现是否成功
     */
    boolean withdrawToStripe(BigDecimal amount);

    /**
     * 检查当前用户是否可以提现指定金额
     * 验证余额是否充足、Stripe账户是否可用等
     * 
     * @param amount 提现金额
     * @return 检查结果和错误信息
     */
    WithdrawCheckResult checkWithdrawEligibility(BigDecimal amount);

    /**
     * 处理充值成功
     * 在用户通过Stripe支付成功后，增加用户余额
     * 
     * @param amount          充值金额
     * @param paymentIntentId Stripe支付意图ID
     * @return 处理是否成功
     */
    boolean handleRechargeSuccess(BigDecimal amount, String paymentIntentId);

    /**
     * 使用余额购买商品
     * 从用户余额中扣除商品金额并创建订单
     * 
     * @param productId   商品ID
     * @param amount      商品金额
     * @param productName 商品名称
     * @return 购买结果
     */
    PurchaseResult purchaseWithBalance(Integer productId, BigDecimal amount, String productName);

    /**
     * 使用余额购买寄卖商品
     * 从用户余额中扣除商品金额并创建订单，包含收货地址信息
     * 
     * @param productId       商品ID
     * @param amount          商品金额
     * @param productName     商品名称
     * @param deliveryAddress 收货地址
     * @param deliveryPhone   收货电话
     * @param deliveryName    收货人姓名
     * @return 购买结果
     */
    PurchaseResult purchaseWithBalanceForConsignment(Integer productId, BigDecimal amount, String productName,
            String deliveryAddress, String deliveryPhone, String deliveryName);

    /**
     * 检查余额购买条件
     * 验证余额是否充足等条件
     * 
     * @param amount 购买金额
     * @return 检查结果
     */
    PurchaseCheckResult checkBalancePurchaseEligibility(BigDecimal amount);

    /**
     * 提现检查结果
     */
    class WithdrawCheckResult {
        private boolean eligible;
        private String errorMessage;

        public WithdrawCheckResult(boolean eligible, String errorMessage) {
            this.eligible = eligible;
            this.errorMessage = errorMessage;
        }

        public boolean isEligible() {
            return eligible;
        }

        public String getErrorMessage() {
            return errorMessage;
        }

        public static WithdrawCheckResult success() {
            return new WithdrawCheckResult(true, null);
        }

        public static WithdrawCheckResult fail(String message) {
            return new WithdrawCheckResult(false, message);
        }
    }

    /**
     * 购买结果
     */
    class PurchaseResult {
        private boolean success;
        private String message;
        private String orderId;

        public PurchaseResult(boolean success, String message, String orderId) {
            this.success = success;
            this.message = message;
            this.orderId = orderId;
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }

        public String getOrderId() {
            return orderId;
        }

        public static PurchaseResult success(String orderId, String message) {
            return new PurchaseResult(true, message, orderId);
        }

        public static PurchaseResult fail(String message) {
            return new PurchaseResult(false, message, null);
        }
    }

    /**
     * 购买条件检查结果
     */
    class PurchaseCheckResult {
        private boolean eligible;
        private String errorMessage;
        private BigDecimal currentBalance;

        public PurchaseCheckResult(boolean eligible, String errorMessage, BigDecimal currentBalance) {
            this.eligible = eligible;
            this.errorMessage = errorMessage;
            this.currentBalance = currentBalance;
        }

        public boolean isEligible() {
            return eligible;
        }

        public String getErrorMessage() {
            return errorMessage;
        }

        public BigDecimal getCurrentBalance() {
            return currentBalance;
        }

        public static PurchaseCheckResult success(BigDecimal currentBalance) {
            return new PurchaseCheckResult(true, null, currentBalance);
        }

        public static PurchaseCheckResult fail(String message, BigDecimal currentBalance) {
            return new PurchaseCheckResult(false, message, currentBalance);
        }
    }
}