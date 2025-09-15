package org.charno.reflip.service.impl;

import org.charno.system.mapper.SysUserStripeAccountMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import com.stripe.Stripe;
import com.stripe.model.Account;
import com.stripe.model.AccountLink;
import com.stripe.param.AccountCreateParams;
import com.stripe.param.AccountLinkCreateParams;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import jakarta.annotation.PostConstruct;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.entity.RfProductAuctionLogistics;
import org.charno.reflip.service.ISellerService;
import org.charno.reflip.service.IRfProductService;
import org.charno.reflip.service.IRfProductAuctionLogisticsService;
import org.charno.reflip.service.IRfWarehouseService;
import org.charno.reflip.entity.RfWarehouse;
import org.charno.reflip.service.IRfInternalLogisticsTaskService;
import org.charno.reflip.entity.RfInternalLogisticsTask;
import org.charno.reflip.dto.ConsignmentListingRequest;
import org.charno.common.utils.SecurityUtils;
import org.charno.common.utils.GoogleMapsUtils;
import org.charno.common.dto.LocationDto;
import org.charno.common.dto.DistanceResult;
import org.charno.common.entity.SysUserStripeAccount;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.reflip.entity.RfProductReturnRecord;
import org.charno.reflip.entity.RfInternalLogisticsTask;
import org.charno.reflip.entity.RfWarehouse;
import org.charno.reflip.mapper.RfProductSellRecordMapper;
import org.charno.reflip.mapper.RfProductReturnRecordMapper;
import org.charno.reflip.entity.RfProductReturnToSeller;
import org.charno.reflip.service.IRfProductReturnToSellerService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * 卖家业务实现类
 */
@Slf4j
@Service
public class SellerServiceImpl implements ISellerService {

    @Autowired
    private IRfProductService rfProductService;

    @Autowired
    private IRfProductAuctionLogisticsService rfProductAuctionLogisticsService;
    
    @Autowired
    private IRfWarehouseService rfWarehouseService;
    
    @Autowired
    private GoogleMapsUtils googleMapsUtils;
    
    @Autowired
    private IRfInternalLogisticsTaskService rfInternalLogisticsTaskService;

    @Autowired
    private RfProductSellRecordMapper rfProductSellRecordMapper;

    @Autowired
    private SysUserStripeAccountMapper sysUserStripeAccountMapper;

    @Autowired
    private RfProductReturnRecordMapper rfProductReturnRecordMapper;

    @Autowired
    private IRfProductReturnToSellerService rfProductReturnToSellerService;

    @Value("${stripe.secret-key}")
    private String stripeSecretKey;

    @Value("${stripe.connect.client-id}")
    private String stripeConnectClientId;

    @Value("${stripe.connect.refresh-url}")
    private String stripeConnectRefreshUrl;

    @Value("${stripe.connect.return-url}")
    private String stripeConnectReturnUrl;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @PostConstruct
    public void initStripe() {
        Stripe.apiKey = stripeSecretKey;
    }

    @Override
    public RfProduct listProduct(RfProduct rfProduct) {
        // 数据验证
        validateProductData(rfProduct);
        
        // 设置默认状态和时间
        rfProduct.setStatus("active"); // 设置商品状态为激活
        rfProduct.setCreateTime(LocalDateTime.now());
        rfProduct.setUpdateTime(LocalDateTime.now());
        rfProduct.setIsDelete(false); // 设置为未删除
        
        // 保存商品
        boolean success = rfProductService.save(rfProduct);
        if (!success) {
            throw new RuntimeException("保存商品失败");
        }
        
        return rfProduct;
    }
    
