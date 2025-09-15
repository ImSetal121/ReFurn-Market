package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfProductReturnRecord;

/**
 * 商品退货记录数据访问层
 */
@Mapper
public interface RfProductReturnRecordMapper extends BaseMapper<RfProductReturnRecord> {
} 