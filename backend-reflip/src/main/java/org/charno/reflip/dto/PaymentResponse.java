package org.charno.reflip.dto;

/**
 * 支付响应DTO
 */
public class PaymentResponse {
    
    /**
     * 支付意图ID
     */
    private String paymentIntentId;
    
    /**
     * 客户端密钥
     */
    private String clientSecret;
    
    /**
     * 支付状态
     */
    private String status;

    public PaymentResponse() {}

    public PaymentResponse(String paymentIntentId, String clientSecret, String status) {
        this.paymentIntentId = paymentIntentId;
        this.clientSecret = clientSecret;
        this.status = status;
    }

    public String getPaymentIntentId() {
        return paymentIntentId;
    }

    public void setPaymentIntentId(String paymentIntentId) {
        this.paymentIntentId = paymentIntentId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public void setClientSecret(String clientSecret) {
        this.clientSecret = clientSecret;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
} 