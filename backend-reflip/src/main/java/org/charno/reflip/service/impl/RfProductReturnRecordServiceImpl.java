package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductReturnRecord;
import org.charno.reflip.mapper.RfProductReturnRecordMapper;
import org.charno.reflip.service.IRfProductReturnRecordService;
import java.util.List;

/**
 * 商品退货记录业务实现类
 */
@Service
public class RfProductReturnRecordServiceImpl extends ServiceImpl<RfProductReturnRecordMapper, RfProductReturnRecord> implements IRfProductReturnRecordService {

    @Override
    public Page<RfProductReturnRecord> selectPageWithCondition(Page<RfProductReturnRecord> page, RfProductReturnRecord condition) {
        LambdaQueryWrapper<RfProductReturnRecord> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductReturnRecord::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductReturnRecord::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getReturnReasonType() != null && !condition.getReturnReasonType().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getReturnReasonType, condition.getReturnReasonType());
            }
            if (condition.getAuditResult() != null && !condition.getAuditResult().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getAuditResult, condition.getAuditResult());
            }
            if (condition.getFreightBearer() != null && !condition.getFreightBearer().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getFreightBearer, condition.getFreightBearer());
            }
            if (condition.getCompensationBearer() != null && !condition.getCompensationBearer().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getCompensationBearer, condition.getCompensationBearer());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductReturnRecord> selectListWithCondition(RfProductReturnRecord condition) {
        LambdaQueryWrapper<RfProductReturnRecord> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductReturnRecord::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfProductReturnRecord::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getReturnReasonType() != null && !condition.getReturnReasonType().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getReturnReasonType, condition.getReturnReasonType());
            }
            if (condition.getAuditResult() != null && !condition.getAuditResult().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getAuditResult, condition.getAuditResult());
            }
            if (condition.getFreightBearer() != null && !condition.getFreightBearer().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getFreightBearer, condition.getFreightBearer());
            }
            if (condition.getCompensationBearer() != null && !condition.getCompensationBearer().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getCompensationBearer, condition.getCompensationBearer());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductReturnRecord::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
    
    @Override
    public RfProductReturnRecord getByProductSellRecordId(Long productSellRecordId) {
        if (productSellRecordId == null) {
            return null;
        }
        
        LambdaQueryWrapper<RfProductReturnRecord> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfProductReturnRecord::getProductSellRecordId, productSellRecordId);
        
        return this.getOne(queryWrapper);
    }
} 