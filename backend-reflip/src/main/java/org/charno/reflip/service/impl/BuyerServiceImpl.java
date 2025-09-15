package org.charno.reflip.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.reflip.entity.RfWarehouse;
import org.charno.reflip.entity.RfWarehouseStock;
import org.charno.reflip.entity.RfInternalLogisticsTask;
import org.charno.reflip.entity.RfBalanceDetail;
import org.charno.reflip.service.IBuyerService;
import org.charno.reflip.service.IRfProductService;
import org.charno.reflip.service.IRfProductSellRecordService;
import org.charno.reflip.service.IRfWarehouseService;
import org.charno.reflip.service.IRfWarehouseStockService;
import org.charno.reflip.service.IRfInternalLogisticsTaskService;
import org.charno.reflip.service.IWarehouseService;
import org.charno.reflip.service.IRfProductReturnRecordService;
import org.charno.reflip.service.IRfBalanceDetailService;
import org.charno.reflip.service.BalanceService;
import org.charno.common.utils.SecurityUtils;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import org.charno.reflip.entity.RfPurchaseReview;
import org.charno.reflip.entity.RfProductReturnRecord;
import org.charno.reflip.mapper.RfProductMapper;
import org.charno.reflip.mapper.RfProductSellRecordMapper;
import org.charno.reflip.mapper.RfPurchaseReviewMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.List;

/**
 * 买家业务实现类
 */
@Service
public class BuyerServiceImpl implements IBuyerService {

    private static final Logger log = LoggerFactory.getLogger(BuyerServiceImpl.class);

    @Autowired
    private IRfProductService rfProductService;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Autowired
    private IRfProductSellRecordService rfProductSellRecordService;

    @Autowired
    private IRfWarehouseService rfWarehouseService;

    @Autowired
    private IRfWarehouseStockService rfWarehouseStockService;

    @Autowired
    private IRfInternalLogisticsTaskService rfInternalLogisticsTaskService;

    @Autowired
    private IWarehouseService warehouseService;

    @Autowired
    private RfProductMapper productMapper;

    @Autowired
    private RfProductSellRecordMapper sellRecordMapper;

    @Autowired
    private RfPurchaseReviewMapper purchaseReviewMapper;

    @Autowired
    private IRfProductReturnRecordService rfProductReturnRecordService;

    @Autowired
    private IRfBalanceDetailService rfBalanceDetailService;

    @Autowired
    @Lazy
    private BalanceService balanceService;

    private static final String PRODUCT_LOCK_PREFIX = "reflip:product_lock:";
    private static final long LOCK_EXPIRE_TIME = 60; // 2分钟，单位：秒

    @Override
    public boolean lockProduct(Long productId) {
        if (productId == null) {
            throw new IllegalArgumentException("Product ID cannot be null");
        }

        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        String lockKey = PRODUCT_LOCK_PREFIX + productId;

        // 检查商品是否存在且可购买
        RfProduct product = getAvailableProduct(productId);
        if (product == null) {
            throw new RuntimeException("Product not found or not available");
        }

        // 使用Redis的SETNX命令实现分布式锁
        Boolean lockResult = redisTemplate.opsForValue().setIfAbsent(
                lockKey,
                userId.toString(),
                LOCK_EXPIRE_TIME,
                TimeUnit.SECONDS);

        return lockResult != null && lockResult;
    }

    @Override
    public boolean isProductLocked(Long productId) {
        if (productId == null) {
            return false;
        }

        String lockKey = PRODUCT_LOCK_PREFIX + productId;
        return redisTemplate.hasKey(lockKey);
    }

    @Override
    public boolean unlockProduct(Long productId) {
        if (productId == null) {
            return false;
        }

        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return false;
        }

        String lockKey = PRODUCT_LOCK_PREFIX + productId;
        Object lockValue = redisTemplate.opsForValue().get(lockKey);

        // 只有锁定者本人才能解锁
        if (lockValue != null && lockValue.toString().equals(userId.toString())) {
            redisTemplate.delete(lockKey);
            return true;
        }

