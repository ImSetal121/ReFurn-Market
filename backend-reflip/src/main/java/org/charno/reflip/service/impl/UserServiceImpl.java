package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.charno.reflip.entity.RfBillItem;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.entity.RfUserFavoriteProduct;
import org.charno.reflip.entity.RfUserProductBrowseHistory;
import org.charno.reflip.service.IRfBillItemService;
import org.charno.reflip.service.IRfProductService;
import org.charno.reflip.service.IUserService;
import org.charno.reflip.service.BalanceService;
import org.charno.reflip.service.IRfUserFavoriteProductService;
import org.charno.reflip.service.IRfUserProductBrowseHistoryService;
import org.charno.common.utils.SecurityUtils;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 用户业务实现类
 */
@Service
public class UserServiceImpl implements IUserService {

    @Autowired
    private IRfBillItemService rfBillItemService;

    @Autowired
    private BalanceService balanceService;

    @Autowired
    private IRfUserFavoriteProductService rfUserFavoriteProductService;

    @Autowired
    private IRfProductService rfProductService;

    @Autowired
    private IRfUserProductBrowseHistoryService rfUserProductBrowseHistoryService;

    @Override
    public Page<RfBillItem> getUserBills(String status, Integer page, Integer size) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        // 创建分页对象
        Page<RfBillItem> pageInfo = new Page<>(page, size);

