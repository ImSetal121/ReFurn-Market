package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfInternalLogisticsTask;
import org.charno.reflip.mapper.RfInternalLogisticsTaskMapper;
import org.charno.reflip.service.IRfInternalLogisticsTaskService;
import java.util.List;

/**
 * 内部物流任务业务实现类
 */
@Service
public class RfInternalLogisticsTaskServiceImpl extends ServiceImpl<RfInternalLogisticsTaskMapper, RfInternalLogisticsTask> implements IRfInternalLogisticsTaskService {

    @Override
    public Page<RfInternalLogisticsTask> selectPageWithCondition(Page<RfInternalLogisticsTask> page, RfInternalLogisticsTask condition) {
        LambdaQueryWrapper<RfInternalLogisticsTask> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfInternalLogisticsTask::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfInternalLogisticsTask::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getTaskType() != null && !condition.getTaskType().isEmpty()) {
                queryWrapper.eq(RfInternalLogisticsTask::getTaskType, condition.getTaskType());
            }
            if (condition.getLogisticsUserId() != null) {
                queryWrapper.eq(RfInternalLogisticsTask::getLogisticsUserId, condition.getLogisticsUserId());
            }
            if (condition.getSourceAddress() != null && !condition.getSourceAddress().isEmpty()) {
                queryWrapper.like(RfInternalLogisticsTask::getSourceAddress, condition.getSourceAddress());
            }
            if (condition.getTargetAddress() != null && !condition.getTargetAddress().isEmpty()) {
                queryWrapper.like(RfInternalLogisticsTask::getTargetAddress, condition.getTargetAddress());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfInternalLogisticsTask::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfInternalLogisticsTask> selectListWithCondition(RfInternalLogisticsTask condition) {
        LambdaQueryWrapper<RfInternalLogisticsTask> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfInternalLogisticsTask::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfInternalLogisticsTask::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getTaskType() != null && !condition.getTaskType().isEmpty()) {
                queryWrapper.eq(RfInternalLogisticsTask::getTaskType, condition.getTaskType());
            }
            if (condition.getLogisticsUserId() != null) {
                queryWrapper.eq(RfInternalLogisticsTask::getLogisticsUserId, condition.getLogisticsUserId());
            }
            if (condition.getSourceAddress() != null && !condition.getSourceAddress().isEmpty()) {
                queryWrapper.like(RfInternalLogisticsTask::getSourceAddress, condition.getSourceAddress());
            }
            if (condition.getTargetAddress() != null && !condition.getTargetAddress().isEmpty()) {
                queryWrapper.like(RfInternalLogisticsTask::getTargetAddress, condition.getTargetAddress());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfInternalLogisticsTask::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 