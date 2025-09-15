package org.charno.reflip.service;

import org.charno.reflip.dto.PaymentRequest;
import org.charno.reflip.dto.PaymentResponse;

/**
 * 支付服务接口
 */
public interface PaymentService {

    /**
     * 创建支付意图
     *
     * @param paymentRequest 支付请求
     * @return 支付响应
     */
    PaymentResponse createPaymentIntent(PaymentRequest paymentRequest) throws Exception;

    /**
     * 处理Stripe Webhook
     *
     * @param payload   请求体
     * @param signature 签名
     */
    void handleWebhook(String payload, String signature) throws Exception;

    /**
     * 获取支付状态
     *
     * @param paymentIntentId 支付意图ID
     * @return 支付状态
     */
    String getPaymentStatus(String paymentIntentId) throws Exception;
} 