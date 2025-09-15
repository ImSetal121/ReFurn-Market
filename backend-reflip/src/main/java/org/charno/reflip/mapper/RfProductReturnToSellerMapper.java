package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfProductReturnToSeller;

/**
 * 商品退回卖家记录数据访问层
 */
@Mapper
public interface RfProductReturnToSellerMapper extends BaseMapper<RfProductReturnToSeller> {
} 