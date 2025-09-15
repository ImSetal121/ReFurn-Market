package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfPurchaseReview;
import org.charno.reflip.mapper.RfPurchaseReviewMapper;
import org.charno.reflip.service.IRfPurchaseReviewService;
import java.util.List;

/**
 * 购买评价业务实现类
 */
@Service
public class RfPurchaseReviewServiceImpl extends ServiceImpl<RfPurchaseReviewMapper, RfPurchaseReview> implements IRfPurchaseReviewService {

    @Override
    public Page<RfPurchaseReview> selectPageWithCondition(Page<RfPurchaseReview> page, RfPurchaseReview condition) {
        LambdaQueryWrapper<RfPurchaseReview> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfPurchaseReview::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfPurchaseReview::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getReviewerUserId() != null) {
                queryWrapper.eq(RfPurchaseReview::getReviewerUserId, condition.getReviewerUserId());
            }
            if (condition.getRating() != null) {
                queryWrapper.eq(RfPurchaseReview::getRating, condition.getRating());
            }
            if (condition.getReviewContent() != null && !condition.getReviewContent().isEmpty()) {
                queryWrapper.like(RfPurchaseReview::getReviewContent, condition.getReviewContent());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfPurchaseReview> selectListWithCondition(RfPurchaseReview condition) {
        LambdaQueryWrapper<RfPurchaseReview> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfPurchaseReview::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfPurchaseReview::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getReviewerUserId() != null) {
                queryWrapper.eq(RfPurchaseReview::getReviewerUserId, condition.getReviewerUserId());
            }
            if (condition.getRating() != null) {
                queryWrapper.eq(RfPurchaseReview::getRating, condition.getRating());
            }
            if (condition.getReviewContent() != null && !condition.getReviewContent().isEmpty()) {
                queryWrapper.like(RfPurchaseReview::getReviewContent, condition.getReviewContent());
            }
        }
        
        return this.list(queryWrapper);
    }
}