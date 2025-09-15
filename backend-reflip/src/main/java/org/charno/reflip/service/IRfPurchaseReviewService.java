package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfPurchaseReview;
import java.util.List;

/**
 * 购买评价业务接口
 */
public interface IRfPurchaseReviewService extends IBaseService<RfPurchaseReview> {
    
    /**
     * 分页条件查询
     */
    Page<RfPurchaseReview> selectPageWithCondition(Page<RfPurchaseReview> page, RfPurchaseReview condition);
    
    /**
     * 不分页条件查询
     */
    List<RfPurchaseReview> selectListWithCondition(RfPurchaseReview condition);
} 