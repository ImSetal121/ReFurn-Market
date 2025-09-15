package org.charno.reflip.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.charno.common.core.R;
import org.charno.reflip.dto.PaymentRequest;
import org.charno.reflip.dto.PaymentResponse;
import org.charno.reflip.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 支付控制器
 */
@RestController
@RequestMapping("/payment")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    /**
     * 创建支付意图
     *
     * @param paymentRequest 支付请求
     * @return 支付响应
     */
    @PostMapping("/create-intent")
    public R<PaymentResponse> createPaymentIntent(@RequestBody PaymentRequest paymentRequest) {
        try {
            PaymentResponse response = paymentService.createPaymentIntent(paymentRequest);
            return R.ok(response, "支付意图创建成功");
        } catch (Exception e) {
            return R.fail("创建支付意图失败: " + e.getMessage());
        }
    }

    /**
     * Stripe Webhook处理
     *
     * @param payload 请求体
     * @param request HTTP请求
     * @return 处理结果
     */
    @PostMapping("/stripe/webhook")
    public R<String> handleStripeWebhook(@RequestBody String payload, HttpServletRequest request) {
        try {
            String signature = request.getHeader("Stripe-Signature");
            paymentService.handleWebhook(payload, signature);
            return R.ok("Webhook处理成功");
        } catch (Exception e) {
            return R.fail("Webhook处理失败: " + e.getMessage());
        }
    }

    /**
     * 确认支付状态
     *
     * @param paymentIntentId 支付意图ID
     * @return 支付状态
     */
    @GetMapping("/status/{paymentIntentId}")
    public R<String> getPaymentStatus(@PathVariable String paymentIntentId) {
        try {
            String status = paymentService.getPaymentStatus(paymentIntentId);
            return R.ok(status, "获取支付状态成功");
        } catch (Exception e) {
            return R.fail("获取支付状态失败: " + e.getMessage());
        }
    }
} 