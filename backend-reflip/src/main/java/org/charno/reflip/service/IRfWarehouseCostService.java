package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfWarehouseCost;
import java.util.List;

/**
 * 仓库费用业务接口
 */
public interface IRfWarehouseCostService extends IBaseService<RfWarehouseCost> {
    
    /**
     * 分页条件查询
     */
    Page<RfWarehouseCost> selectPageWithCondition(Page<RfWarehouseCost> page, RfWarehouseCost condition);
    
    /**
     * 不分页条件查询
     */
    List<RfWarehouseCost> selectListWithCondition(RfWarehouseCost condition);
} 