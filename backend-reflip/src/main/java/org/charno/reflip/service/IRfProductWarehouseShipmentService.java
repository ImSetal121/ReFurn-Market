package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductWarehouseShipment;
import java.util.List;

/**
 * 商品仓库发货业务接口
 */
public interface IRfProductWarehouseShipmentService extends IBaseService<RfProductWarehouseShipment> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductWarehouseShipment> selectPageWithCondition(Page<RfProductWarehouseShipment> page, RfProductWarehouseShipment condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductWarehouseShipment> selectListWithCondition(RfProductWarehouseShipment condition);
} 