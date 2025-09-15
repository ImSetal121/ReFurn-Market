package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProduct;
import java.util.List;

/**
 * 商品业务接口
 */
public interface IRfProductService extends IBaseService<RfProduct> {
    
    /**
     * 分页条件查询
     */
    Page<RfProduct> selectPageWithCondition(Page<RfProduct> page, RfProduct condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProduct> selectListWithCondition(RfProduct condition);
} 