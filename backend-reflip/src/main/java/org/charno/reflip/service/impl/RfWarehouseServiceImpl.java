package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfWarehouse;
import org.charno.reflip.mapper.RfWarehouseMapper;
import org.charno.reflip.service.IRfWarehouseService;
import java.util.List;

/**
 * 仓库业务实现类
 */
@Service
public class RfWarehouseServiceImpl extends ServiceImpl<RfWarehouseMapper, RfWarehouse> implements IRfWarehouseService {

    @Override
    public Page<RfWarehouse> selectPageWithCondition(Page<RfWarehouse> page, RfWarehouse condition) {
        LambdaQueryWrapper<RfWarehouse> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getName() != null && !condition.getName().isEmpty()) {
                queryWrapper.like(RfWarehouse::getName, condition.getName());
            }
            if (condition.getAddress() != null && !condition.getAddress().isEmpty()) {
                queryWrapper.like(RfWarehouse::getAddress, condition.getAddress());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfWarehouse::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfWarehouse> selectListWithCondition(RfWarehouse condition) {
        LambdaQueryWrapper<RfWarehouse> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getName() != null && !condition.getName().isEmpty()) {
                queryWrapper.like(RfWarehouse::getName, condition.getName());
            }
            if (condition.getAddress() != null && !condition.getAddress().isEmpty()) {
                queryWrapper.like(RfWarehouse::getAddress, condition.getAddress());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfWarehouse::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 