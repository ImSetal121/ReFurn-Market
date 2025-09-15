package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.charno.reflip.entity.RfBalanceDetail;
import org.charno.reflip.mapper.RfBalanceDetailMapper;
import org.charno.reflip.service.IRfBalanceDetailService;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 余额明细业务实现类
 */
@Service
public class RfBalanceDetailServiceImpl extends ServiceImpl<RfBalanceDetailMapper, RfBalanceDetail> implements IRfBalanceDetailService {

    @Override
    public Page<RfBalanceDetail> selectPageWithCondition(Page<RfBalanceDetail> page, RfBalanceDetail condition) {
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(RfBalanceDetail::getUserId, condition.getUserId());
            }
            if (condition.getTransactionType() != null && !condition.getTransactionType().isEmpty()) {
                queryWrapper.eq(RfBalanceDetail::getTransactionType, condition.getTransactionType());
            }
            if (condition.getAmount() != null) {
                queryWrapper.eq(RfBalanceDetail::getAmount, condition.getAmount());
            }
        }
        
        queryWrapper.orderByDesc(RfBalanceDetail::getTransactionTime);
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfBalanceDetail> selectListWithCondition(RfBalanceDetail condition) {
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(RfBalanceDetail::getUserId, condition.getUserId());
            }
            if (condition.getTransactionType() != null && !condition.getTransactionType().isEmpty()) {
                queryWrapper.eq(RfBalanceDetail::getTransactionType, condition.getTransactionType());
            }
            if (condition.getAmount() != null) {
                queryWrapper.eq(RfBalanceDetail::getAmount, condition.getAmount());
            }
        }
        
        queryWrapper.orderByDesc(RfBalanceDetail::getTransactionTime);
        return this.list(queryWrapper);
    }

    @Override
    public List<RfBalanceDetail> getByUserId(Long userId) {
        if (userId == null) {
            return List.of();
        }
        
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBalanceDetail::getUserId, userId)
                   .orderByDesc(RfBalanceDetail::getTransactionTime);
        
        return this.list(queryWrapper);
    }

    @Override
    public Page<RfBalanceDetail> getByUserIdPage(Page<RfBalanceDetail> page, Long userId) {
        if (userId == null) {
            return page;
        }
        
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBalanceDetail::getUserId, userId)
                   .orderByDesc(RfBalanceDetail::getTransactionTime);
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfBalanceDetail> getByUserIdAndType(Long userId, String transactionType) {
        if (userId == null || transactionType == null || transactionType.isEmpty()) {
            return List.of();
        }
        
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBalanceDetail::getUserId, userId)
                   .eq(RfBalanceDetail::getTransactionType, transactionType)
                   .orderByDesc(RfBalanceDetail::getTransactionTime);
        
        return this.list(queryWrapper);
    }

    @Override
    public List<RfBalanceDetail> getByUserIdAndTimeRange(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        if (userId == null) {
            return List.of();
        }
        
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBalanceDetail::getUserId, userId);
        
        if (startTime != null) {
            queryWrapper.ge(RfBalanceDetail::getTransactionTime, startTime);
        }
        if (endTime != null) {
            queryWrapper.le(RfBalanceDetail::getTransactionTime, endTime);
        }
        
        queryWrapper.orderByDesc(RfBalanceDetail::getTransactionTime);
        return this.list(queryWrapper);
    }

    @Override
    public RfBalanceDetail getLatestByUserId(Long userId) {
        if (userId == null) {
            return null;
        }
        
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBalanceDetail::getUserId, userId)
                   .orderByDesc(RfBalanceDetail::getTransactionTime)
                   .last("LIMIT 1");
        
        return this.getOne(queryWrapper);
    }

    @Override
    public BigDecimal getCurrentBalance(Long userId) {
        RfBalanceDetail latestDetail = getLatestByUserId(userId);
        return latestDetail != null ? latestDetail.getBalanceAfter() : BigDecimal.ZERO;
    }

    @Override
    @Transactional
    public boolean createBalanceDetail(RfBalanceDetail balanceDetail) {
        if (balanceDetail == null || balanceDetail.getUserId() == null) {
            return false;
        }
        
        // 获取用户最新的余额明细记录
        RfBalanceDetail latestDetail = getLatestByUserId(balanceDetail.getUserId());
        
        // 维护双链表结构
        if (latestDetail != null) {
            // 设置当前记录的前指针
            balanceDetail.setPrevDetailId(latestDetail.getId());
            
            // 保存当前记录
            boolean saved = this.save(balanceDetail);
            if (!saved) {
                return false;
            }
            
            // 更新上一条记录的后指针
            LambdaUpdateWrapper<RfBalanceDetail> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.eq(RfBalanceDetail::getId, latestDetail.getId())
                        .set(RfBalanceDetail::getNextDetailId, balanceDetail.getId());
            return this.update(updateWrapper);
        } else {
            // 第一条记录，直接保存
            return this.save(balanceDetail);
        }
    }

    @Override
    public BigDecimal sumAmountByUserIdAndType(Long userId, String transactionType) {
        if (userId == null || transactionType == null || transactionType.isEmpty()) {
            return BigDecimal.ZERO;
        }
        
        LambdaQueryWrapper<RfBalanceDetail> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfBalanceDetail::getUserId, userId)
                   .eq(RfBalanceDetail::getTransactionType, transactionType);
        
        List<RfBalanceDetail> details = this.list(queryWrapper);
        return details.stream()
                     .map(RfBalanceDetail::getAmount)
                     .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    @Override
    public RfBalanceDetail getPrevDetail(Long detailId) {
        if (detailId == null) {
            return null;
        }
        
        RfBalanceDetail currentDetail = this.getById(detailId);
        if (currentDetail == null || currentDetail.getPrevDetailId() == null) {
            return null;
        }
        
        return this.getById(currentDetail.getPrevDetailId());
    }

    @Override
    public RfBalanceDetail getNextDetail(Long detailId) {
        if (detailId == null) {
            return null;
        }
        
        RfBalanceDetail currentDetail = this.getById(detailId);
        if (currentDetail == null || currentDetail.getNextDetailId() == null) {
            return null;
        }
        
        return this.getById(currentDetail.getNextDetailId());
    }
} 