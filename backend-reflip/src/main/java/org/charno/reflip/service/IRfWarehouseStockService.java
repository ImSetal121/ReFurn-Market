package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfWarehouseStock;
import java.util.List;

/**
 * 仓库库存业务接口
 */
public interface IRfWarehouseStockService extends IBaseService<RfWarehouseStock> {
    
    /**
     * 分页条件查询
     */
    Page<RfWarehouseStock> selectPageWithCondition(Page<RfWarehouseStock> page, RfWarehouseStock condition);
    
    /**
     * 不分页条件查询
     */
    List<RfWarehouseStock> selectListWithCondition(RfWarehouseStock condition);
} 