    /**
     * 验证商品数据
     * 
     * @param rfProduct 商品信息
     */
    private void validateProductData(RfProduct rfProduct) {
        if (rfProduct == null) {
            throw new IllegalArgumentException("商品信息不能为空");
        }
        
        if (!StringUtils.hasText(rfProduct.getName())) {
            throw new IllegalArgumentException("商品名称不能为空");
        }
        
        if (!StringUtils.hasText(rfProduct.getDescription())) {
            throw new IllegalArgumentException("商品描述不能为空");
        }
        
        if (rfProduct.getPrice() == null || rfProduct.getPrice().compareTo(java.math.BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("商品价格必须大于0");
        }
        
        if (!StringUtils.hasText(rfProduct.getImageUrlJson())) {
            throw new IllegalArgumentException("商品图片不能为空");
        }
        
        if (!StringUtils.hasText(rfProduct.getType())) {
            throw new IllegalArgumentException("商品类型不能为空");
        }
        
        if (!StringUtils.hasText(rfProduct.getCategory())) {
            throw new IllegalArgumentException("商品类别不能为空");
        }
        
        if (rfProduct.getIsSelfPickup() == null) {
            throw new IllegalArgumentException("配送方式不能为空");
        }
        
        // 设置默认库存为1（如果未设置）
        if (rfProduct.getStock() == null || rfProduct.getStock() <= 0) {
            rfProduct.setStock(1);
        }
        
        // 设置默认拍卖状态为false（如果未设置）
        if (rfProduct.getIsAuction() == null) {
            rfProduct.setIsAuction(false);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public RfProduct consignmentListing(ConsignmentListingRequest request) {
        // 验证请求数据
        validateConsignmentRequest(request);

        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 创建商品实体
        RfProduct rfProduct = createProductFromRequest(request, userId);

        // 保存商品到数据库
        boolean productSaved = rfProductService.save(rfProduct);
        if (!productSaved) {
            throw new RuntimeException("Failed to save product");
        }

        // 创建物流实体
        RfProductAuctionLogistics logistics = createLogisticsFromRequest(request, rfProduct.getId());

        // 保存物流记录到数据库
        boolean logisticsSaved = rfProductAuctionLogisticsService.save(logistics);
        if (!logisticsSaved) {
            throw new RuntimeException("Failed to save logistics information");
        }

        // 计算距离并获取最近仓库
        RfWarehouse nearestWarehouse = calculateWarehouseDistances(request.getPickupAddress());
        
        // 如果找到了最近的仓库，更新物流记录并创建内部物流任务
        if (nearestWarehouse != null) {
            // 记录商品的寄卖仓库
            rfProduct.setWarehouseId(nearestWarehouse.getId());
            rfProductService.updateById(rfProduct);

            // 更新物流记录中的仓库信息
            logistics.setWarehouseId(nearestWarehouse.getId());
            logistics.setWarehouseAddress(nearestWarehouse.getAddress());
            rfProductAuctionLogisticsService.updateById(logistics);
            
            // 创建内部物流任务
            RfInternalLogisticsTask logisticsTask = createInternalLogisticsTask(
                rfProduct.getId(),
                logistics.getId(),
                request.getPickupAddress(), 
                nearestWarehouse.getAddress()
            );
            
            // 保存内部物流任务
            boolean taskSaved = rfInternalLogisticsTaskService.save(logisticsTask);
            if (taskSaved) {
                // 更新物流记录中的内部物流任务ID
                logistics.setInternalLogisticsTaskId(logisticsTask.getId());
                rfProductAuctionLogisticsService.updateById(logistics);
                log.info("成功创建内部物流任务，任务ID: {}", logisticsTask.getId());
            } else {
                log.error("内部物流任务保存失败");
            }
        }

        return rfProduct;
    }

    /**
     * 验证寄卖请求数据
     */
    private void validateConsignmentRequest(ConsignmentListingRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Request cannot be null");
        }

        if (!StringUtils.hasText(request.getName())) {
            throw new IllegalArgumentException("Product name cannot be empty");
        }

        if (!StringUtils.hasText(request.getDescription())) {
            throw new IllegalArgumentException("Product description cannot be empty");
        }

        if (request.getPrice() == null || request.getPrice().compareTo(java.math.BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Product price must be greater than 0");
        }

        if (!StringUtils.hasText(request.getImageUrlJson())) {
            throw new IllegalArgumentException("Product images cannot be empty");
        }

        if (!StringUtils.hasText(request.getType())) {
            throw new IllegalArgumentException("Product type cannot be empty");
        }

        if (!StringUtils.hasText(request.getCategory())) {
            throw new IllegalArgumentException("Product category cannot be empty");
        }

        if (!StringUtils.hasText(request.getPickupAddress())) {
            throw new IllegalArgumentException("Pickup address cannot be empty");
        }

        if (request.getAppointmentPickupDate() == null) {
            throw new IllegalArgumentException("Pickup date cannot be empty");
        }

        if (!StringUtils.hasText(request.getAppointmentPickupTimePeriod())) {
            throw new IllegalArgumentException("Pickup time period cannot be empty");
        }
    }

    /**
     * 从请求创建商品实体
     */
    private RfProduct createProductFromRequest(ConsignmentListingRequest request, Long userId) {
        RfProduct rfProduct = new RfProduct();
        
        // 设置基本信息
        rfProduct.setUserId(userId);
        rfProduct.setName(request.getName());
        rfProduct.setCategoryId(request.getCategoryId());
        rfProduct.setType(request.getType());
        rfProduct.setCategory(request.getCategory());
        rfProduct.setPrice(request.getPrice());
        rfProduct.setStock(request.getStock() != null ? request.getStock() : 1);
        rfProduct.setDescription(request.getDescription());
        rfProduct.setImageUrlJson(request.getImageUrlJson());
        rfProduct.setAddress(request.getPickupAddress());
        
        // 设置寄卖相关状态
        rfProduct.setIsAuction(true); // 寄卖商品
        rfProduct.setIsSelfPickup(false); // 不是自提
        rfProduct.setStatus("UNLISTED"); // 状态为未上架
        
        // 设置时间
        LocalDateTime now = LocalDateTime.now();
        rfProduct.setCreateTime(now);
        rfProduct.setUpdateTime(now);
        rfProduct.setIsDelete(false);
        
        return rfProduct;
    }

    /**
     * 从请求创建物流实体
     */
    private RfProductAuctionLogistics createLogisticsFromRequest(ConsignmentListingRequest request, Long productId) {
        RfProductAuctionLogistics logistics = new RfProductAuctionLogistics();
        
        // 设置基本信息
        logistics.setProductId(productId);
        logistics.setPickupAddress(request.getPickupAddress());
        logistics.setIsUseLogisticsService(true);
        logistics.setAppointmentPickupDate(request.getAppointmentPickupDate());
        logistics.setAppointmentPickupTimePeriod(request.getAppointmentPickupTimePeriod());
        logistics.setStatus("PENDING_PICKUP");
        
        // 设置时间
        LocalDateTime now = LocalDateTime.now();
        logistics.setCreateTime(now);
        logistics.setUpdateTime(now);
        logistics.setIsDelete(false);
        
        return logistics;
    }

    @Override
    public RfProduct selfPickupListing(RfProduct rfProduct) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 设置用户ID
        rfProduct.setUserId(userId);

        // 数据验证
        validateProductData(rfProduct);

        // 设置自提相关的状态
        rfProduct.setStatus("LISTED"); // 状态为已上架
        rfProduct.setIsAuction(false); // 不是寄卖商品
        rfProduct.setIsSelfPickup(true); // 是自提商品
        
        // 设置时间
        LocalDateTime now = LocalDateTime.now();
        rfProduct.setCreateTime(now);
        rfProduct.setUpdateTime(now);
        rfProduct.setIsDelete(false);

        // 保存商品
        boolean success = rfProductService.save(rfProduct);
        if (!success) {
            throw new RuntimeException("保存商品失败");
        }

        log.info("自提商品上架成功 - 商品ID: {} | 用户ID: {} | 商品名称: {}", 
            rfProduct.getId(), userId, rfProduct.getName());

        return rfProduct;
    }

    @Override
    public List<RfProduct> getMyProducts() {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 查询当前用户的所有商品，按创建时间倒序排列
        QueryWrapper<RfProduct> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                //    .eq("is_delete", false) // 只查询未删除的商品
                   .orderByDesc("create_time"); // 按创建时间倒序

        return rfProductService.list(queryWrapper);
    }
    
    /**
     * 计算取件地址到各个仓库的距离
     * 
     * @param pickupAddress 取件地址JSON字符串
     * @return 距离最近的仓库，如果没有找到则返回null
     */
    private RfWarehouse calculateWarehouseDistances(String pickupAddress) {
        try {
            log.info("开始计算取件地址到仓库的距离...");
            
            // 解析取件地址
            LocationDto pickupLocation = googleMapsUtils.parseLocationFromJson(pickupAddress);
            if (pickupLocation == null) {
                log.error("取件地址解析失败: {}", pickupAddress);
                return null;
            }
            
            log.info("取件地址: {}", pickupLocation.getFormattedAddress());
            
            // 获取所有活跃的仓库
            QueryWrapper<RfWarehouse> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("status", "ENABLED"); // 只查询活跃状态的仓库
            
            List<RfWarehouse> warehouses = rfWarehouseService.list(queryWrapper);
            
            if (warehouses.isEmpty()) {
                log.warn("没有找到可用的仓库");
                return null;
            }
            
            log.info("找到 {} 个可用仓库", warehouses.size());
            
            // 存储距离结果
            RfWarehouse nearestWarehouse = null;
            DistanceResult shortestDistance = null;
            
            // 逐个计算距离
            for (RfWarehouse warehouse : warehouses) {
                LocationDto warehouseLocation = googleMapsUtils.parseLocationFromJson(warehouse.getAddress());
                if (warehouseLocation == null) {
                    log.warn("仓库 {} 地址解析失败: {}", warehouse.getName(), warehouse.getAddress());
                    continue;
                }
                
                // 计算驾驶距离
                DistanceResult distanceResult = googleMapsUtils.calculateDistance(pickupLocation, warehouseLocation);
                
                if ("OK".equals(distanceResult.getStatus())) {
                    log.info("仓库: {} | 地址: {} | 距离: {} | 时间: {}", 
                        warehouse.getName(),
                        warehouseLocation.getFormattedAddress(),
                        distanceResult.getDistanceText(),
                        distanceResult.getDurationText()
                    );
                    
                    // 更新最短距离
                    if (shortestDistance == null || 
                        distanceResult.getDistanceInMeters() < shortestDistance.getDistanceInMeters()) {
                        shortestDistance = distanceResult;
                        nearestWarehouse = warehouse;
                    }
                } else {
                    log.warn("计算距离失败 - 仓库: {} | 状态: {}", warehouse.getName(), distanceResult.getStatus());
                }
            }
            
            // 输出最短距离的仓库
            if (nearestWarehouse != null && shortestDistance != null) {
                log.info("==================== 距离计算结果 ====================");
                log.info("最近仓库: {}", nearestWarehouse.getName());
                log.info("仓库地址: {}", googleMapsUtils.parseLocationFromJson(nearestWarehouse.getAddress()).getFormattedAddress());
                log.info("最短距离: {}", shortestDistance.getDistanceText());
                log.info("预计时间: {}", shortestDistance.getDurationText());
                log.info("距离(米): {}", shortestDistance.getDistanceInMeters());
                log.info("距离(公里): {}", String.format("%.2f", shortestDistance.getDistanceInKilometers()));
                log.info("==================================================");
            } else {
                log.warn("没有成功计算出任何仓库的距离");
            }
            
            return nearestWarehouse;
            
        } catch (Exception e) {
            log.error("计算仓库距离时发生错误: {}", e.getMessage(), e);
            return null;
        }
    }
    
    /**
     * 创建内部物流任务
     * 
     * @param productId 商品ID
     * @param sourceAddress 源地址（取件地址）
     * @param targetAddress 目标地址（仓库地址）
     * @return 内部物流任务实体
     */
    private RfInternalLogisticsTask createInternalLogisticsTask(Long productId, Long productConsignmentRecordId, String sourceAddress, String targetAddress) {
        RfInternalLogisticsTask task = new RfInternalLogisticsTask();
        
        // 设置基本信息
        task.setProductId(productId);
        task.setProductConsignmentRecordId(productConsignmentRecordId); // 寄卖记录ID
        task.setTaskType("PICKUP_SERVICE"); // 任务类型：上门取货
        task.setSourceAddress(sourceAddress); // 源地址：取件地址
        task.setTargetAddress(targetAddress); // 目标地址：仓库地址
        task.setStatus("PENDING_ACCEPT"); // 状态：待接受
        
        // 设置时间
        LocalDateTime now = LocalDateTime.now();
        task.setCreateTime(now);
        task.setUpdateTime(now);
        task.setIsDelete(false);
        
        log.info("创建内部物流任务 - 类型: {} | 状态: {} | 源地址: {} | 目标地址: {}", 
            task.getTaskType(), task.getStatus(), sourceAddress, targetAddress);
            
        return task;
    }

    @Override
    public List<RfProductSellRecord> getMySales(int page, int size) {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 构建查询条件
        LambdaQueryWrapper<RfProductSellRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfProductSellRecord::getSellerUserId, userId)
                   .orderByDesc(RfProductSellRecord::getCreateTime);

        // 分页查询
        Page<RfProductSellRecord> pageParam = new Page<>(page, size);
        Page<RfProductSellRecord> result = rfProductSellRecordMapper.selectPage(pageParam, queryWrapper);

        // 获取销售记录列表
        List<RfProductSellRecord> records = result.getRecords();

        // 填充商品信息
        for (RfProductSellRecord record : records) {
            RfProduct product = rfProductService.getById(record.getProductId());
            if (product != null) {
                record.setProduct(product);
            }
        }

        return records;
    }

    @Override
    public SysUserStripeAccount getStripeAccountInfo() {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 查询用户的Stripe账户信息
        LambdaQueryWrapper<SysUserStripeAccount> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SysUserStripeAccount::getUserId, userId)
                   .eq(SysUserStripeAccount::getIsDelete, false);

        return sysUserStripeAccountMapper.selectOne(queryWrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> createStripeAccount() {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 检查是否已经存在Stripe账户
        SysUserStripeAccount existingAccount = getStripeAccountInfo();
        if (existingAccount != null) {
            throw new RuntimeException("Stripe account already exists for this user");
        }

        try {
            // 调用Stripe API创建Express账户
            AccountCreateParams params = AccountCreateParams.builder()
                .setType(AccountCreateParams.Type.EXPRESS)
                .setCountry("HK") // 设置为香港，您可以根据需要调整
                .setCapabilities(
                    AccountCreateParams.Capabilities.builder()
                        .setCardPayments(
                            AccountCreateParams.Capabilities.CardPayments.builder()
                                .setRequested(true)
                                .build())
                        .setTransfers(
                            AccountCreateParams.Capabilities.Transfers.builder()
                                .setRequested(true)
                                .build())
                        .build())
                .build();

            Account account = Account.create(params);
            
            // 创建账户链接
            AccountLinkCreateParams linkParams = AccountLinkCreateParams.builder()
                .setAccount(account.getId())
                .setRefreshUrl(stripeConnectRefreshUrl)
                .setReturnUrl(stripeConnectReturnUrl)
                .setType(AccountLinkCreateParams.Type.ACCOUNT_ONBOARDING)
                .setCollect(AccountLinkCreateParams.Collect.EVENTUALLY_DUE)
                .build();

            AccountLink accountLink = AccountLink.create(linkParams);

            // 创建数据库记录
            SysUserStripeAccount stripeAccount = new SysUserStripeAccount();
            stripeAccount.setUserId(userId);
            stripeAccount.setStripeAccountId(account.getId());
            stripeAccount.setAccountStatus("pending");
            stripeAccount.setVerificationStatus("unverified");
            stripeAccount.setAccountLinkUrl(accountLink.getUrl());
            stripeAccount.setLinkExpiresAt(LocalDateTime.now().plusHours(24)); // 链接24小时后过期
            stripeAccount.setCanReceivePayments(false);
            stripeAccount.setCanMakeTransfers(false);
            
            // 保存capabilities为JSON
            try {
                stripeAccount.setCapabilitiesJson(objectMapper.writeValueAsString(account.getCapabilities()));
            } catch (JsonProcessingException e) {
                log.warn("Failed to serialize capabilities: {}", e.getMessage());
                stripeAccount.setCapabilitiesJson("{}");
            }
            
            stripeAccount.setCreateTime(LocalDateTime.now());
            stripeAccount.setUpdateTime(LocalDateTime.now());
            stripeAccount.setIsDelete(false);

            // 保存到数据库
            int result = sysUserStripeAccountMapper.insert(stripeAccount);
            if (result <= 0) {
                throw new RuntimeException("Failed to save Stripe account to database");
            }

            log.info("Stripe账户创建成功 - 用户ID: {} | Stripe账户ID: {}", userId, account.getId());

            // 返回结果
            Map<String, Object> response = new HashMap<>();
            response.put("stripeAccountId", account.getId());
            response.put("accountLinkUrl", accountLink.getUrl());
            response.put("accountStatus", "pending");
            response.put("message", "Please complete account setup via the provided link");

            return response;

        } catch (Exception e) {
            log.error("创建Stripe账户失败 - 用户ID: {}", userId, e);
            throw new RuntimeException("Failed to create Stripe account: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> refreshStripeAccountLink() {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 获取现有的Stripe账户
        SysUserStripeAccount existingAccount = getStripeAccountInfo();
        if (existingAccount == null) {
            throw new RuntimeException("No Stripe account found for this user");
        }

        try {
            // 调用Stripe API刷新账户链接
            AccountLinkCreateParams linkParams = AccountLinkCreateParams.builder()
                .setAccount(existingAccount.getStripeAccountId())
                .setRefreshUrl(stripeConnectRefreshUrl)
                .setReturnUrl(stripeConnectReturnUrl)
                .setType(AccountLinkCreateParams.Type.ACCOUNT_ONBOARDING)
                .setCollect(AccountLinkCreateParams.Collect.EVENTUALLY_DUE)
                .build();

            AccountLink accountLink = AccountLink.create(linkParams);

            // 更新数据库记录
            existingAccount.setAccountLinkUrl(accountLink.getUrl());
            existingAccount.setLinkExpiresAt(LocalDateTime.now().plusHours(24));
            existingAccount.setUpdateTime(LocalDateTime.now());

            int result = sysUserStripeAccountMapper.updateById(existingAccount);
            if (result <= 0) {
                throw new RuntimeException("Failed to update account link in database");
            }

            log.info("Stripe账户链接刷新成功 - 用户ID: {} | Stripe账户ID: {}", userId, existingAccount.getStripeAccountId());

            // 返回结果
            Map<String, Object> response = new HashMap<>();
            response.put("stripeAccountId", existingAccount.getStripeAccountId());
            response.put("accountLinkUrl", accountLink.getUrl());
            response.put("accountStatus", existingAccount.getAccountStatus());
            response.put("message", "Account link refreshed successfully");

            return response;

        } catch (Exception e) {
            log.error("刷新Stripe账户链接失败 - 用户ID: {}", userId, e);
            throw new RuntimeException("Failed to refresh account link: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysUserStripeAccount syncStripeAccountStatus() {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 获取现有的Stripe账户
        SysUserStripeAccount existingAccount = getStripeAccountInfo();
        if (existingAccount == null) {
            throw new RuntimeException("No Stripe account found for this user");
        }

        try {
            // 调用Stripe API获取账户最新状态
            Account account = Account.retrieve(existingAccount.getStripeAccountId());
            
            // 更新账户状态
            existingAccount.setAccountStatus(account.getChargesEnabled() ? "active" : "pending");
            existingAccount.setVerificationStatus(account.getDetailsSubmitted() ? "verified" : "pending");
            existingAccount.setCanReceivePayments(account.getChargesEnabled());
            existingAccount.setCanMakeTransfers(account.getPayoutsEnabled());
            existingAccount.setLastSyncTime(LocalDateTime.now());
            existingAccount.setUpdateTime(LocalDateTime.now());

            // 更新capabilities为JSON
            try {
                existingAccount.setCapabilitiesJson(objectMapper.writeValueAsString(account.getCapabilities()));
            } catch (JsonProcessingException e) {
                log.warn("Failed to serialize capabilities: {}", e.getMessage());
            }

            // 更新requirements为JSON
            try {
                existingAccount.setRequirementsJson(objectMapper.writeValueAsString(account.getRequirements()));
            } catch (JsonProcessingException e) {
                log.warn("Failed to serialize requirements: {}", e.getMessage());
            }

            // 更新到数据库
            int result = sysUserStripeAccountMapper.updateById(existingAccount);
            if (result <= 0) {
                throw new RuntimeException("Failed to update account status in database");
            }

            log.info("Stripe账户状态同步成功 - 用户ID: {} | 状态: {} | 验证状态: {} | 可收款: {} | 可转账: {}", 
                userId, existingAccount.getAccountStatus(), existingAccount.getVerificationStatus(),
                existingAccount.getCanReceivePayments(), existingAccount.getCanMakeTransfers());

            return existingAccount;

        } catch (Exception e) {
            log.error("同步Stripe账户状态失败 - 用户ID: {}", userId, e);
            throw new RuntimeException("Failed to sync account status: " + e.getMessage());
        }
    }

    @Override
    public Map<String, Object> getReturnRequestDetail(Long sellRecordId) {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 查询销售记录
        RfProductSellRecord sellRecord = rfProductSellRecordMapper.selectById(sellRecordId);
        if (sellRecord == null) {
            throw new RuntimeException("Sell record not found");
        }

        // 验证是否为当前用户的销售记录
        if (!userId.equals(sellRecord.getSellerUserId())) {
            throw new RuntimeException("Access denied: Not your sell record");
        }

        // 查询退货记录
        LambdaQueryWrapper<RfProductReturnRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfProductReturnRecord::getProductSellRecordId, sellRecordId)
                   .eq(RfProductReturnRecord::getIsDelete, false);

        RfProductReturnRecord returnRecord = rfProductReturnRecordMapper.selectOne(queryWrapper);
        if (returnRecord == null) {
            throw new RuntimeException("Return request not found");
        }

        // 查询商品信息
        RfProduct product = rfProductService.getById(returnRecord.getProductId());

        // 构建返回结果
        Map<String, Object> result = new HashMap<>();
        result.put("productSellRecordId", sellRecordId);
        result.put("returnReasonType", returnRecord.getReturnReasonType());
        result.put("returnReasonDetail", returnRecord.getReturnReasonDetail());
        result.put("pickupAddress", returnRecord.getPickupAddress());
        result.put("product", product);
        result.put("sellRecord", sellRecord);
        result.put("returnRecord", returnRecord);

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean handleReturnRequest(Long sellRecordId, boolean accept, String sellerOpinion) {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 查询销售记录
        RfProductSellRecord sellRecord = rfProductSellRecordMapper.selectById(sellRecordId);
        if (sellRecord == null) {
            throw new RuntimeException("Sell record not found");
        }

        // 验证是否为当前用户的销售记录
        if (!userId.equals(sellRecord.getSellerUserId())) {
            throw new RuntimeException("Access denied: Not your sell record");
        }

        // 查询退货记录
        LambdaQueryWrapper<RfProductReturnRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfProductReturnRecord::getProductSellRecordId, sellRecordId)
                   .eq(RfProductReturnRecord::getIsDelete, false);

        RfProductReturnRecord returnRecord = rfProductReturnRecordMapper.selectOne(queryWrapper);
        if (returnRecord == null) {
            throw new RuntimeException("Return request not found");
        }

        // 处理拒绝退货的情况
        if (!accept) {
            try {
                // 更新退货记录
                returnRecord.setSellerAcceptReturn(false);
                returnRecord.setSellerOpinionDetail(sellerOpinion);
                returnRecord.setStatus("RETURN_NEGOTIATION_FAILED");
                returnRecord.setUpdateTime(LocalDateTime.now());

                // 更新销售记录状态
                sellRecord.setStatus("RETURN_NEGOTIATION_FAILED");
                sellRecord.setUpdateTime(LocalDateTime.now());

                // 更新数据库
                rfProductReturnRecordMapper.updateById(returnRecord);
                rfProductSellRecordMapper.updateById(sellRecord);

                log.info("卖家拒绝退货申请处理完成 - 销售记录ID: {} | 卖家意见: {}", sellRecordId, sellerOpinion);
                return true;

            } catch (Exception e) {
                log.error("处理拒绝退货申请失败 - 销售记录ID: {}", sellRecordId, e);
                throw new RuntimeException("Failed to handle reject return request: " + e.getMessage());
            }
        }

        // 同意退货的处理逻辑
        try {
            // 更新退货记录
            returnRecord.setSellerAcceptReturn(true);
            returnRecord.setSellerOpinionDetail(sellerOpinion);
            returnRecord.setAuditResult("APPROVED");
            returnRecord.setFreightBearer("SELLER");
            returnRecord.setNeedCompensateProduct(false);
            returnRecord.setUpdateTime(LocalDateTime.now());

            // 查询商品信息判断是否为寄卖商品
            RfProduct product = rfProductService.getById(returnRecord.getProductId());
            if (product == null) {
                throw new RuntimeException("Product not found");
            }

            boolean isConsignment = Boolean.TRUE.equals(sellRecord.getIsAuction());

            if (isConsignment) {
                // 寄卖商品：退回仓库
                sellRecord.setStatus("RETURNED_TO_WAREHOUSE");
                returnRecord.setStatus("RETURNED_TO_WAREHOUSE");

                // 创建内部物流任务
                createReturnLogisticsTask(returnRecord, product);

                log.info("寄卖商品退货处理完成 - 销售记录ID: {} | 状态: RETURNED_TO_WAREHOUSE", sellRecordId);
            } else {
                // 非寄卖商品：退回卖家
                sellRecord.setStatus("RETURNED_TO_SELLER");
                returnRecord.setStatus("RETURNED_TO_SELLER");

                log.info("非寄卖商品退货处理完成 - 销售记录ID: {} | 状态: RETURNED_TO_SELLER", sellRecordId);
            }

            // 更新销售记录和退货记录
            sellRecord.setUpdateTime(LocalDateTime.now());
            rfProductSellRecordMapper.updateById(sellRecord);
            rfProductReturnRecordMapper.updateById(returnRecord);

            log.info("退货申请处理成功 - 销售记录ID: {} | 是否寄卖: {} | 卖家意见: {}", 
                sellRecordId, isConsignment, sellerOpinion);

            return true;

        } catch (Exception e) {
            log.error("处理退货申请失败 - 销售记录ID: {}", sellRecordId, e);
            throw new RuntimeException("Failed to handle return request: " + e.getMessage());
        }
    }

    /**
     * 创建退货物流任务（寄卖商品退回仓库）
     */
    private void createReturnLogisticsTask(RfProductReturnRecord returnRecord, RfProduct product) {
        try {
            // 获取仓库信息
            RfWarehouse warehouse = null;
            if (product.getWarehouseId() != null) {
                warehouse = rfWarehouseService.getById(product.getWarehouseId());
            }

            if (warehouse == null) {
                log.warn("未找到商品对应的仓库信息 - 商品ID: {}", product.getId());
                return;
            }

            // 创建内部物流任务
            RfInternalLogisticsTask logisticsTask = new RfInternalLogisticsTask();
            logisticsTask.setProductId(returnRecord.getProductId());
            logisticsTask.setProductSellRecordId(returnRecord.getProductSellRecordId());
            logisticsTask.setProductReturnRecordId(returnRecord.getId());
            logisticsTask.setTaskType("PRODUCT_RETURN");
            logisticsTask.setSourceAddress(returnRecord.getPickupAddress()); // 取货地址
            logisticsTask.setTargetAddress(warehouse.getAddress()); // 仓库地址
            logisticsTask.setStatus("PENDING_ACCEPT");
            logisticsTask.setCreateTime(LocalDateTime.now());
            logisticsTask.setUpdateTime(LocalDateTime.now());
            logisticsTask.setIsDelete(false);

            // 保存物流任务
            boolean taskSaved = rfInternalLogisticsTaskService.save(logisticsTask);
            if (taskSaved) {
                // 更新退货记录中的物流任务ID
                returnRecord.setInternalLogisticsTaskId(logisticsTask.getId());
                log.info("创建退货物流任务成功 - 任务ID: {} | 起点: {} | 终点: {}", 
                    logisticsTask.getId(), returnRecord.getPickupAddress(), warehouse.getAddress());
            } else {
                log.error("保存退货物流任务失败");
            }

        } catch (Exception e) {
            log.error("创建退货物流任务失败", e);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean confirmReturnReceived(Long sellRecordId) {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 查询销售记录
        RfProductSellRecord sellRecord = rfProductSellRecordMapper.selectById(sellRecordId);
        if (sellRecord == null) {
            throw new RuntimeException("Sell record not found");
        }

        // 验证是否为当前用户的销售记录
        if (!userId.equals(sellRecord.getSellerUserId())) {
            throw new RuntimeException("Access denied: Not your sell record");
        }

        // 验证当前状态是否为RETURNED_TO_SELLER
        if (!"RETURNED_TO_SELLER".equals(sellRecord.getStatus())) {
            throw new RuntimeException("Invalid status: Can only confirm receipt for items with status RETURNED_TO_SELLER");
        }

        // 查询对应的退货记录
        LambdaQueryWrapper<RfProductReturnRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfProductReturnRecord::getProductSellRecordId, sellRecordId)
                   .eq(RfProductReturnRecord::getIsDelete, false);

        RfProductReturnRecord returnRecord = rfProductReturnRecordMapper.selectOne(queryWrapper);
        if (returnRecord == null) {
            throw new RuntimeException("Return record not found");
        }

        try {
            // 更新销售记录状态
            sellRecord.setStatus("RETURN_COMPLETED");
            sellRecord.setUpdateTime(LocalDateTime.now());

            // 更新退货记录状态
            returnRecord.setStatus("RETURN_COMPLETED");
            returnRecord.setUpdateTime(LocalDateTime.now());

            // 更新到数据库
            int sellRecordResult = rfProductSellRecordMapper.updateById(sellRecord);
            int returnRecordResult = rfProductReturnRecordMapper.updateById(returnRecord);

            if (sellRecordResult > 0 && returnRecordResult > 0) {
                log.info("卖家确认收到退货完成 - 销售记录ID: {} | 用户ID: {}", sellRecordId, userId);
                return true;
            } else {
                throw new RuntimeException("Failed to update records in database");
            }

        } catch (Exception e) {
            log.error("确认收到退货失败 - 销售记录ID: {} | 用户ID: {}", sellRecordId, userId, e);
            throw new RuntimeException("Failed to confirm return received: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean requestReturnToSeller(Long productId, String returnAddress) {
        // 获取当前用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User not authenticated");
        }

        // 查询商品信息
        RfProduct product = rfProductService.getById(productId);
        if (product == null) {
            throw new RuntimeException("Product not found");
        }

        // 验证是否为当前用户的商品
        if (!userId.equals(product.getUserId())) {
            throw new RuntimeException("Access denied: Not your product");
        }

        // 验证商品状态和类型
        if (!"LISTED".equals(product.getStatus()) || !Boolean.TRUE.equals(product.getIsAuction())) {
            throw new RuntimeException("Invalid product status: Only listed consignment products can be returned");
        }

        try {
            // 更新商品状态为RETURNED_TO_SELLER
            product.setStatus("RETURNED_TO_SELLER");
            product.setUpdateTime(LocalDateTime.now());
            boolean productUpdated = rfProductService.updateById(product);
            if (!productUpdated) {
                throw new RuntimeException("Failed to update product status");
            }

            // 创建商品退回卖家记录
            RfProductReturnToSeller returnToSellerRecord = createReturnToSellerRecord(product, returnAddress);
            
            // 创建内部物流任务
            createReturnToSellerLogisticsTask(returnToSellerRecord, product);

            log.info("商品退回卖家申请成功 - 商品ID: {} | 用户ID: {} | 退回地址: {}", 
                productId, userId, returnAddress);

            return true;

        } catch (Exception e) {
            log.error("商品退回卖家申请失败 - 商品ID: {} | 用户ID: {}", productId, userId, e);
            throw new RuntimeException("Failed to request return to seller: " + e.getMessage());
        }
    }

    /**
     * 创建商品退回卖家记录
     */
    private RfProductReturnToSeller createReturnToSellerRecord(RfProduct product, String returnAddress) {
        RfProductReturnToSeller returnToSeller = new RfProductReturnToSeller();
        
        // 基本信息
        returnToSeller.setProductId(product.getId());
        returnToSeller.setWarehouseId(product.getWarehouseId());
        returnToSeller.setSellerReceiptAddress(returnAddress);
        
        // 获取仓库地址
        if (product.getWarehouseId() != null) {
            RfWarehouse warehouse = rfWarehouseService.getById(product.getWarehouseId());
            if (warehouse != null) {
                returnToSeller.setWarehouseAddress(warehouse.getAddress());
            }
        }
        
        // 状态和时间
        returnToSeller.setStatus("PENDING_SHIPMENT");
        returnToSeller.setCreateTime(LocalDateTime.now());
        returnToSeller.setUpdateTime(LocalDateTime.now());
        returnToSeller.setIsDelete(false);
        
        // 保存记录到数据库
        boolean saved = rfProductReturnToSellerService.save(returnToSeller);
        if (!saved) {
            throw new RuntimeException("Failed to save return to seller record");
        }
        
        log.info("创建商品退回卖家记录成功 - 记录ID: {} | 商品ID: {} | 仓库ID: {} | 退回地址: {}", 
            returnToSeller.getId(), product.getId(), product.getWarehouseId(), returnAddress);
        
        return returnToSeller;
    }

    /**
     * 创建退回卖家的内部物流任务
     */
    private void createReturnToSellerLogisticsTask(RfProductReturnToSeller returnToSeller, RfProduct product) {
        try {
            RfInternalLogisticsTask logisticsTask = new RfInternalLogisticsTask();
            
            // 基本信息
            logisticsTask.setProductId(product.getId());
            logisticsTask.setProductReturnToSellerRecordId(returnToSeller.getId()); // 设置退回卖家记录ID
            logisticsTask.setTaskType("RETURN_TO_SELLER");
            logisticsTask.setSourceAddress(returnToSeller.getWarehouseAddress()); // 起点：仓库地址
            logisticsTask.setTargetAddress(returnToSeller.getSellerReceiptAddress()); // 终点：卖家收货地址
            logisticsTask.setStatus("PENDING_ACCEPT");
            
            // 时间信息
            logisticsTask.setCreateTime(LocalDateTime.now());
            logisticsTask.setUpdateTime(LocalDateTime.now());
            logisticsTask.setIsDelete(false);
            
            // 保存物流任务
            boolean taskSaved = rfInternalLogisticsTaskService.save(logisticsTask);
            if (taskSaved) {
                // 更新退回记录中的物流任务ID
                returnToSeller.setInternalLogisticsTaskId(logisticsTask.getId());
                boolean updated = rfProductReturnToSellerService.updateById(returnToSeller);
                if (!updated) {
                    log.warn("更新退回卖家记录的物流任务ID失败 - 记录ID: {}", returnToSeller.getId());
                }
                
                log.info("创建退回卖家物流任务成功 - 任务ID: {} | 记录ID: {} | 起点: {} | 终点: {}", 
                    logisticsTask.getId(), returnToSeller.getId(), returnToSeller.getWarehouseAddress(), returnToSeller.getSellerReceiptAddress());
            } else {
                log.error("保存退回卖家物流任务失败");
                throw new RuntimeException("Failed to save return to seller logistics task");
            }
            
        } catch (Exception e) {
            log.error("创建退回卖家物流任务失败", e);
            throw new RuntimeException("Failed to create return to seller logistics task: " + e.getMessage(), e);
        }
    }
} 