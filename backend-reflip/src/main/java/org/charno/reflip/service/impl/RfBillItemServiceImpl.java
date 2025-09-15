package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfBillItem;
import org.charno.reflip.mapper.RfBillItemMapper;
import org.charno.reflip.service.IRfBillItemService;
import java.util.List;

/**
 * 账单项业务实现类
 */
@Service
public class RfBillItemServiceImpl extends ServiceImpl<RfBillItemMapper, RfBillItem> implements IRfBillItemService {

    @Override
    public Page<RfBillItem> selectPageWithCondition(Page<RfBillItem> page, RfBillItem condition) {
        LambdaQueryWrapper<RfBillItem> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfBillItem::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfBillItem::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getCostType() != null && !condition.getCostType().isEmpty()) {
                queryWrapper.eq(RfBillItem::getCostType, condition.getCostType());
            }
            if (condition.getPayUserId() != null) {
                queryWrapper.eq(RfBillItem::getPayUserId, condition.getPayUserId());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfBillItem::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfBillItem> selectListWithCondition(RfBillItem condition) {
        LambdaQueryWrapper<RfBillItem> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfBillItem::getProductId, condition.getProductId());
            }
            if (condition.getProductSellRecordId() != null) {
                queryWrapper.eq(RfBillItem::getProductSellRecordId, condition.getProductSellRecordId());
            }
            if (condition.getCostType() != null && !condition.getCostType().isEmpty()) {
                queryWrapper.eq(RfBillItem::getCostType, condition.getCostType());
            }
            if (condition.getPayUserId() != null) {
                queryWrapper.eq(RfBillItem::getPayUserId, condition.getPayUserId());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfBillItem::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 