package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductReturnToSeller;
import java.util.List;

/**
 * 商品退回卖家记录业务接口
 */
public interface IRfProductReturnToSellerService extends IBaseService<RfProductReturnToSeller> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductReturnToSeller> selectPageWithCondition(Page<RfProductReturnToSeller> page, RfProductReturnToSeller condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductReturnToSeller> selectListWithCondition(RfProductReturnToSeller condition);
} 