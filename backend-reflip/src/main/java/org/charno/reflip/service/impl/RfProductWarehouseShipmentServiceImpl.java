package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductWarehouseShipment;
import org.charno.reflip.mapper.RfProductWarehouseShipmentMapper;
import org.charno.reflip.service.IRfProductWarehouseShipmentService;
import java.util.List;

/**
 * 商品仓库发货业务实现类
 */
@Service
public class RfProductWarehouseShipmentServiceImpl extends ServiceImpl<RfProductWarehouseShipmentMapper, RfProductWarehouseShipment> implements IRfProductWarehouseShipmentService {

    @Override
    public Page<RfProductWarehouseShipment> selectPageWithCondition(Page<RfProductWarehouseShipment> page, RfProductWarehouseShipment condition) {
        LambdaQueryWrapper<RfProductWarehouseShipment> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductWarehouseShipment::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductWarehouseShipment::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfProductWarehouseShipment::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getWarehouseAddress() != null && !condition.getWarehouseAddress().isEmpty()) {
                queryWrapper.like(RfProductWarehouseShipment::getWarehouseAddress, condition.getWarehouseAddress());
            }
            if (condition.getBuyerReceiptAddress() != null && !condition.getBuyerReceiptAddress().isEmpty()) {
                queryWrapper.like(RfProductWarehouseShipment::getBuyerReceiptAddress, condition.getBuyerReceiptAddress());
            }
            if (condition.getInternalLogisticsTaskId() != null) {
                queryWrapper.eq(RfProductWarehouseShipment::getInternalLogisticsTaskId, condition.getInternalLogisticsTaskId());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductWarehouseShipment::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductWarehouseShipment> selectListWithCondition(RfProductWarehouseShipment condition) {
        LambdaQueryWrapper<RfProductWarehouseShipment> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductWarehouseShipment::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductWarehouseShipment::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfProductWarehouseShipment::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getWarehouseAddress() != null && !condition.getWarehouseAddress().isEmpty()) {
                queryWrapper.like(RfProductWarehouseShipment::getWarehouseAddress, condition.getWarehouseAddress());
            }
            if (condition.getBuyerReceiptAddress() != null && !condition.getBuyerReceiptAddress().isEmpty()) {
                queryWrapper.like(RfProductWarehouseShipment::getBuyerReceiptAddress, condition.getBuyerReceiptAddress());
            }
            if (condition.getInternalLogisticsTaskId() != null) {
                queryWrapper.eq(RfProductWarehouseShipment::getInternalLogisticsTaskId, condition.getInternalLogisticsTaskId());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductWarehouseShipment::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 