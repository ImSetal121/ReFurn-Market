package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.reflip.mapper.RfProductSellRecordMapper;
import org.charno.reflip.service.IRfProductSellRecordService;
import java.util.List;

/**
 * 商品销售记录业务实现类
 */
@Service
public class RfProductSellRecordServiceImpl extends ServiceImpl<RfProductSellRecordMapper, RfProductSellRecord> implements IRfProductSellRecordService {

    @Override
    public Page<RfProductSellRecord> selectPageWithCondition(Page<RfProductSellRecord> page, RfProductSellRecord condition) {
        LambdaQueryWrapper<RfProductSellRecord> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductSellRecord::getProductId, condition.getProductId());
            }
            if (condition.getSellerUserId() != null) {
                queryWrapper.eq(RfProductSellRecord::getSellerUserId, condition.getSellerUserId());
            }
            if (condition.getBuyerUserId() != null) {
                queryWrapper.eq(RfProductSellRecord::getBuyerUserId, condition.getBuyerUserId());
            }
            if (condition.getIsAuction() != null) {
                queryWrapper.eq(RfProductSellRecord::getIsAuction, condition.getIsAuction());
            }
            if (condition.getIsSelfPickup() != null) {
                queryWrapper.eq(RfProductSellRecord::getIsSelfPickup, condition.getIsSelfPickup());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductSellRecord::getStatus, condition.getStatus());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductSellRecord> selectListWithCondition(RfProductSellRecord condition) {
        LambdaQueryWrapper<RfProductSellRecord> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfProductSellRecord::getProductId, condition.getProductId());
            }
            if (condition.getSellerUserId() != null) {
                queryWrapper.eq(RfProductSellRecord::getSellerUserId, condition.getSellerUserId());
            }
            if (condition.getBuyerUserId() != null) {
                queryWrapper.eq(RfProductSellRecord::getBuyerUserId, condition.getBuyerUserId());
            }
            if (condition.getIsAuction() != null) {
                queryWrapper.eq(RfProductSellRecord::getIsAuction, condition.getIsAuction());
            }
            if (condition.getIsSelfPickup() != null) {
                queryWrapper.eq(RfProductSellRecord::getIsSelfPickup, condition.getIsSelfPickup());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(RfProductSellRecord::getStatus, condition.getStatus());
            }
        }
        
        return this.list(queryWrapper);
    }
} 