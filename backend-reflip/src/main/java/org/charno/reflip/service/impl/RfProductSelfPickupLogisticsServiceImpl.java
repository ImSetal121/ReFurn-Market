package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductSelfPickupLogistics;
import org.charno.reflip.mapper.RfProductSelfPickupLogisticsMapper;
import org.charno.reflip.service.IRfProductSelfPickupLogisticsService;
import java.util.List;

/**
 * 商品自提物流业务实现类
 */
@Service
public class RfProductSelfPickupLogisticsServiceImpl extends ServiceImpl<RfProductSelfPickupLogisticsMapper, RfProductSelfPickupLogistics> implements IRfProductSelfPickupLogisticsService {

    @Override
    public Page<RfProductSelfPickupLogistics> selectPageWithCondition(Page<RfProductSelfPickupLogistics> page, RfProductSelfPickupLogistics condition) {
        LambdaQueryWrapper<RfProductSelfPickupLogistics> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductSelfPickupLogistics::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductSelfPickupLogistics::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getPickupAddress() != null && !condition.getPickupAddress().isEmpty()) {
                queryWrapper.like(RfProductSelfPickupLogistics::getPickupAddress, condition.getPickupAddress());
            }
            if (condition.getBuyerReceiptAddress() != null && !condition.getBuyerReceiptAddress().isEmpty()) {
                queryWrapper.like(RfProductSelfPickupLogistics::getBuyerReceiptAddress, condition.getBuyerReceiptAddress());
            }
            if (condition.getExternalLogisticsServiceName() != null && !condition.getExternalLogisticsServiceName().isEmpty()) {
                queryWrapper.like(RfProductSelfPickupLogistics::getExternalLogisticsServiceName, condition.getExternalLogisticsServiceName());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductSelfPickupLogistics::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductSelfPickupLogistics> selectListWithCondition(RfProductSelfPickupLogistics condition) {
        LambdaQueryWrapper<RfProductSelfPickupLogistics> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductSelfPickupLogistics::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductSelfPickupLogistics::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getPickupAddress() != null && !condition.getPickupAddress().isEmpty()) {
                queryWrapper.like(RfProductSelfPickupLogistics::getPickupAddress, condition.getPickupAddress());
            }
            if (condition.getBuyerReceiptAddress() != null && !condition.getBuyerReceiptAddress().isEmpty()) {
                queryWrapper.like(RfProductSelfPickupLogistics::getBuyerReceiptAddress, condition.getBuyerReceiptAddress());
            }
            if (condition.getExternalLogisticsServiceName() != null && !condition.getExternalLogisticsServiceName().isEmpty()) {
                queryWrapper.like(RfProductSelfPickupLogistics::getExternalLogisticsServiceName, condition.getExternalLogisticsServiceName());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductSelfPickupLogistics::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 