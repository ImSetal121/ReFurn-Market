package org.charno.reflip.service.impl;

import com.stripe.Stripe;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.PaymentIntent;
import com.stripe.model.StripeObject;
import com.stripe.net.Webhook;
import com.stripe.param.PaymentIntentCreateParams;
import jakarta.annotation.PostConstruct;
import org.charno.reflip.dto.PaymentRequest;
import org.charno.reflip.dto.PaymentResponse;
import org.charno.reflip.service.PaymentService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

/**
 * 支付服务实现类
 */
@Service
public class PaymentServiceImpl implements PaymentService {

    @Value("${stripe.secret-key}")
    private String stripeSecretKey;

    @Value("${stripe.webhook-secret}")
    private String webhookSecret;

    @PostConstruct
    public void init() {
        Stripe.apiKey = stripeSecretKey;
    }

    @Override
    public PaymentResponse createPaymentIntent(PaymentRequest paymentRequest) throws Exception {
        // 将美元转换为美分（Stripe使用最小货币单位）
        long amountInCents = paymentRequest.getAmount().multiply(new BigDecimal("100")).longValue();

        PaymentIntentCreateParams params = PaymentIntentCreateParams.builder()
                .setAmount(amountInCents)
                .setCurrency(paymentRequest.getCurrency())
                .setDescription(paymentRequest.getDescription())
                // 添加元数据，用于追踪订单信息
                .putMetadata("product_id", String.valueOf(paymentRequest.getProductId()))
                .putMetadata("platform", "reflip_flutter")
                .build();

        PaymentIntent paymentIntent = PaymentIntent.create(params);

        return new PaymentResponse(
                paymentIntent.getId(),
                paymentIntent.getClientSecret(),
                paymentIntent.getStatus()
        );
    }

    @Override
    public void handleWebhook(String payload, String signature) throws Exception {
        Event event;

        try {
            event = Webhook.constructEvent(payload, signature, webhookSecret);
        } catch (SignatureVerificationException e) {
            throw new Exception("Invalid signature");
        }

        // 处理不同的事件类型
        switch (event.getType()) {
            case "payment_intent.succeeded":
                PaymentIntent paymentIntent = (PaymentIntent) event.getDataObjectDeserializer().getObject().orElse(null);
                if (paymentIntent != null) {
                    handlePaymentSucceeded(paymentIntent);
                }
                break;
            case "payment_intent.payment_failed":
                PaymentIntent failedPayment = (PaymentIntent) event.getDataObjectDeserializer().getObject().orElse(null);
                if (failedPayment != null) {
                    handlePaymentFailed(failedPayment);
                }
                break;
            default:
                System.out.println("Unhandled event type: " + event.getType());
        }
    }

    @Override
    public String getPaymentStatus(String paymentIntentId) throws Exception {
        PaymentIntent paymentIntent = PaymentIntent.retrieve(paymentIntentId);
        return paymentIntent.getStatus();
    }

    /**
     * 处理支付成功事件
     *
     * @param paymentIntent 支付意图
     */
    private void handlePaymentSucceeded(PaymentIntent paymentIntent) {
        // TODO: 在这里实现支付成功后的业务逻辑
        // 1. 更新订单状态
        // 2. 发送确认邮件
        // 3. 更新库存等
        
        String productId = paymentIntent.getMetadata().get("product_id");
        System.out.println("支付成功 - 商品ID: " + productId + ", 支付意图ID: " + paymentIntent.getId());
        
        // 这里可以调用其他服务来处理业务逻辑
        // orderService.updateOrderStatus(productId, "paid");
    }

    /**
     * 处理支付失败事件
     *
     * @param paymentIntent 支付意图
     */
    private void handlePaymentFailed(PaymentIntent paymentIntent) {
        // TODO: 在这里实现支付失败后的业务逻辑
        // 1. 更新订单状态为失败
        // 2. 释放库存
        // 3. 发送失败通知等
        
        String productId = paymentIntent.getMetadata().get("product_id");
        System.out.println("支付失败 - 商品ID: " + productId + ", 支付意图ID: " + paymentIntent.getId());
        
        // 这里可以调用其他服务来处理业务逻辑
        // orderService.updateOrderStatus(productId, "failed");
    }
} 