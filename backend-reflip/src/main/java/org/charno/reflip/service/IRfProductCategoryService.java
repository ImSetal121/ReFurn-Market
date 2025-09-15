package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductCategory;
import java.util.List;

/**
 * 商品分类业务接口
 */
public interface IRfProductCategoryService extends IBaseService<RfProductCategory> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductCategory> selectPageWithCondition(Page<RfProductCategory> page, RfProductCategory condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductCategory> selectListWithCondition(RfProductCategory condition);
} 