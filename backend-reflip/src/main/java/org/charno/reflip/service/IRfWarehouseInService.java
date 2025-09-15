package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfWarehouseIn;
import java.util.List;

/**
 * 仓库入库业务接口
 */
public interface IRfWarehouseInService extends IBaseService<RfWarehouseIn> {
    
    /**
     * 分页条件查询
     */
    Page<RfWarehouseIn> selectPageWithCondition(Page<RfWarehouseIn> page, RfWarehouseIn condition);
    
    /**
     * 不分页条件查询
     */
    List<RfWarehouseIn> selectListWithCondition(RfWarehouseIn condition);
} 