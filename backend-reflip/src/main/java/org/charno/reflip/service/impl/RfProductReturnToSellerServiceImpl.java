package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductReturnToSeller;
import org.charno.reflip.mapper.RfProductReturnToSellerMapper;
import org.charno.reflip.service.IRfProductReturnToSellerService;
import java.util.List;

/**
 * 商品退回卖家记录业务实现类
 */
@Service
public class RfProductReturnToSellerServiceImpl extends ServiceImpl<RfProductReturnToSellerMapper, RfProductReturnToSeller> implements IRfProductReturnToSellerService {

    @Override
    public Page<RfProductReturnToSeller> selectPageWithCondition(Page<RfProductReturnToSeller> page, RfProductReturnToSeller condition) {
        LambdaQueryWrapper<RfProductReturnToSeller> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getInternalLogisticsTaskId() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getInternalLogisticsTaskId, condition.getInternalLogisticsTaskId());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductReturnToSeller::getStatus, condition.getStatus());
            }
            if (condition.getShipmentTime() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getShipmentTime, condition.getShipmentTime());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductReturnToSeller> selectListWithCondition(RfProductReturnToSeller condition) {
        LambdaQueryWrapper<RfProductReturnToSeller> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getInternalLogisticsTaskId() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getInternalLogisticsTaskId, condition.getInternalLogisticsTaskId());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductReturnToSeller::getStatus, condition.getStatus());
            }
            if (condition.getShipmentTime() != null) {
                queryWrapper.eq(RfProductReturnToSeller::getShipmentTime, condition.getShipmentTime());
            }
        }
        
        return this.list(queryWrapper);
    }
} 