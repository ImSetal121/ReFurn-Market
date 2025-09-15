package org.charno.reflip.dto;

import java.math.BigDecimal;

/**
 * 支付请求DTO
 */
public class PaymentRequest {
    
    /**
     * 商品ID
     */
    private Long productId;
    
    /**
     * 支付金额（美元）
     */
    private BigDecimal amount;
    
    /**
     * 币种，默认USD
     */
    private String currency = "usd";
    
    /**
     * 支付描述
     */
    private String description;

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
} 