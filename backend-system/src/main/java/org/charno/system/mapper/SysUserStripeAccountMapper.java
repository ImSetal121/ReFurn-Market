package org.charno.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.common.entity.SysUserStripeAccount;

/**
 * 用户Stripe Express账户数据访问层
 */
@Mapper
public interface SysUserStripeAccountMapper extends BaseMapper<SysUserStripeAccount> {
} 