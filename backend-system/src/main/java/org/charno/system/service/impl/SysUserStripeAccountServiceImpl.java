package org.charno.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.system.mapper.SysUserStripeAccountMapper;
import org.springframework.stereotype.Service;
import org.charno.common.entity.SysUserStripeAccount;
import org.charno.system.service.ISysUserStripeAccountService;
import java.util.List;

/**
 * 用户Stripe Express账户业务实现类
 */
@Service
public class SysUserStripeAccountServiceImpl extends ServiceImpl<SysUserStripeAccountMapper, SysUserStripeAccount> implements ISysUserStripeAccountService {

    @Override
    public Page<SysUserStripeAccount> selectPageWithCondition(Page<SysUserStripeAccount> page, SysUserStripeAccount condition) {
        LambdaQueryWrapper<SysUserStripeAccount> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(SysUserStripeAccount::getUserId, condition.getUserId());
            }
            if (condition.getStripeAccountId() != null && !condition.getStripeAccountId().isEmpty()) {
                queryWrapper.eq(SysUserStripeAccount::getStripeAccountId, condition.getStripeAccountId());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<SysUserStripeAccount> selectListWithCondition(SysUserStripeAccount condition) {
        LambdaQueryWrapper<SysUserStripeAccount> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(SysUserStripeAccount::getUserId, condition.getUserId());
            }
            if (condition.getStripeAccountId() != null && !condition.getStripeAccountId().isEmpty()) {
                queryWrapper.eq(SysUserStripeAccount::getStripeAccountId, condition.getStripeAccountId());
            }
        }
        
        return this.list(queryWrapper);
    }

    @Override
    public SysUserStripeAccount getByUserId(Integer userId) {
        if (userId == null) {
            return null;
        }
        
        LambdaQueryWrapper<SysUserStripeAccount> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SysUserStripeAccount::getUserId, userId);
        return this.getOne(queryWrapper);
    }

    @Override
    public SysUserStripeAccount getByStripeAccountId(String stripeAccountId) {
        if (stripeAccountId == null || stripeAccountId.isEmpty()) {
            return null;
        }
        
        LambdaQueryWrapper<SysUserStripeAccount> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SysUserStripeAccount::getStripeAccountId, stripeAccountId);
        return this.getOne(queryWrapper);
    }
} 