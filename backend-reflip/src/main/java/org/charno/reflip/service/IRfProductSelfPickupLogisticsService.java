package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductSelfPickupLogistics;
import java.util.List;

/**
 * 商品自提物流业务接口
 */
public interface IRfProductSelfPickupLogisticsService extends IBaseService<RfProductSelfPickupLogistics> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductSelfPickupLogistics> selectPageWithCondition(Page<RfProductSelfPickupLogistics> page, RfProductSelfPickupLogistics condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductSelfPickupLogistics> selectListWithCondition(RfProductSelfPickupLogistics condition);
} 