package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfUserFavoriteProduct;

/**
 * 用户收藏商品数据访问层
 */
@Mapper
public interface RfUserFavoriteProductMapper extends BaseMapper<RfUserFavoriteProduct> {
}