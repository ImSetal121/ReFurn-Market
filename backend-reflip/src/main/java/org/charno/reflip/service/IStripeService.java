package org.charno.reflip.service;

import java.math.BigDecimal;

/**
 * Stripe支付服务接口
 */
public interface IStripeService {
    
    /**
     * 向指定账户转账
     * 支持订单确认收货付款和用户提现两种场景
     * 
     * @param transferId 转账ID（订单ID或提现ID）
     * @param stripeAccountId 目标Stripe账户ID
     * @param amount 转账金额
     * @return 转账是否成功
     */
    boolean transferToSeller(String transferId, String stripeAccountId, BigDecimal amount);
} 