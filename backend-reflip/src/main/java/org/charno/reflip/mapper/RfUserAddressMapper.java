package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfUserAddress;

/**
 * 用户地址数据访问层
 */
@Mapper
public interface RfUserAddressMapper extends BaseMapper<RfUserAddress> {
} 