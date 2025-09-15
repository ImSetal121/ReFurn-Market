package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfWarehouseOut;
import java.util.List;

/**
 * 仓库出库业务接口
 */
public interface IRfWarehouseOutService extends IBaseService<RfWarehouseOut> {
    
    /**
     * 分页条件查询
     */
    Page<RfWarehouseOut> selectPageWithCondition(Page<RfWarehouseOut> page, RfWarehouseOut condition);
    
    /**
     * 不分页条件查询
     */
    List<RfWarehouseOut> selectListWithCondition(RfWarehouseOut condition);
} 