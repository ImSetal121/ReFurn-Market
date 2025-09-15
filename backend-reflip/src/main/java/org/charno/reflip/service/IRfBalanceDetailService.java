package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfBalanceDetail;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 余额明细业务接口
 */
public interface IRfBalanceDetailService extends IBaseService<RfBalanceDetail> {
    
    /**
     * 分页条件查询
     */
    Page<RfBalanceDetail> selectPageWithCondition(Page<RfBalanceDetail> page, RfBalanceDetail condition);
    
    /**
     * 不分页条件查询
     */
    List<RfBalanceDetail> selectListWithCondition(RfBalanceDetail condition);
    
    /**
     * 根据用户ID查询余额明细（按时间倒序）
     */
    List<RfBalanceDetail> getByUserId(Long userId);
    
    /**
     * 分页查询用户余额明细
     */
    Page<RfBalanceDetail> getByUserIdPage(Page<RfBalanceDetail> page, Long userId);
    
    /**
     * 根据用户ID和交易类型查询余额明细
     */
    List<RfBalanceDetail> getByUserIdAndType(Long userId, String transactionType);
    
    /**
     * 根据时间范围查询用户余额明细
     */
    List<RfBalanceDetail> getByUserIdAndTimeRange(Long userId, LocalDateTime startTime, LocalDateTime endTime);
    
    /**
     * 获取用户最新的余额明细记录
     */
    RfBalanceDetail getLatestByUserId(Long userId);
    
    /**
     * 获取用户当前余额
     */
    BigDecimal getCurrentBalance(Long userId);
    
    /**
     * 创建余额明细记录（自动维护双链表结构）
     */
    boolean createBalanceDetail(RfBalanceDetail balanceDetail);
    
    /**
     * 根据交易类型统计用户总金额
     */
    BigDecimal sumAmountByUserIdAndType(Long userId, String transactionType);
    
    /**
     * 获取用户上一条明细记录
     */
    RfBalanceDetail getPrevDetail(Long detailId);
    
    /**
     * 获取用户下一条明细记录
     */
    RfBalanceDetail getNextDetail(Long detailId);
} 