        // 构建查询条件
        LambdaQueryWrapper<RfBillItem> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBillItem::getPayUserId, userId);

        // 如果指定了状态，添加状态过滤
        if (status != null && !status.isEmpty()) {
            queryWrapper.eq(RfBillItem::getStatus, status);
        }

        // 按创建时间倒序排列
        queryWrapper.orderByDesc(RfBillItem::getCreateTime);

        // 执行分页查询
        return rfBillItemService.page(pageInfo, queryWrapper);
    }

    @Override
    public Map<String, Object> getBillsSummary() {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        // 查询所有账单
        LambdaQueryWrapper<RfBillItem> allWrapper = new LambdaQueryWrapper<>();
        allWrapper.eq(RfBillItem::getPayUserId, userId);
        long totalBills = rfBillItemService.count(allWrapper);

        // 查询待付款账单
        LambdaQueryWrapper<RfBillItem> pendingWrapper = new LambdaQueryWrapper<>();
        pendingWrapper.eq(RfBillItem::getPayUserId, userId)
                .eq(RfBillItem::getStatus, "PENDING");
        long pendingBills = rfBillItemService.count(pendingWrapper);

        // 查询已付款账单
        LambdaQueryWrapper<RfBillItem> paidWrapper = new LambdaQueryWrapper<>();
        paidWrapper.eq(RfBillItem::getPayUserId, userId)
                .eq(RfBillItem::getStatus, "PAID");
        long paidBills = rfBillItemService.count(paidWrapper);

        // 查询逾期账单
        LambdaQueryWrapper<RfBillItem> overdueWrapper = new LambdaQueryWrapper<>();
        overdueWrapper.eq(RfBillItem::getPayUserId, userId)
                .eq(RfBillItem::getStatus, "OVERDUE");
        long overdueBills = rfBillItemService.count(overdueWrapper);

        // 构建返回数据
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalBills", totalBills);
        summary.put("pendingBills", pendingBills);
        summary.put("paidBills", paidBills);
        summary.put("overdueBills", overdueBills);

        return summary;
    }

    @Override
    public RfBillItem getBillDetail(Long billId) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        // 查询账单，确保只能查看自己的账单
        LambdaQueryWrapper<RfBillItem> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBillItem::getId, billId)
                .eq(RfBillItem::getPayUserId, userId);

        RfBillItem billItem = rfBillItemService.getOne(queryWrapper);

        if (billItem == null) {
            throw new RuntimeException("Bill not found or access denied");
        }

        return billItem;
    }

    @Override
    public boolean handleBillPaymentSuccess(Long billId, String paymentIntentId) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        // 查询账单，确保只能操作自己的账单
        LambdaQueryWrapper<RfBillItem> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBillItem::getId, billId)
                .eq(RfBillItem::getPayUserId, userId)
                .eq(RfBillItem::getStatus, "PENDING"); // 只能支付待付款的账单

        RfBillItem billItem = rfBillItemService.getOne(queryWrapper);

        if (billItem == null) {
            throw new RuntimeException("Bill not found, already paid, or access denied");
        }

        try {
            // 更新账单状态为已支付
            billItem.setStatus("PAID");
            billItem.setPayTime(LocalDateTime.now());
            // 这里可以保存paymentIntentId作为支付记录ID，如果有相关字段的话
            // billItem.setPaymentRecordId(paymentIntentId);
            billItem.setUpdateTime(LocalDateTime.now());

            // 更新数据库
            boolean updateResult = rfBillItemService.updateById(billItem);

            if (!updateResult) {
                throw new RuntimeException("Failed to update bill status");
            }

            return true;
        } catch (Exception e) {
            throw new RuntimeException("Failed to process bill payment: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean handleBillBalancePayment(Long billId) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        // 查询账单，确保只能操作自己的账单
        LambdaQueryWrapper<RfBillItem> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBillItem::getId, billId)
                .eq(RfBillItem::getPayUserId, userId)
                .eq(RfBillItem::getStatus, "PENDING"); // 只能支付待付款的账单

        RfBillItem billItem = rfBillItemService.getOne(queryWrapper);

        if (billItem == null) {
            throw new RuntimeException("Bill not found, already paid, or access denied");
        }

        try {
            // 检查余额是否充足
            BigDecimal billAmount = billItem.getCost();
            BalanceService.PurchaseCheckResult checkResult = balanceService.checkBalancePurchaseEligibility(billAmount);

            if (!checkResult.isEligible()) {
                throw new RuntimeException("Insufficient balance: " + checkResult.getErrorMessage());
            }

            // 扣除余额
            String description = String.format("支付账单: %s (账单ID: %s)",
                    billItem.getCostDescription(), billId);
            boolean balanceSuccess = balanceService.createBalanceDetailForUser(
                    userId,
                    "BILL_PAYMENT", // 交易类型：账单支付
                    billAmount.negate(), // 负数表示扣除
                    description);

            if (!balanceSuccess) {
                throw new RuntimeException("Failed to deduct balance");
            }

            // 更新账单状态为已支付
            billItem.setStatus("PAID");
            billItem.setPayTime(LocalDateTime.now());
            billItem.setUpdateTime(LocalDateTime.now());
            // 标记为平台支付（余额支付）
            billItem.setIsPlatformPay(true);

            // 更新数据库
            boolean updateResult = rfBillItemService.updateById(billItem);

            if (!updateResult) {
                throw new RuntimeException("Failed to update bill status");
            }

            return true;
        } catch (Exception e) {
            throw new RuntimeException("Failed to process bill balance payment: " + e.getMessage());
        }
    }

    @Override
    public boolean addFavoriteProduct(Long productId) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        if (productId == null) {
            throw new RuntimeException("Product ID cannot be null");
        }

        try {
            return rfUserFavoriteProductService.addFavorite(userId, productId);
        } catch (Exception e) {
            throw new RuntimeException("Failed to add favorite product: " + e.getMessage());
        }
    }

    @Override
    public boolean removeFavoriteProduct(Long productId) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        if (productId == null) {
            throw new RuntimeException("Product ID cannot be null");
        }

        try {
            return rfUserFavoriteProductService.removeFavorite(userId, productId);
        } catch (Exception e) {
            throw new RuntimeException("Failed to remove favorite product: " + e.getMessage());
        }
    }

    @Override
    public boolean isProductFavorited(Long productId) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        if (productId == null) {
            throw new RuntimeException("Product ID cannot be null");
        }

        try {
            return rfUserFavoriteProductService.isFavorited(userId, productId);
        } catch (Exception e) {
            throw new RuntimeException("Failed to check favorite status: " + e.getMessage());
        }
    }

    @Override
    public Page<RfProduct> getUserFavoriteProducts(Integer page, Integer size) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        try {
            // 创建分页对象
            Page<RfUserFavoriteProduct> favoritePageInfo = new Page<>(page, size);

            // 构建查询条件 - 查询用户的收藏记录
            LambdaQueryWrapper<RfUserFavoriteProduct> favoriteWrapper = new LambdaQueryWrapper<>();
            favoriteWrapper.eq(RfUserFavoriteProduct::getUserId, userId);
            favoriteWrapper.orderByDesc(RfUserFavoriteProduct::getFavoriteTime);

            // 分页查询收藏记录
            Page<RfUserFavoriteProduct> favoriteResult = rfUserFavoriteProductService.page(favoritePageInfo,
                    favoriteWrapper);

            // 提取商品ID列表
            List<Long> productIds = favoriteResult.getRecords().stream()
                    .map(RfUserFavoriteProduct::getProductId)
                    .collect(Collectors.toList());

            // 创建商品分页对象
            Page<RfProduct> productPageInfo = new Page<>(page, size);
            productPageInfo.setTotal(favoriteResult.getTotal());
            productPageInfo.setPages(favoriteResult.getPages());
            productPageInfo.setCurrent(favoriteResult.getCurrent());
            productPageInfo.setSize(favoriteResult.getSize());

            if (productIds.isEmpty()) {
                // 如果没有收藏商品，返回空的分页结果
                return productPageInfo;
            }

            // 查询商品详情
            LambdaQueryWrapper<RfProduct> productWrapper = new LambdaQueryWrapper<>();
            productWrapper.in(RfProduct::getId, productIds);
            productWrapper.orderByDesc(RfProduct::getCreateTime);

            List<RfProduct> products = rfProductService.list(productWrapper);

            // 按照收藏时间排序商品
            Map<Long, Integer> productOrderMap = new HashMap<>();
            for (int i = 0; i < productIds.size(); i++) {
                productOrderMap.put(productIds.get(i), i);
            }

            products.sort((p1, p2) -> {
                Integer order1 = productOrderMap.get(p1.getId());
                Integer order2 = productOrderMap.get(p2.getId());
                if (order1 == null)
                    order1 = Integer.MAX_VALUE;
                if (order2 == null)
                    order2 = Integer.MAX_VALUE;
                return order1.compareTo(order2);
            });

            productPageInfo.setRecords(products);
            return productPageInfo;

        } catch (Exception e) {
            throw new RuntimeException("Failed to get favorite products: " + e.getMessage());
        }
    }

    @Override
    public boolean recordBrowseHistory(Long productId) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        if (productId == null) {
            throw new RuntimeException("Product ID cannot be null");
        }

        try {
            return rfUserProductBrowseHistoryService.recordBrowseHistory(userId, productId);
        } catch (Exception e) {
            throw new RuntimeException("Failed to record browse history: " + e.getMessage());
        }
    }

    @Override
    public Page<RfProduct> getUserBrowseHistory(Integer page, Integer size) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not logged in");
        }

        try {
            // 创建分页对象
            Page<RfUserProductBrowseHistory> browsePageInfo = new Page<>(page, size);

            // 构建查询条件 - 查询用户的浏览记录
            LambdaQueryWrapper<RfUserProductBrowseHistory> browseWrapper = new LambdaQueryWrapper<>();
            browseWrapper.eq(RfUserProductBrowseHistory::getUserId, userId);
            browseWrapper.eq(RfUserProductBrowseHistory::getIsDelete, false);
            browseWrapper.orderByDesc(RfUserProductBrowseHistory::getBrowseTime);

            // 分页查询浏览记录
            Page<RfUserProductBrowseHistory> browseResult = rfUserProductBrowseHistoryService.page(browsePageInfo,
                    browseWrapper);

            // 提取商品ID列表
            List<Long> productIds = browseResult.getRecords().stream()
                    .map(RfUserProductBrowseHistory::getProductId)
                    .collect(Collectors.toList());

            // 创建商品分页对象
            Page<RfProduct> productPageInfo = new Page<>(page, size);
            productPageInfo.setTotal(browseResult.getTotal());
            productPageInfo.setPages(browseResult.getPages());
            productPageInfo.setCurrent(browseResult.getCurrent());
            productPageInfo.setSize(browseResult.getSize());

            if (productIds.isEmpty()) {
                // 如果没有浏览记录，返回空的分页结果
                return productPageInfo;
            }

            // 查询商品详情
            LambdaQueryWrapper<RfProduct> productWrapper = new LambdaQueryWrapper<>();
            productWrapper.in(RfProduct::getId, productIds);

            List<RfProduct> products = rfProductService.list(productWrapper);

            // 按照浏览时间排序商品
            Map<Long, Integer> productOrderMap = new HashMap<>();
            for (int i = 0; i < productIds.size(); i++) {
                productOrderMap.put(productIds.get(i), i);
            }

            products.sort((p1, p2) -> {
                Integer order1 = productOrderMap.get(p1.getId());
                Integer order2 = productOrderMap.get(p2.getId());
                if (order1 == null)
                    order1 = Integer.MAX_VALUE;
                if (order2 == null)
                    order2 = Integer.MAX_VALUE;
                return order1.compareTo(order2);
            });

            productPageInfo.setRecords(products);
            return productPageInfo;

        } catch (Exception e) {
            throw new RuntimeException("Failed to get browse history: " + e.getMessage());
        }
    }

    @Override
    public Long getProductBrowseCount(Long productId) {
        if (productId == null) {
            throw new RuntimeException("Product ID cannot be null");
        }

        try {
            // 构建查询条件 - 查询某个商品的所有浏览记录
            LambdaQueryWrapper<RfUserProductBrowseHistory> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(RfUserProductBrowseHistory::getProductId, productId);
            queryWrapper.eq(RfUserProductBrowseHistory::getIsDelete, false);

            return rfUserProductBrowseHistoryService.count(queryWrapper);
        } catch (Exception e) {
            throw new RuntimeException("Failed to get product browse count: " + e.getMessage());
        }
    }
}