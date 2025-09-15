package org.charno.reflip.service.impl;

import org.charno.reflip.dto.PickupRequestDTO;
import org.charno.reflip.dto.DeliveryRequestDTO;
import org.charno.reflip.dto.AcceptTaskRequestDTO;
import org.charno.reflip.service.CourierService;
import org.charno.reflip.service.IRfInternalLogisticsTaskService;
import org.charno.reflip.service.IRfProductAuctionLogisticsService;
import org.charno.reflip.service.IRfProductService;
import org.charno.reflip.service.IRfProductSellRecordService;
import org.charno.reflip.service.IRfProductReturnRecordService;
import org.charno.reflip.service.IRfProductReturnToSellerService;
import org.charno.reflip.service.IWarehouseService;
import org.charno.reflip.entity.RfInternalLogisticsTask;
import org.charno.reflip.entity.RfProductAuctionLogistics;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.reflip.entity.RfProductReturnRecord;
import org.charno.reflip.entity.RfProductReturnToSeller;
import org.charno.common.utils.SecurityUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CourierServiceImpl implements CourierService {

    @Autowired
    private IRfInternalLogisticsTaskService rfInternalLogisticsTaskService;
    
    @Autowired
    private IRfProductAuctionLogisticsService rfProductAuctionLogisticsService;
    
    @Autowired
    private IRfProductService rfProductService;
    
    @Autowired
    private IRfProductSellRecordService rfProductSellRecordService;
    
    @Autowired
    private IRfProductReturnRecordService rfProductReturnRecordService;
    
    @Autowired
    private IRfProductReturnToSellerService rfProductReturnToSellerService;
    
    @Autowired
    private IWarehouseService warehouseService;
    
    @Autowired
    private ObjectMapper objectMapper;

    @Override
    @Transactional
    public boolean acceptTask(AcceptTaskRequestDTO request) {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return false;
        }

        // 获取任务信息
        RfInternalLogisticsTask task = rfInternalLogisticsTaskService.getById(request.getTaskId());
        if (task == null || !"PENDING_ACCEPT".equals(task.getStatus())) {
            return false;
        }

        // 检查是否已经有其他快递员接单
        if (task.getLogisticsUserId() != null) {
            return false;
        }

        // 更新任务状态和物流员ID
        task.setStatus("PENDING_PICKUP");
        task.setLogisticsUserId(userId);
        
        return rfInternalLogisticsTaskService.updateById(task);
    }

    @Override
    @Transactional
    public boolean handlePickup(PickupRequestDTO request) {
        try {
            // 获取当前登录用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return false;
            }

            // 获取任务信息
            RfInternalLogisticsTask task = rfInternalLogisticsTaskService.getById(request.getTaskId());
            if (task == null || !"PENDING_PICKUP".equals(task.getStatus())) {
                return false;
            }

            // 验证是否为当前用户的任务
            if (!userId.equals(task.getLogisticsUserId())) {
                return false;
            }

            // 根据任务类型处理不同的业务逻辑
            switch (task.getTaskType()) {
                case "PICKUP_SERVICE":
                    return handlePickupService(task, request);
                case "WAREHOUSE_SHIPMENT":
                    return handleWarehouseShipmentPickup(task, request);
                case "PRODUCT_RETURN":
                    return handleProductReturnPickup(task, request);
                case "RETURN_TO_SELLER":
                    return handleReturnToSellerPickup(task, request);
                default:
                    return false;
            }
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 处理取货服务类型的取货
     */
    private boolean handlePickupService(RfInternalLogisticsTask task, PickupRequestDTO request) {
        try {
            // 将图片URL集合转换为JSON字符串
            String imageUrlJson = objectMapper.writeValueAsString(request.getImageUrls());
            
            // 更新内部物流任务
            task.setSourceAddressImageUrlJson(imageUrlJson);
            task.setStatus("PENDING_RECEIPT");
            
            boolean taskUpdated = rfInternalLogisticsTaskService.updateById(task);
            if (!taskUpdated) {
                return false;
            }

            // 如果有关联的商品寄售记录，更新其状态
            if (task.getProductConsignmentRecordId() != null) {
                RfProductAuctionLogistics auctionLogistics = rfProductAuctionLogisticsService.getById(task.getProductConsignmentRecordId());
                if (auctionLogistics != null) {
                    auctionLogistics.setStatus("PENDING_WAREHOUSING");
                    rfProductAuctionLogisticsService.updateById(auctionLogistics);
                }
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    @Transactional
    public boolean handleDelivery(DeliveryRequestDTO request) {
        try {
            // 获取当前登录用户ID
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return false;
            }

            // 获取任务信息
            RfInternalLogisticsTask task = rfInternalLogisticsTaskService.getById(request.getTaskId());
            if (task == null || !"PENDING_RECEIPT".equals(task.getStatus())) {
                return false;
            }

            // 验证是否为当前用户的任务
            if (!userId.equals(task.getLogisticsUserId())) {
                return false;
            }

            // 根据任务类型处理不同的业务逻辑
            switch (task.getTaskType()) {
                case "PICKUP_SERVICE":
                    return handleDeliveryService(task, request);
                case "WAREHOUSE_SHIPMENT":
                    return handleWarehouseShipmentDelivery(task, request);
                case "PRODUCT_RETURN":
                    return handleProductReturnDelivery(task, request);
                case "RETURN_TO_SELLER":
                    return handleReturnToSellerDelivery(task, request);
                default:
                    return false;
            }
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 处理取货服务类型的送达
     */
    private boolean handleDeliveryService(RfInternalLogisticsTask task, DeliveryRequestDTO request) {
        try {
            // 将图片URL集合转换为JSON字符串
            String imageUrlJson = objectMapper.writeValueAsString(request.getImageUrls());
            
            // 更新内部物流任务
            task.setTargetAddressImageUrlJson(imageUrlJson);
            task.setStatus("COMPLETED");
            
            boolean taskUpdated = rfInternalLogisticsTaskService.updateById(task);
            if (!taskUpdated) {
                return false;
            }

            // 如果有关联的商品寄售记录，更新其状态
            if (task.getProductConsignmentRecordId() != null) {
                RfProductAuctionLogistics auctionLogistics = rfProductAuctionLogisticsService.getById(task.getProductConsignmentRecordId());
                if (auctionLogistics != null) {
                    auctionLogistics.setStatus("WAREHOUSED");
                    rfProductAuctionLogisticsService.updateById(auctionLogistics);
                }
            }

            // 根据productId更新商品状态
            if (task.getProductId() != null) {
                RfProduct product = rfProductService.getById(task.getProductId());
                if (product != null) {
                    product.setStatus("LISTED");
                    rfProductService.updateById(product);

                    // 商品入库
                    boolean warehouseInResult = warehouseService.warehouseIn(task.getProductId(), "PICKUP_SERVICE");
                    if (!warehouseInResult) {
                        // 入库失败，记录日志但不影响主流程
                        // 可以考虑添加日志记录
                    }
                }
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 处理仓库发货类型的取货
     */
    private boolean handleWarehouseShipmentPickup(RfInternalLogisticsTask task, PickupRequestDTO request) {
        try {
            // 将图片URL集合转换为JSON字符串
            String imageUrlJson = objectMapper.writeValueAsString(request.getImageUrls());
            
            // 更新内部物流任务
            task.setSourceAddressImageUrlJson(imageUrlJson);
            task.setStatus("PENDING_RECEIPT");
            
            boolean taskUpdated = rfInternalLogisticsTaskService.updateById(task);
            if (!taskUpdated) {
                return false;
            }

            // 更新关联的销售记录状态
            if (task.getProductSellRecordId() != null) {
                RfProductSellRecord sellRecord = rfProductSellRecordService.getById(task.getProductSellRecordId());
                if (sellRecord != null) {
                    sellRecord.setStatus("PENDING_RECEIPT");
                    sellRecord.setInternalLogisticsTaskId(task.getId());
                    rfProductSellRecordService.updateById(sellRecord);
                }
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 处理仓库发货类型的送达
     */
    private boolean handleWarehouseShipmentDelivery(RfInternalLogisticsTask task, DeliveryRequestDTO request) {
        try {
            // 将图片URL集合转换为JSON字符串
            String imageUrlJson = objectMapper.writeValueAsString(request.getImageUrls());
            
            // 更新内部物流任务
            task.setTargetAddressImageUrlJson(imageUrlJson);
            task.setStatus("COMPLETED");
            
            boolean taskUpdated = rfInternalLogisticsTaskService.updateById(task);
            if (!taskUpdated) {
                return false;
            }

            // 更新关联的销售记录状态
            if (task.getProductSellRecordId() != null) {
                RfProductSellRecord sellRecord = rfProductSellRecordService.getById(task.getProductSellRecordId());
                if (sellRecord != null) {
                    sellRecord.setStatus("DELIVERED");
                    rfProductSellRecordService.updateById(sellRecord);
                }
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 处理商品退货类型的取货
     */
    private boolean handleProductReturnPickup(RfInternalLogisticsTask task, PickupRequestDTO request) {
        try {
            // 将图片URL集合转换为JSON字符串
            String imageUrlJson = objectMapper.writeValueAsString(request.getImageUrls());
            
            // 更新内部物流任务
            task.setSourceAddressImageUrlJson(imageUrlJson);
            task.setStatus("PENDING_RECEIPT");
            
            return rfInternalLogisticsTaskService.updateById(task);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 处理商品退货类型的送达
     */
    private boolean handleProductReturnDelivery(RfInternalLogisticsTask task, DeliveryRequestDTO request) {
        try {
            // 将图片URL集合转换为JSON字符串
            String imageUrlJson = objectMapper.writeValueAsString(request.getImageUrls());
            
            // 更新内部物流任务
            task.setTargetAddressImageUrlJson(imageUrlJson);
            task.setStatus("COMPLETED");
            
            boolean taskUpdated = rfInternalLogisticsTaskService.updateById(task);
            if (!taskUpdated) {
                return false;
            }

            // 更新关联的销售记录状态
            if (task.getProductSellRecordId() != null) {
                RfProductSellRecord sellRecord = rfProductSellRecordService.getById(task.getProductSellRecordId());
                if (sellRecord != null) {
                    sellRecord.setStatus("RETURNED_TO_WAREHOUSE_CONFIRMED");
                    boolean sellRecordUpdated = rfProductSellRecordService.updateById(sellRecord);
                    if (!sellRecordUpdated) {
                        return false;
                    }

                    // 通过销售记录ID查找对应的退货记录并更新状态
                    RfProductReturnRecord returnRecord = rfProductReturnRecordService.getByProductSellRecordId(task.getProductSellRecordId());
                    if (returnRecord != null) {
                        returnRecord.setStatus("RETURNED_TO_WAREHOUSE_CONFIRMED");
                        boolean returnRecordUpdated = rfProductReturnRecordService.updateById(returnRecord);
                        if (!returnRecordUpdated) {
                            return false;
                        }
                    }
                }
            }

            // 更新商品状态为LISTED，使其重新上架
            if (task.getProductId() != null) {
                RfProduct product = rfProductService.getById(task.getProductId());
                if (product != null) {
                    product.setStatus("LISTED");
                    boolean productUpdated = rfProductService.updateById(product);
                    if (!productUpdated) {
                        return false;
                    }
                }
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 处理退回卖家类型的取货
     */
    private boolean handleReturnToSellerPickup(RfInternalLogisticsTask task, PickupRequestDTO request) {
        try {
            // 将图片URL集合转换为JSON字符串
            String imageUrlJson = objectMapper.writeValueAsString(request.getImageUrls());
            
            // 更新内部物流任务
            task.setSourceAddressImageUrlJson(imageUrlJson);
            task.setStatus("PENDING_RECEIPT");
            
            boolean taskUpdated = rfInternalLogisticsTaskService.updateById(task);
            if (!taskUpdated) {
                return false;
            }

            // 更新关联的退回卖家记录状态为SHIPPED
            if (task.getProductReturnToSellerRecordId() != null) {
                RfProductReturnToSeller returnToSellerRecord = rfProductReturnToSellerService.getById(task.getProductReturnToSellerRecordId());
                if (returnToSellerRecord != null) {
                    returnToSellerRecord.setStatus("SHIPPED");
                    boolean recordUpdated = rfProductReturnToSellerService.updateById(returnToSellerRecord);
                    if (!recordUpdated) {
                        return false;
                    }
                }
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 处理退回卖家类型的送达
     */
    private boolean handleReturnToSellerDelivery(RfInternalLogisticsTask task, DeliveryRequestDTO request) {
        try {
            // 将图片URL集合转换为JSON字符串
            String imageUrlJson = objectMapper.writeValueAsString(request.getImageUrls());
            
            // 更新内部物流任务
            task.setTargetAddressImageUrlJson(imageUrlJson);
            task.setStatus("COMPLETED");
            
            boolean taskUpdated = rfInternalLogisticsTaskService.updateById(task);
            if (!taskUpdated) {
                return false;
            }

            // 更新关联的退回卖家记录状态为RECEIVED
            if (task.getProductReturnToSellerRecordId() != null) {
                RfProductReturnToSeller returnToSellerRecord = rfProductReturnToSellerService.getById(task.getProductReturnToSellerRecordId());
                if (returnToSellerRecord != null) {
                    returnToSellerRecord.setStatus("RECEIVED");
                    boolean recordUpdated = rfProductReturnToSellerService.updateById(returnToSellerRecord);
                    if (!recordUpdated) {
                        return false;
                    }
                }
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }
} 