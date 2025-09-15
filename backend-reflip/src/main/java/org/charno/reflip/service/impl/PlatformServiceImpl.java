package org.charno.reflip.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.charno.reflip.dto.AuditReturnRequestDto;
import org.charno.reflip.entity.RfProductReturnRecord;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.reflip.service.IPlatformService;
import org.charno.reflip.service.IRfProductReturnRecordService;
import org.charno.reflip.service.IRfProductSellRecordService;
import org.charno.reflip.service.IRfProductService;
import org.charno.reflip.service.IRfWarehouseService;
import org.charno.reflip.service.IRfInternalLogisticsTaskService;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.entity.RfWarehouse;
import org.charno.reflip.entity.RfInternalLogisticsTask;
import lombok.extern.slf4j.Slf4j;
import java.time.LocalDateTime;

/**
 * 平台管理服务实现类
 */
@Slf4j
@Service
public class PlatformServiceImpl implements IPlatformService {
    
    @Autowired
    private IRfProductReturnRecordService returnRecordService;
    
    @Autowired
    private IRfProductSellRecordService sellRecordService;
    
    @Autowired
    private IRfProductService productService;
    
    @Autowired
    private IRfWarehouseService warehouseService;
    
    @Autowired
    private IRfInternalLogisticsTaskService internalLogisticsTaskService;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean auditReturnRequest(AuditReturnRequestDto auditRequest) {
        // 1. 获取退货记录
        RfProductReturnRecord returnRecord = returnRecordService.getById(auditRequest.getReturnRecordId());
        if (returnRecord == null) {
            throw new RuntimeException("退货记录不存在");
        }
        
        // 2. 获取销售记录，用于获取买家和卖家ID
        RfProductSellRecord sellRecord = sellRecordService.getById(returnRecord.getProductSellRecordId());
        if (sellRecord == null) {
            throw new RuntimeException("销售记录不存在");
        }
        
        // 3. 更新退货记录
        returnRecord.setAuditResult(auditRequest.getAuditResult());
        returnRecord.setAuditDetail(auditRequest.getAuditDetail());
        returnRecord.setFreightBearer(auditRequest.getFreightBearer());
        returnRecord.setNeedCompensateProduct(auditRequest.getNeedCompensateProduct());
        
        // 4. 根据运费承担方设置运费承担用户ID
        setFreightBearerUserId(returnRecord, sellRecord, auditRequest.getFreightBearer());
        
        // 5. 根据赔偿承担方设置赔偿承担用户ID
        if (auditRequest.getNeedCompensateProduct() != null && auditRequest.getNeedCompensateProduct()) {
            returnRecord.setCompensationBearer(auditRequest.getCompensationBearer());
            setCompensationBearerUserId(returnRecord, sellRecord, auditRequest.getCompensationBearer());
        } else {
            returnRecord.setCompensationBearer(null);
            returnRecord.setCompensationBearerUserId(null);
        }
        
        // 6. 根据审核结果更新状态
        if ("APPROVED".equals(auditRequest.getAuditResult())) {
            // 审核通过，需要根据商品类型设置不同状态
            handleApprovedReturn(returnRecord, sellRecord);
        } else if ("REJECTED".equals(auditRequest.getAuditResult())) {
            // 审核拒绝，直接完成退货流程
            returnRecord.setStatus("RETURN_COMPLETED");
            sellRecord.setStatus("RETURN_COMPLETED");
        }
        
        // 7. 保存更新
        boolean returnRecordUpdated = returnRecordService.updateById(returnRecord);
        boolean sellRecordUpdated = sellRecordService.updateById(sellRecord);
        
        return returnRecordUpdated && sellRecordUpdated;
    }
    
