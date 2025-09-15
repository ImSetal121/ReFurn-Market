package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductAuctionLogistics;
import org.charno.reflip.mapper.RfProductAuctionLogisticsMapper;
import org.charno.reflip.service.IRfProductAuctionLogisticsService;
import java.util.List;

/**
 * 商品拍卖物流业务实现类
 */
@Service
public class RfProductAuctionLogisticsServiceImpl extends ServiceImpl<RfProductAuctionLogisticsMapper, RfProductAuctionLogistics> implements IRfProductAuctionLogisticsService {

    @Override
    public Page<RfProductAuctionLogistics> selectPageWithCondition(Page<RfProductAuctionLogistics> page, RfProductAuctionLogistics condition) {
        LambdaQueryWrapper<RfProductAuctionLogistics> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductAuctionLogistics::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductAuctionLogistics::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfProductAuctionLogistics::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getPickupAddress() != null && !condition.getPickupAddress().isEmpty()) {
                queryWrapper.like(RfProductAuctionLogistics::getPickupAddress, condition.getPickupAddress());
            }
            if (condition.getWarehouseAddress() != null && !condition.getWarehouseAddress().isEmpty()) {
                queryWrapper.like(RfProductAuctionLogistics::getWarehouseAddress, condition.getWarehouseAddress());
            }
            if (condition.getExternalLogisticsServiceName() != null && !condition.getExternalLogisticsServiceName().isEmpty()) {
                queryWrapper.like(RfProductAuctionLogistics::getExternalLogisticsServiceName, condition.getExternalLogisticsServiceName());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductAuctionLogistics::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductAuctionLogistics> selectListWithCondition(RfProductAuctionLogistics condition) {
        LambdaQueryWrapper<RfProductAuctionLogistics> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductAuctionLogistics::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductAuctionLogistics::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfProductAuctionLogistics::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getPickupAddress() != null && !condition.getPickupAddress().isEmpty()) {
                queryWrapper.like(RfProductAuctionLogistics::getPickupAddress, condition.getPickupAddress());
            }
            if (condition.getWarehouseAddress() != null && !condition.getWarehouseAddress().isEmpty()) {
                queryWrapper.like(RfProductAuctionLogistics::getWarehouseAddress, condition.getWarehouseAddress());
            }
            if (condition.getExternalLogisticsServiceName() != null && !condition.getExternalLogisticsServiceName().isEmpty()) {
                queryWrapper.like(RfProductAuctionLogistics::getExternalLogisticsServiceName, condition.getExternalLogisticsServiceName());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductAuctionLogistics::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 