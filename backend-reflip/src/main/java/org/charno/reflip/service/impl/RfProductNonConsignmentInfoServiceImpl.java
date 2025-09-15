package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductNonConsignmentInfo;
import org.charno.reflip.mapper.RfProductNonConsignmentInfoMapper;
import org.charno.reflip.service.IRfProductNonConsignmentInfoService;
import java.util.List;

/**
 * 非寄卖信息业务实现类
 */
@Service
public class RfProductNonConsignmentInfoServiceImpl extends ServiceImpl<RfProductNonConsignmentInfoMapper, RfProductNonConsignmentInfo> implements IRfProductNonConsignmentInfoService {

    @Override
    public Page<RfProductNonConsignmentInfo> selectPageWithCondition(Page<RfProductNonConsignmentInfo> page, RfProductNonConsignmentInfo condition) {
        LambdaQueryWrapper<RfProductNonConsignmentInfo> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getProductId, condition.getProductId());
            }
            if (condition.getSellerId() != null) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getSellerId, condition.getSellerId());
            }
            if (condition.getDeliveryMethod() != null && !condition.getDeliveryMethod().isEmpty()) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getDeliveryMethod, condition.getDeliveryMethod());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getStatus, condition.getStatus());
            }
            if (condition.getAppointmentPickupDate() != null) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getAppointmentPickupDate, condition.getAppointmentPickupDate());
            }
            if (condition.getAppointmentPickupTimePeriod() != null && !condition.getAppointmentPickupTimePeriod().isEmpty()) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getAppointmentPickupTimePeriod, condition.getAppointmentPickupTimePeriod());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductNonConsignmentInfo> selectListWithCondition(RfProductNonConsignmentInfo condition) {
        LambdaQueryWrapper<RfProductNonConsignmentInfo> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getProductId, condition.getProductId());
            }
            if (condition.getSellerId() != null) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getSellerId, condition.getSellerId());
            }
            if (condition.getDeliveryMethod() != null && !condition.getDeliveryMethod().isEmpty()) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getDeliveryMethod, condition.getDeliveryMethod());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getStatus, condition.getStatus());
            }
            if (condition.getAppointmentPickupDate() != null) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getAppointmentPickupDate, condition.getAppointmentPickupDate());
            }
            if (condition.getAppointmentPickupTimePeriod() != null && !condition.getAppointmentPickupTimePeriod().isEmpty()) {
                queryWrapper.eq(RfProductNonConsignmentInfo::getAppointmentPickupTimePeriod, condition.getAppointmentPickupTimePeriod());
            }
        }
        
        return this.list(queryWrapper);
    }
} 