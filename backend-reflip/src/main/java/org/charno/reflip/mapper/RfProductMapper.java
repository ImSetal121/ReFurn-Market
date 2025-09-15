package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfProduct;

/**
 * 商品数据访问层
 */
@Mapper
public interface RfProductMapper extends BaseMapper<RfProduct> {
} 