        return false;
    }

    @Override
    public boolean isLockOwner(Long productId) {
        if (productId == null) {
            return false;
        }

        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return false;
        }

        String lockKey = PRODUCT_LOCK_PREFIX + productId;
        Object lockValue = redisTemplate.opsForValue().get(lockKey);

        // 检查锁是否存在且当前用户是拥有者
        return lockValue != null && lockValue.toString().equals(userId.toString());
    }

    @Override
    public long getLockRemainingTime(Long productId) {
        if (productId == null) {
            return -1;
        }

        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return -1;
        }

        String lockKey = PRODUCT_LOCK_PREFIX + productId;
        Object lockValue = redisTemplate.opsForValue().get(lockKey);

        // 检查锁是否存在且当前用户是拥有者
        if (lockValue != null && lockValue.toString().equals(userId.toString())) {
            // 获取键的剩余过期时间
            Long expireTime = redisTemplate.getExpire(lockKey, TimeUnit.SECONDS);
            return expireTime != null ? expireTime : -1;
        }

        return -1;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean handlePurchaseSuccess(Long productId, String paymentIntentId) {
        if (productId == null) {
            throw new IllegalArgumentException("Product ID cannot be null");
        }

        // 获取当前用户ID（买家）
        Long buyerUserId = SecurityUtils.getUserId();
        if (buyerUserId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 检查用户是否是锁的拥有者
        if (!isLockOwner(productId)) {
            throw new RuntimeException("User is not the lock owner of this product");
        }

        // 获取商品信息
        RfProduct product = getAvailableProduct(productId);
        if (product == null) {
            throw new RuntimeException("Product not found or not available");
        }

        // 检查商品是否为非寄卖商品
        if (product.getIsAuction() != null && product.getIsAuction()) {
            throw new RuntimeException("This method is only for non-consignment products");
        }

        try {
            // 1. 更新商品状态为SOLD
            product.setStatus("SOLD");
            product.setUpdateTime(LocalDateTime.now());
            boolean productUpdated = rfProductService.updateById(product);

            if (!productUpdated) {
                throw new RuntimeException("Failed to update product status");
            }

            // 2. 创建销售记录
            RfProductSellRecord sellRecord = new RfProductSellRecord();
            sellRecord.setProductId(productId);
            sellRecord.setSellerUserId(product.getUserId());
            sellRecord.setBuyerUserId(buyerUserId);
            sellRecord.setFinalProductPrice(product.getPrice());
            sellRecord.setIsAuction(false); // 非寄卖
            sellRecord.setIsSelfPickup(product.getIsSelfPickup());
            sellRecord.setStatus("PENDING_RECEIPT"); // 已支付状态
            sellRecord.setCreateTime(LocalDateTime.now());
            sellRecord.setUpdateTime(LocalDateTime.now());
            sellRecord.setIsDelete(false);

            boolean recordSaved = rfProductSellRecordService.save(sellRecord);

            if (!recordSaved) {
                throw new RuntimeException("Failed to create sell record");
            }

            // 3. 释放商品锁
            unlockProduct(productId);

            return true;

        } catch (Exception e) {
            // 事务会自动回滚
            throw new RuntimeException("Purchase processing failed: " + e.getMessage(), e);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean handleConsignmentPurchaseSuccess(Long productId, String paymentIntentId,
            String deliveryAddress, String deliveryPhone, String deliveryName) {
        if (productId == null) {
            throw new IllegalArgumentException("Product ID cannot be null");
        }

        // 获取当前用户ID（买家）
        Long buyerUserId = SecurityUtils.getUserId();
        if (buyerUserId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 检查用户是否是锁的拥有者
        if (!isLockOwner(productId)) {
            throw new RuntimeException("User is not the lock owner of this product");
        }

        // 获取商品信息
        RfProduct product = getAvailableProduct(productId);
        if (product == null) {
            throw new RuntimeException("Product not found or not available");
        }

        // 检查商品是否为寄卖商品
        if (product.getIsAuction() == null || !product.getIsAuction()) {
            throw new RuntimeException("This method is only for consignment products");
        }

        // 检查商品是否有仓库库存记录
        if (product.getWarehouseStockId() == null) {
            throw new RuntimeException("Product does not have warehouse stock record");
        }

        // 验证和解析收货地址 (必须是有效的Google地图JSON格式)
        String validatedAddress = validateAndParseDeliveryAddress(deliveryAddress);

        try {
            // 1. 根据warehouse_stock_id进行出库操作
            boolean warehouseOutSuccess = warehouseService.warehouseOut(product.getWarehouseStockId(), "SOLD");
            if (!warehouseOutSuccess) {
                throw new RuntimeException("Failed to process warehouse out operation");
            }

            // 2. 更新商品状态为SOLD
            product.setStatus("SOLD");
            product.setUpdateTime(LocalDateTime.now());
            boolean productUpdated = rfProductService.updateById(product);
            if (!productUpdated) {
                throw new RuntimeException("Failed to update product status");
            }

            // 3. 创建销售记录
            RfProductSellRecord sellRecord = new RfProductSellRecord();
            sellRecord.setProductId(productId);
            sellRecord.setSellerUserId(product.getUserId());
            sellRecord.setBuyerUserId(buyerUserId);
            sellRecord.setFinalProductPrice(product.getPrice());
            sellRecord.setIsAuction(true); // 寄卖商品
            sellRecord.setIsSelfPickup(false); // 寄卖商品不支持自取
            sellRecord.setStatus("PENDING_SHIPMENT"); // 待发货状态
            sellRecord.setCreateTime(LocalDateTime.now());
            sellRecord.setUpdateTime(LocalDateTime.now());
            sellRecord.setIsDelete(false);

            boolean recordSaved = rfProductSellRecordService.save(sellRecord);
            if (!recordSaved) {
                throw new RuntimeException("Failed to create sell record");
            }

            // 4. 获取仓库地址作为源地址
            RfWarehouseStock warehouseStock = rfWarehouseStockService.getById(product.getWarehouseStockId());
            if (warehouseStock == null) {
                throw new RuntimeException("Warehouse stock record not found");
            }

            RfWarehouse warehouse = rfWarehouseService.getById(warehouseStock.getWarehouseId());
            if (warehouse == null) {
                throw new RuntimeException("Warehouse not found");
            }

            // 5. 创建内部物流任务
            RfInternalLogisticsTask logisticsTask = new RfInternalLogisticsTask();
            logisticsTask.setProductId(productId);
            logisticsTask.setProductSellRecordId(sellRecord.getId());
            logisticsTask.setTaskType("WAREHOUSE_SHIPMENT"); // 仓库发货
            logisticsTask.setSourceAddress(warehouse.getAddress()); // 仓库地址作为源地址
            logisticsTask.setTargetAddress(validatedAddress); // 使用验证后的买家收货地址作为目标地址
            logisticsTask.setContactPhone(deliveryPhone); // 收货人电话
            logisticsTask.setLogisticsCost(BigDecimal.ZERO); // 物流费用暂设为0，后续可配置
            logisticsTask.setStatus("PENDING_ACCEPT"); // 待接受状态
            logisticsTask.setCreateTime(LocalDateTime.now());
            logisticsTask.setUpdateTime(LocalDateTime.now());
            logisticsTask.setIsDelete(false);

            boolean taskSaved = rfInternalLogisticsTaskService.save(logisticsTask);
            if (!taskSaved) {
                throw new RuntimeException("Failed to create internal logistics task");
            }

            // 6. 释放商品锁
            unlockProduct(productId);

            return true;

        } catch (Exception e) {
            // 事务会自动回滚
            throw new RuntimeException("Consignment purchase processing failed: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean isProductOwner(Long productId) {
        if (productId == null) {
            return false;
        }

        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return false;
        }

        // 查询商品信息
        RfProduct product = rfProductService.getById(productId);
        if (product == null || product.getIsDelete()) {
            return false;
        }

        // 检查商品的发布人是否是当前用户
        return userId.equals(product.getUserId());
    }

    @Override
    public Page<RfProductSellRecord> getMyOrders(int page, int size) {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 创建分页对象
        Page<RfProductSellRecord> pageRequest = new Page<>(page, size);

        // 构建查询条件：查询当前用户作为买家的购买记录
        QueryWrapper<RfProductSellRecord> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("buyer_user_id", userId)
                .orderByDesc("create_time"); // 按创建时间降序排列

        // 执行分页查询
        Page<RfProductSellRecord> result = rfProductSellRecordService.page(pageRequest, queryWrapper);

        // 为每个销售记录填充商品信息
        for (RfProductSellRecord record : result.getRecords()) {
            if (record.getProductId() != null) {
                RfProduct product = rfProductService.getById(record.getProductId());
                record.setProduct(product);
            }
        }

        return result;
    }

    /**
     * 获取可购买的商品
     * 
     * @param productId 商品ID
     * @return 商品信息，如果不存在或不可购买则返回null
     */
    private RfProduct getAvailableProduct(Long productId) {
        QueryWrapper<RfProduct> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("id", productId)
                .eq("status", "LISTED");

        return rfProductService.getOne(queryWrapper);
    }

    /**
     * 验证和解析收货地址，确保是有效的Google地图JSON格式
     * 
     * @param deliveryAddress 收货地址JSON字符串
     * @return 验证后的地址JSON字符串
     * @throws RuntimeException 如果地址格式无效
     */
    private String validateAndParseDeliveryAddress(String deliveryAddress) {
        if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
            throw new RuntimeException("Delivery address cannot be null or empty");
        }

        try {
            // 尝试解析JSON
            JSONObject addressJson = JSON.parseObject(deliveryAddress);

            // 验证必要的字段
            if (!addressJson.containsKey("formattedAddress") ||
                    !addressJson.containsKey("latitude") ||
                    !addressJson.containsKey("longitude")) {
                throw new RuntimeException("Address must contain formattedAddress, latitude, and longitude");
            }

            // 验证数据类型
            String formattedAddress = addressJson.getString("formattedAddress");
            Double latitude = addressJson.getDouble("latitude");
            Double longitude = addressJson.getDouble("longitude");

            if (formattedAddress == null || formattedAddress.trim().isEmpty()) {
                throw new RuntimeException("Formatted address cannot be empty");
            }

            if (latitude == null || longitude == null) {
                throw new RuntimeException("Latitude and longitude must be valid numbers");
            }

            // 验证经纬度范围
            if (latitude < -90 || latitude > 90) {
                throw new RuntimeException("Latitude must be between -90 and 90");
            }

            if (longitude < -180 || longitude > 180) {
                throw new RuntimeException("Longitude must be between -180 and 180");
            }

            // 返回原始JSON字符串（已经验证过格式）
            return deliveryAddress;

        } catch (Exception e) {
            if (e instanceof RuntimeException) {
                throw e;
            }
            throw new RuntimeException(
                    "Invalid delivery address format. Must be valid Google Maps JSON format: " + e.getMessage());
        }
    }

    /**
     * 确认收货
     * 
     * @param orderId       订单ID
     * @param comment       评价内容
     * @param receiptImages 收货凭证图片列表
     * @return 确认是否成功
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean confirmReceipt(String orderId, String comment, List<String> receiptImages) {
        try {
            // 获取当前登录用户ID
            Long userId = SecurityUtils.getUserId();

            // 查询订单信息
            Long orderIdLong = Long.parseLong(orderId);
            RfProductSellRecord sellRecord = sellRecordMapper.selectById(orderIdLong);

            if (sellRecord == null) {
                log.error("订单不存在: {}", orderId);
                throw new RuntimeException("订单不存在: " + orderId);
            }

            // 验证订单是否属于当前用户
            if (!sellRecord.getBuyerUserId().equals(userId)) {
                log.error("用户无权确认此订单: userId={}, orderId={}", userId, orderId);
                throw new RuntimeException("您无权确认此订单");
            }

            // 查询商品信息
            RfProduct product = productMapper.selectById(sellRecord.getProductId());
            if (product == null) {
                log.error("商品不存在: {}", sellRecord.getProductId());
                throw new RuntimeException("商品不存在: " + sellRecord.getProductId());
            }

            // 区分寄卖和非寄卖商品的状态验证
            boolean isConsignment = product.getIsAuction() != null && product.getIsAuction();
            if (isConsignment) {
                // 寄卖商品只有DELIVERED状态可以确认收货
                if (!"DELIVERED".equals(sellRecord.getStatus())) {
                    log.error("寄卖商品订单状态不允许确认收货: {}", sellRecord.getStatus());
                    throw new RuntimeException("寄卖商品订单状态不允许确认收货，当前状态: " + sellRecord.getStatus() + "，需要状态: DELIVERED");
                }
            } else {
                // 非寄卖商品只有PENDING_RECEIPT状态可以确认收货
                if (!"PENDING_RECEIPT".equals(sellRecord.getStatus())) {
                    log.error("非寄卖商品订单状态不允许确认收货: {}", sellRecord.getStatus());
                    throw new RuntimeException(
                            "非寄卖商品订单状态不允许确认收货，当前状态: " + sellRecord.getStatus() + "，需要状态: PENDING_RECEIPT");
                }
            }

            // 先处理支付，支付成功后才更新订单状态
            boolean paymentSuccess;
            if (product.getIsAuction() != null && product.getIsAuction()) {
                // 寄卖商品处理逻辑
                paymentSuccess = handleConsignmentPayment(sellRecord);
            } else {
                // 非寄卖商品处理逻辑
                paymentSuccess = handleRegularPayment(sellRecord);
            }

            // 只有支付成功才更新订单状态为CONFIRMED
            if (!paymentSuccess) {
                throw new RuntimeException("支付失败，无法确认收货");
            }

            // 更新订单状态为已确认
            LambdaUpdateWrapper<RfProductSellRecord> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.eq(RfProductSellRecord::getId, orderIdLong)
                    .set(RfProductSellRecord::getStatus, "CONFIRMED")
                    .set(RfProductSellRecord::getUpdateTime, LocalDateTime.now());

            // 如果有收货凭证，保存图片路径JSON
            if (receiptImages != null && !receiptImages.isEmpty()) {
                Map<String, String> imageMap = convertListToMap(receiptImages);
                updateWrapper.set(RfProductSellRecord::getBuyerReceiptImageUrlJson, JSON.toJSONString(imageMap));
            }

            int updatedRows = sellRecordMapper.update(null, updateWrapper);
            if (updatedRows <= 0) {
                log.error("更新订单状态失败: {}", orderId);
                throw new RuntimeException("更新订单状态失败");
            }

            // 如果有评价内容，创建评价记录
            if (comment != null && !comment.trim().isEmpty()) {
                RfPurchaseReview review = new RfPurchaseReview();
                review.setProductId(sellRecord.getProductId());
                review.setProductSellRecordId(orderIdLong);
                review.setSellerUserId(sellRecord.getSellerUserId());
                review.setReviewerUserId(userId);
                review.setReviewContent(comment);

                // 如果有图片，保存到评价记录
                if (receiptImages != null && !receiptImages.isEmpty()) {
                    Map<String, String> imageMap = convertListToMap(receiptImages);
                    review.setReviewImagesJson(JSON.toJSONString(imageMap));
                }

                review.setCreateTime(LocalDateTime.now());
                review.setUpdateTime(LocalDateTime.now());
                review.setIsDelete(false);

                purchaseReviewMapper.insert(review);
            }

            log.info("确认收货成功: orderId={}", orderId);
            return true;

        } catch (Exception e) {
            log.error("确认收货处理出错", e);
            throw e;
        }
    }

    /**
     * 处理非寄卖商品的付款
     */
    private boolean handleRegularPayment(RfProductSellRecord sellRecord) {
        try {
            // 使用BalanceService创建卖家余额明细记录，增加收入
            boolean balanceSuccess = balanceService.createBalanceDetailForUser(
                    sellRecord.getSellerUserId(),
                    "COMMISSION", // 交易类型：佣金收入
                    sellRecord.getFinalProductPrice(),
                    "确认收货付款 - 订单ID: " + sellRecord.getId());

            if (!balanceSuccess) {
                log.error("创建卖家余额明细失败: orderId={}", sellRecord.getId());
                throw new RuntimeException("创建卖家余额明细失败，请稍后再试或联系客服");
            }

            log.info("确认收货并向卖家账户增加余额成功: orderId={}, amount={}",
                    sellRecord.getId(), sellRecord.getFinalProductPrice());
            return true;

        } catch (Exception e) {
            log.error("处理非寄卖商品付款出错", e);
            throw e; // 直接抛出异常，确保事务回滚
        }
    }

    /**
     * 处理寄卖商品的付款
     */
    private boolean handleConsignmentPayment(RfProductSellRecord sellRecord) {
        try {
            // 寄卖商品的付款逻辑，目前与非寄卖商品一致
            return handleRegularPayment(sellRecord);
        } catch (Exception e) {
            log.error("处理寄卖商品付款出错", e);
            throw e; // 直接抛出异常，确保事务回滚
        }
    }

    /**
     * 将图片路径列表转换为Map格式，用于存储为JSON
     */
    private Map<String, String> convertListToMap(List<String> imageUrls) {
        Map<String, String> imageMap = new java.util.HashMap<>();
        for (int i = 0; i < imageUrls.size(); i++) {
            imageMap.put(String.valueOf(i + 1), imageUrls.get(i));
        }
        return imageMap;
    }

    /**
     * 申请退货
     * 
     * @param orderId       订单ID
     * @param reason        退货原因类型
     * @param description   退货原因详细说明
     * @param pickupAddress 取货地址
     * @return 申请是否成功
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean applyRefund(String orderId, String reason, String description, String pickupAddress) {
        try {
            // 获取当前登录用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                throw new RuntimeException("用户未登录");
            }

            // 查询订单信息
            Long orderIdLong = Long.parseLong(orderId);
            RfProductSellRecord sellRecord = sellRecordMapper.selectById(orderIdLong);

            if (sellRecord == null) {
                log.error("订单不存在: {}", orderId);
                throw new RuntimeException("订单不存在: " + orderId);
            }

            // 验证订单是否属于当前用户
            if (!sellRecord.getBuyerUserId().equals(userId)) {
                log.error("用户无权对此订单申请退货: userId={}, orderId={}", userId, orderId);
                throw new RuntimeException("您无权对此订单申请退货");
            }

            // 查询商品信息
            RfProduct product = productMapper.selectById(sellRecord.getProductId());
            if (product == null) {
                log.error("商品不存在: {}", sellRecord.getProductId());
                throw new RuntimeException("商品不存在: " + sellRecord.getProductId());
            }

            // 验证订单状态是否允许退货
            String currentStatus = sellRecord.getStatus();
            if (!"PENDING_SHIPMENT".equals(currentStatus) &&
                    !"PENDING_RECEIPT".equals(currentStatus) &&
                    !"DELIVERED".equals(currentStatus)) {
                log.error("订单状态不允许退货: {}", currentStatus);
                throw new RuntimeException("订单状态不允许退货，当前状态: " + currentStatus +
                        "，允许状态: PENDING_SHIPMENT, PENDING_RECEIPT, DELIVERED");
            }

            // 检查是否已经存在退货申请
            LambdaQueryWrapper<RfProductReturnRecord> checkWrapper = new LambdaQueryWrapper<>();
            checkWrapper.eq(RfProductReturnRecord::getProductSellRecordId, orderIdLong)
                    .eq(RfProductReturnRecord::getIsDelete, false);
            RfProductReturnRecord existingReturn = rfProductReturnRecordService.getOne(checkWrapper);

            if (existingReturn != null) {
                log.error("订单已存在退货申请: {}", orderId);
                throw new RuntimeException("该订单已存在退货申请，请勿重复提交");
            }

            // 1. 更新销售记录状态为 RETURN_INITIATED
            LambdaUpdateWrapper<RfProductSellRecord> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.eq(RfProductSellRecord::getId, orderIdLong)
                    .set(RfProductSellRecord::getStatus, "RETURN_INITIATED")
                    .set(RfProductSellRecord::getUpdateTime, LocalDateTime.now());

            int updatedRows = sellRecordMapper.update(null, updateWrapper);
            if (updatedRows <= 0) {
                log.error("更新订单状态失败: {}", orderId);
                throw new RuntimeException("更新订单状态失败");
            }

            // 2. 创建退货记录
            RfProductReturnRecord returnRecord = new RfProductReturnRecord();
            returnRecord.setProductId(sellRecord.getProductId());
            returnRecord.setProductSellRecordId(orderIdLong);
            returnRecord.setReturnReasonType(reason);
            returnRecord.setReturnReasonDetail(description);
            returnRecord.setPickupAddress(pickupAddress); // 设置取货地址

            // 设置是否寄卖信息
            returnRecord.setIsAuction(product.getIsAuction());

            // 设置退货记录状态为 RETURN_INITIATED
            returnRecord.setStatus("RETURN_INITIATED");
            returnRecord.setCreateTime(LocalDateTime.now());
            returnRecord.setUpdateTime(LocalDateTime.now());
            returnRecord.setIsDelete(false);

            boolean returnRecordSaved = rfProductReturnRecordService.save(returnRecord);
            if (!returnRecordSaved) {
                log.error("创建退货记录失败: {}", orderId);
                throw new RuntimeException("创建退货记录失败");
            }

            log.info("退货申请提交成功: orderId={}, returnRecordId={}", orderId, returnRecord.getId());
            return true;

        } catch (NumberFormatException e) {
            log.error("订单ID格式错误: {}", orderId);
            throw new RuntimeException("订单ID格式错误");
        } catch (Exception e) {
            log.error("退货申请处理出错", e);
            throw e;
        }
    }
}