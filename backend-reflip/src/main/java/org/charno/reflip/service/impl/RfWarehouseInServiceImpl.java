package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfWarehouseIn;
import org.charno.reflip.mapper.RfWarehouseInMapper;
import org.charno.reflip.service.IRfWarehouseInService;
import java.util.List;

/**
 * 仓库入库业务实现类
 */
@Service
public class RfWarehouseInServiceImpl extends ServiceImpl<RfWarehouseInMapper, RfWarehouseIn> implements IRfWarehouseInService {

    @Override
    public Page<RfWarehouseIn> selectPageWithCondition(Page<RfWarehouseIn> page, RfWarehouseIn condition) {
        LambdaQueryWrapper<RfWarehouseIn> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseIn::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseIn::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfWarehouseIn::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getStockPosition() != null && !condition.getStockPosition().isEmpty()) {
                queryWrapper.like(RfWarehouseIn::getStockPosition, condition.getStockPosition());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfWarehouseIn> selectListWithCondition(RfWarehouseIn condition) {
        LambdaQueryWrapper<RfWarehouseIn> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseIn::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseIn::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfWarehouseIn::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getStockPosition() != null && !condition.getStockPosition().isEmpty()) {
                queryWrapper.like(RfWarehouseIn::getStockPosition, condition.getStockPosition());
            }
        }
        
        return this.list(queryWrapper);
    }
} 