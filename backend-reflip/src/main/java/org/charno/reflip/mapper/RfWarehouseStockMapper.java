package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfWarehouseStock;

/**
 * 仓库库存数据访问层
 */
@Mapper
public interface RfWarehouseStockMapper extends BaseMapper<RfWarehouseStock> {
} 