    /**
     * 根据运费承担方设置运费承担用户ID
     */
    private void setFreightBearerUserId(RfProductReturnRecord returnRecord, RfProductSellRecord sellRecord, String freightBearer) {
        switch (freightBearer) {
            case "SELLER":
                returnRecord.setFreightBearerUserId(sellRecord.getSellerUserId());
                break;
            case "BUYER":
                returnRecord.setFreightBearerUserId(sellRecord.getBuyerUserId());
                break;
            case "PLATFORM":
                returnRecord.setFreightBearerUserId(null); // 平台承担，不设置具体用户ID
                break;
            default:
                throw new IllegalArgumentException("无效的运费承担方: " + freightBearer);
        }
    }
    
    /**
     * 根据赔偿承担方设置赔偿承担用户ID
     */
    private void setCompensationBearerUserId(RfProductReturnRecord returnRecord, RfProductSellRecord sellRecord, String compensationBearer) {
        switch (compensationBearer) {
            case "SELLER":
                returnRecord.setCompensationBearerUserId(sellRecord.getSellerUserId());
                break;
            case "BUYER":
                returnRecord.setCompensationBearerUserId(sellRecord.getBuyerUserId());
                break;
            case "PLATFORM":
                returnRecord.setCompensationBearerUserId(null); // 平台承担，不设置具体用户ID
                break;
            default:
                throw new IllegalArgumentException("无效的赔偿承担方: " + compensationBearer);
        }
    }
    
    /**
     * 处理审核通过的退货申请
     */
    private void handleApprovedReturn(RfProductReturnRecord returnRecord, RfProductSellRecord sellRecord) {
        try {
            // 获取商品信息判断是否为寄卖商品
            RfProduct product = productService.getById(returnRecord.getProductId());
            if (product == null) {
                throw new RuntimeException("商品不存在");
            }

            // 判断是否为寄卖商品（通过销售记录的isAuction字段判断）
            boolean isConsignment = Boolean.TRUE.equals(sellRecord.getIsAuction());

            if (isConsignment) {
                // 寄卖商品：退回仓库
                returnRecord.setStatus("RETURNED_TO_WAREHOUSE");
                sellRecord.setStatus("RETURNED_TO_WAREHOUSE");

                // 创建退货物流任务
                createReturnLogisticsTask(returnRecord, product);

                log.info("寄卖商品退货审批通过 - 退货记录ID: {} | 状态: RETURNED_TO_WAREHOUSE", returnRecord.getId());
            } else {
                // 非寄卖商品：退回卖家
                returnRecord.setStatus("RETURNED_TO_SELLER");
                sellRecord.setStatus("RETURNED_TO_SELLER");

                log.info("非寄卖商品退货审批通过 - 退货记录ID: {} | 状态: RETURNED_TO_SELLER", returnRecord.getId());
            }

        } catch (Exception e) {
            log.error("处理审核通过的退货申请失败 - 退货记录ID: {}", returnRecord.getId(), e);
            throw new RuntimeException("处理审核通过失败: " + e.getMessage());
        }
    }
    
    /**
     * 创建退货物流任务（寄卖商品退回仓库）
     * 参考SellerServiceImpl中的实现
     */
    private void createReturnLogisticsTask(RfProductReturnRecord returnRecord, RfProduct product) {
        try {
            // 获取仓库信息
            RfWarehouse warehouse = null;
            if (product.getWarehouseId() != null) {
                warehouse = warehouseService.getById(product.getWarehouseId());
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
            boolean taskSaved = internalLogisticsTaskService.save(logisticsTask);
            if (taskSaved) {
                // 更新退货记录中的物流任务ID
                returnRecord.setInternalLogisticsTaskId(logisticsTask.getId());
                log.info("创建退货物流任务成功 - 任务ID: {} | 起点: {} | 终点: {}", 
                    logisticsTask.getId(), returnRecord.getPickupAddress(), warehouse.getAddress());
            } else {
                log.error("保存退货物流任务失败");
            }

        } catch (Exception e) {
            log.error("创建退货物流任务失败 - 退货记录ID: {}", returnRecord.getId(), e);
        }
    }
} 