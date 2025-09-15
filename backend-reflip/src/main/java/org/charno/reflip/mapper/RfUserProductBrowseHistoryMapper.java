package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfUserProductBrowseHistory;

/**
 * 用户商品浏览记录数据访问层
 */
@Mapper
public interface RfUserProductBrowseHistoryMapper extends BaseMapper<RfUserProductBrowseHistory> {
}