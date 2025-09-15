package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfWarehouseInApply;
import java.util.List;

/**
 * 仓库入库申请业务接口
 */
public interface IRfWarehouseInApplyService extends IBaseService<RfWarehouseInApply> {
    
    /**
     * 分页条件查询
     */
    Page<RfWarehouseInApply> selectPageWithCondition(Page<RfWarehouseInApply> page, RfWarehouseInApply condition);
    
    /**
     * 不分页条件查询
     */
    List<RfWarehouseInApply> selectListWithCondition(RfWarehouseInApply condition);
} 