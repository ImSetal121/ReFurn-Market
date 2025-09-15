package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfWarehouseStock;
import org.charno.reflip.mapper.RfWarehouseStockMapper;
import org.charno.reflip.service.IRfWarehouseStockService;
import java.util.List;

/**
 * 仓库库存业务实现类
 */
@Service
public class RfWarehouseStockServiceImpl extends ServiceImpl<RfWarehouseStockMapper, RfWarehouseStock> implements IRfWarehouseStockService {

    @Override
    public Page<RfWarehouseStock> selectPageWithCondition(Page<RfWarehouseStock> page, RfWarehouseStock condition) {
        LambdaQueryWrapper<RfWarehouseStock> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseStock::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseStock::getProductId, condition.getProductId());
            }
            if (condition.getStockPosition() != null && !condition.getStockPosition().isEmpty()) {
                queryWrapper.like(RfWarehouseStock::getStockPosition, condition.getStockPosition());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfWarehouseStock::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfWarehouseStock> selectListWithCondition(RfWarehouseStock condition) {
        LambdaQueryWrapper<RfWarehouseStock> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseStock::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseStock::getProductId, condition.getProductId());
            }
            if (condition.getStockPosition() != null && !condition.getStockPosition().isEmpty()) {
                queryWrapper.like(RfWarehouseStock::getStockPosition, condition.getStockPosition());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfWarehouseStock::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 