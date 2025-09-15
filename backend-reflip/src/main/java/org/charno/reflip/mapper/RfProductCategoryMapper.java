package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfProductCategory;

/**
 * 商品分类数据访问层
 */
@Mapper
public interface RfProductCategoryMapper extends BaseMapper<RfProductCategory> {
} 