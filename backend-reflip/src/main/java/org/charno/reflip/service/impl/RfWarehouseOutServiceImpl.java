package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfWarehouseOut;
import org.charno.reflip.mapper.RfWarehouseOutMapper;
import org.charno.reflip.service.IRfWarehouseOutService;
import java.util.List;

/**
 * 仓库出库业务实现类
 */
@Service
public class RfWarehouseOutServiceImpl extends ServiceImpl<RfWarehouseOutMapper, RfWarehouseOut> implements IRfWarehouseOutService {

    @Override
    public Page<RfWarehouseOut> selectPageWithCondition(Page<RfWarehouseOut> page, RfWarehouseOut condition) {
        LambdaQueryWrapper<RfWarehouseOut> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseOut::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseOut::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfWarehouseOut::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getStockPosition() != null && !condition.getStockPosition().isEmpty()) {
                queryWrapper.like(RfWarehouseOut::getStockPosition, condition.getStockPosition());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfWarehouseOut> selectListWithCondition(RfWarehouseOut condition) {
        LambdaQueryWrapper<RfWarehouseOut> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseOut::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseOut::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfWarehouseOut::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getStockPosition() != null && !condition.getStockPosition().isEmpty()) {
                queryWrapper.like(RfWarehouseOut::getStockPosition, condition.getStockPosition());
            }
        }
        
        return this.list(queryWrapper);
    }
} 