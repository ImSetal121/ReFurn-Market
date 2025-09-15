package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfWarehouseInApply;
import org.charno.reflip.mapper.RfWarehouseInApplyMapper;
import org.charno.reflip.service.IRfWarehouseInApplyService;
import java.util.List;

/**
 * 仓库入库申请业务实现类
 */
@Service
public class RfWarehouseInApplyServiceImpl extends ServiceImpl<RfWarehouseInApplyMapper, RfWarehouseInApply> implements IRfWarehouseInApplyService {

    @Override
    public Page<RfWarehouseInApply> selectPageWithCondition(Page<RfWarehouseInApply> page, RfWarehouseInApply condition) {
        LambdaQueryWrapper<RfWarehouseInApply> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseInApply::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseInApply::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfWarehouseInApply::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getSource() != null && !condition.getSource().isEmpty()) {
                queryWrapper.eq(RfWarehouseInApply::getSource, condition.getSource());
            }
            if (condition.getAuditResult() != null && !condition.getAuditResult().isEmpty()) {
                queryWrapper.eq(RfWarehouseInApply::getAuditResult, condition.getAuditResult());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfWarehouseInApply::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfWarehouseInApply> selectListWithCondition(RfWarehouseInApply condition) {
        LambdaQueryWrapper<RfWarehouseInApply> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getWarehouseId() != null) {
                queryWrapper.eq(RfWarehouseInApply::getWarehouseId, condition.getWarehouseId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfWarehouseInApply::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfWarehouseInApply::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getSource() != null && !condition.getSource().isEmpty()) {
                queryWrapper.eq(RfWarehouseInApply::getSource, condition.getSource());
            }
            if (condition.getAuditResult() != null && !condition.getAuditResult().isEmpty()) {
                queryWrapper.eq(RfWarehouseInApply::getAuditResult, condition.getAuditResult());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfWarehouseInApply::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 