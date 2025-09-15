package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.mapper.RfProductMapper;
import org.charno.reflip.service.IRfProductService;
import java.util.List;

/**
 * 商品业务实现类
 */
@Service
public class RfProductServiceImpl extends ServiceImpl<RfProductMapper, RfProduct> implements IRfProductService {

    @Override
    public Page<RfProduct> selectPageWithCondition(Page<RfProduct> page, RfProduct condition) {
        LambdaQueryWrapper<RfProduct> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getName() != null && !condition.getName().isEmpty()) {
                queryWrapper.like(RfProduct::getName, condition.getName());
            }
            if (condition.getCategoryId() != null) {
                queryWrapper.eq(RfProduct::getCategoryId, condition.getCategoryId());
            }
            if (condition.getType() != null && !condition.getType().isEmpty()) {
                queryWrapper.like(RfProduct::getType, condition.getType());
            }
            if (condition.getIsAuction() != null) {
                queryWrapper.eq(RfProduct::getIsAuction, condition.getIsAuction());
            }
            if (condition.getIsSelfPickup() != null) {
                queryWrapper.eq(RfProduct::getIsSelfPickup, condition.getIsSelfPickup());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProduct::getStatus, condition.getStatus());
            }
        }
        
        // 添加排序条件，按创建时间倒序
        queryWrapper.orderByDesc(RfProduct::getCreateTime);
        
        // 执行分页查询
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProduct> selectListWithCondition(RfProduct condition) {
        LambdaQueryWrapper<RfProduct> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getName() != null && !condition.getName().isEmpty()) {
                queryWrapper.like(RfProduct::getName, condition.getName());
            }
            if (condition.getCategoryId() != null) {
                queryWrapper.eq(RfProduct::getCategoryId, condition.getCategoryId());
            }
            if (condition.getType() != null && !condition.getType().isEmpty()) {
                queryWrapper.like(RfProduct::getType, condition.getType());
            }
            if (condition.getIsAuction() != null) {
                queryWrapper.eq(RfProduct::getIsAuction, condition.getIsAuction());
            }
            if (condition.getIsSelfPickup() != null) {
                queryWrapper.eq(RfProduct::getIsSelfPickup, condition.getIsSelfPickup());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProduct::getStatus, condition.getStatus());
            }
        }
        
        // 添加排序条件，按创建时间倒序
        queryWrapper.orderByDesc(RfProduct::getCreateTime);
        
        return this.list(queryWrapper);
    }
} 