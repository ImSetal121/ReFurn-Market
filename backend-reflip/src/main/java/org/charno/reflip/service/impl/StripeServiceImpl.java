package org.charno.reflip.service.impl;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.Transfer;
import com.stripe.param.TransferCreateParams;
import jakarta.annotation.PostConstruct;
import org.charno.reflip.service.IStripeService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * Stripe支付服务实现类
 */
@Service
public class StripeServiceImpl implements IStripeService {
    
    private static final Logger log = LoggerFactory.getLogger(StripeServiceImpl.class);
    
    @Value("${stripe.secret-key}")
    private String stripeApiKey;
    
    @PostConstruct
    public void init() {
        Stripe.apiKey = stripeApiKey;
    }
    
    /**
     * 向卖家转账
     * 
     * @param transferId 转账ID（可以是订单ID或提现ID）
     * @param stripeAccountId 卖家的Stripe账户ID
     * @param amount 转账金额
     * @return 转账是否成功
     */
    @Override
    public boolean transferToSeller(String transferId, String stripeAccountId, BigDecimal amount) {
        try {
            // Stripe金额以最小货币单位（分）计算，需要将金额转换为分
            long amountInCents = amount.multiply(new BigDecimal(100)).longValue();
            
            // 判断转账类型并设置相应描述
            String description;
            if (transferId.startsWith("WITHDRAW_")) {
                description = "用户提现 - 提现ID: " + transferId;
            } else {
                description = "确认收货付款 - 订单ID: " + transferId;
            }
            
            // 创建转账参数
            TransferCreateParams params = TransferCreateParams.builder()
                .setAmount(amountInCents)
                .setCurrency("usd") // 平台统一使用美元结算
                .setDestination(stripeAccountId)
                .setDescription(description)
                .build();
            
            // 执行转账
            Transfer transfer = Transfer.create(params);
            
            log.info("向账户{}转账成功: 金额={}USD, 转账ID={}, Stripe转账ID={}", 
                    stripeAccountId, amount, transferId, transfer.getId());
            
            return true;
        } catch (StripeException e) {
            // 特殊处理余额不足的情况
            if (e.getCode() != null && "balance_insufficient".equals(e.getCode())) {
                log.warn("Stripe账户余额不足，无法向账户{}转账: 金额={}USD, 转账ID={}. " +
                        "这是测试环境的常见问题，实际生产环境中平台账户应有足够余额。" +
                        "建议：1) 使用测试卡4000000000000077向平台充值 2) 或在生产环境中确保平台账户有足够余额", 
                        stripeAccountId, amount, transferId);
                
                // 抛出异常以便事务回滚
                throw new RuntimeException("Stripe账户余额不足，无法转账", e);
            }
            
            log.error("向账户{}转账失败: 金额={}USD, 转账ID={}, 错误代码={}, 错误信息={}", 
                    stripeAccountId, amount, transferId, e.getCode(), e.getMessage(), e);
            throw new RuntimeException("转账失败: " + e.getMessage(), e);
        }
    }
} 