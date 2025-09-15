package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfWarehouseCost;
import org.charno.reflip.mapper.RfWarehouseCostMapper;
import org.charno.reflip.service.IRfWarehouseCostService;
import java.util.List;

/**
 * 仓库费用业务实现类
 */
@Service
public class RfWarehouseCostServiceImpl extends ServiceImpl<RfWarehouseCostMapper, RfWarehouseCost> implements IRfWarehouseCostService {

    @Override
    public Page<RfWarehouseCost> selectPageWithCondition(Page<RfWarehouseCost> page, RfWarehouseCost condition) {
        LambdaQueryWrapper<RfWarehouseCost> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseCost::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseCost::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfWarehouseCost::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getCostType() != null && !condition.getCostType().isEmpty()) {
                queryWrapper.eq(RfWarehouseCost::getCostType, condition.getCostType());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfWarehouseCost> selectListWithCondition(RfWarehouseCost condition) {
        LambdaQueryWrapper<RfWarehouseCost> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseCost::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseCost::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfWarehouseCost::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getCostType() != null && !condition.getCostType().isEmpty()) {
                queryWrapper.eq(RfWarehouseCost::getCostType, condition.getCostType());
            }
        }
        
        return this.list(queryWrapper);
    }
} 