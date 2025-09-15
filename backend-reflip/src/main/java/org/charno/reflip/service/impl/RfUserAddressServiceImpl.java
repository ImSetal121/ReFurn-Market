package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfUserAddress;
import org.charno.reflip.mapper.RfUserAddressMapper;
import org.charno.reflip.service.IRfUserAddressService;
import java.util.List;

/**
 * 用户地址业务实现类
 */
@Service
public class RfUserAddressServiceImpl extends ServiceImpl<RfUserAddressMapper, RfUserAddress> implements IRfUserAddressService {

    @Override
    public Page<RfUserAddress> selectPageWithCondition(Page<RfUserAddress> page, RfUserAddress condition) {
        LambdaQueryWrapper<RfUserAddress> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(RfUserAddress::getUserId, condition.getUserId());
            }
            if (condition.getReceiverName() != null && !condition.getReceiverName().isEmpty()) {
                queryWrapper.like(RfUserAddress::getReceiverName, condition.getReceiverName());
            }
            if (condition.getReceiverPhone() != null && !condition.getReceiverPhone().isEmpty()) {
                queryWrapper.like(RfUserAddress::getReceiverPhone, condition.getReceiverPhone());
            }
            if (condition.getRegion() != null && !condition.getRegion().isEmpty()) {
                queryWrapper.like(RfUserAddress::getRegion, condition.getRegion());
            }
            if (condition.getIsDefault() != null) {
                queryWrapper.eq(RfUserAddress::getIsDefault, condition.getIsDefault());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfUserAddress> selectListWithCondition(RfUserAddress condition) {
        LambdaQueryWrapper<RfUserAddress> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(RfUserAddress::getUserId, condition.getUserId());
            }
            if (condition.getReceiverName() != null && !condition.getReceiverName().isEmpty()) {
                queryWrapper.like(RfUserAddress::getReceiverName, condition.getReceiverName());
            }
            if (condition.getReceiverPhone() != null && !condition.getReceiverPhone().isEmpty()) {
                queryWrapper.like(RfUserAddress::getReceiverPhone, condition.getReceiverPhone());
            }

            if (condition.getRegion() != null && !condition.getRegion().isEmpty()) {
                queryWrapper.like(RfUserAddress::getRegion, condition.getRegion());
            }
            if (condition.getIsDefault() != null) {
                queryWrapper.eq(RfUserAddress::getIsDefault, condition.getIsDefault());
            }
        }
        
        return this.list(queryWrapper);
    }
} 