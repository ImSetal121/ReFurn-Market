package org.charno.system.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.common.entity.SysUserStripeAccount;
import java.util.List;

/**
 * 用户Stripe Express账户业务接口
 */
public interface ISysUserStripeAccountService extends IBaseService<SysUserStripeAccount> {
    
    /**
     * 分页条件查询
     */
    Page<SysUserStripeAccount> selectPageWithCondition(Page<SysUserStripeAccount> page, SysUserStripeAccount condition);
    
    /**
     * 不分页条件查询
     */
    List<SysUserStripeAccount> selectListWithCondition(SysUserStripeAccount condition);
    
    /**
     * 根据用户ID查询账户信息
     */
    SysUserStripeAccount getByUserId(Integer userId);
    
    /**
     * 根据Stripe账户ID查询
     */
    SysUserStripeAccount getByStripeAccountId(String stripeAccountId);
} 