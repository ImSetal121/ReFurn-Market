package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfWarehouse;
import java.util.List;

/**
 * 仓库业务接口
 */
public interface IRfWarehouseService extends IBaseService<RfWarehouse> {
    
    /**
     * 分页条件查询
     */
    Page<RfWarehouse> selectPageWithCondition(Page<RfWarehouse> page, RfWarehouse condition);
    
    /**
     * 不分页条件查询
     */
    List<RfWarehouse> selectListWithCondition(RfWarehouse condition);
} 