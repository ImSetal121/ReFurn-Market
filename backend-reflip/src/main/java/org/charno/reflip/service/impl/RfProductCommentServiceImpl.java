package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductComment;
import org.charno.reflip.mapper.RfProductCommentMapper;
import org.charno.reflip.service.IRfProductCommentService;
import java.util.List;

/**
 * 商品留言业务实现类
 */
@Service
public class RfProductCommentServiceImpl extends ServiceImpl<RfProductCommentMapper, RfProductComment> implements IRfProductCommentService {

    @Override
    public Page<RfProductComment> selectPageWithCondition(Page<RfProductComment> page, RfProductComment condition) {
        LambdaQueryWrapper<RfProductComment> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductComment::getProductId, condition.getProductId());
            }
            if (condition.getCommenterUserId() != null) {
                queryWrapper.eq(RfProductComment::getCommenterUserId, condition.getCommenterUserId());
            }
            if (condition.getCommentContent() != null && !condition.getCommentContent().isEmpty()) {
                queryWrapper.like(RfProductComment::getCommentContent, condition.getCommentContent());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductComment> selectListWithCondition(RfProductComment condition) {
        LambdaQueryWrapper<RfProductComment> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductComment::getProductId, condition.getProductId());
            }
            if (condition.getCommenterUserId() != null) {
                queryWrapper.eq(RfProductComment::getCommenterUserId, condition.getCommenterUserId());
            }
            if (condition.getCommentContent() != null && !condition.getCommentContent().isEmpty()) {
                queryWrapper.like(RfProductComment::getCommentContent, condition.getCommentContent());
            }
        }
        
        return this.list(queryWrapper);
    }
} 