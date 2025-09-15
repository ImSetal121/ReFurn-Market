package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfBillItem;

/**
 * 账单项数据访问层
 */
@Mapper
public interface RfBillItemMapper extends BaseMapper<RfBillItem> {
} 