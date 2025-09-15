package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;
import org.charno.common.core.R;
import org.charno.reflip.entity.RfBalanceDetail;
import org.charno.reflip.service.BalanceService;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * 面向用户的余额控制器
 * 提供当前登录用户的余额查询相关接口
 */
@RestController
@RequestMapping("/api/user/balance")
public class BalanceController {

    @Autowired
    private BalanceService balanceService;

    /**
     * 获取当前用户余额
     */
    @GetMapping("/current")
    public R<BigDecimal> getCurrentBalance() {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("用户未登录");
        }

        BigDecimal balance = balanceService.getCurrentUserBalance();
        return R.ok(balance, "获取余额成功");
    }

    /**
     * 分页查询当前用户的余额明细
     */
    @GetMapping("/details")
    public R<Page<RfBalanceDetail>> getBalanceDetailsPage(
            @RequestParam(defaultValue = "1") int current,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String transactionType,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startTime,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endTime) {

        if (!balanceService.isUserLoggedIn()) {
            return R.fail("用户未登录");
        }

        Page<RfBalanceDetail> page = new Page<>(current, size);
        Page<RfBalanceDetail> result = balanceService.getCurrentUserBalanceDetailsPage(
                page, transactionType, startTime, endTime);
        return R.ok(result, "获取余额明细成功");
    }

    /**
     * 获取当前用户指定交易类型的总金额
     */
    @GetMapping("/amount/{transactionType}")
    public R<BigDecimal> getAmountByType(@PathVariable String transactionType) {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("用户未登录");
        }

        BigDecimal amount = balanceService.getCurrentUserAmountByType(transactionType);
        return R.ok(amount, "获取交易类型金额成功");
    }

    /**
     * 获取当前用户最新余额明细
     */
    @GetMapping("/latest")
    public R<RfBalanceDetail> getLatestBalanceDetail() {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("用户未登录");
        }

        RfBalanceDetail detail = balanceService.getCurrentUserLatestBalanceDetail();
        return R.ok(detail, "获取最新余额明细成功");
    }

    /**
     * 获取当前用户ID（调试用）
     */
    @GetMapping("/user-id")
    public R<Long> getCurrentUserId() {
        Long userId = balanceService.getCurrentUserId();
        return R.ok(userId, "获取用户ID成功");
    }

    /**
     * 检查用户登录状态
     */
    @GetMapping("/status")
    public R<Boolean> checkLoginStatus() {
        boolean isLoggedIn = balanceService.isUserLoggedIn();
        return R.ok(isLoggedIn, "获取登录状态成功");
    }

    /**
     * 检查提现条件
     */
    @PostMapping("/withdraw/check")
    public R<Map<String, Object>> checkWithdrawEligibility(@RequestBody Map<String, Object> request) {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("用户未登录");
        }

        try {
            BigDecimal amount = new BigDecimal(request.get("amount").toString());
            BalanceService.WithdrawCheckResult result = balanceService.checkWithdrawEligibility(amount);

            Map<String, Object> response = new java.util.HashMap<>();
            response.put("eligible", result.isEligible());
            response.put("errorMessage", result.getErrorMessage());

            if (result.isEligible()) {
                return R.ok(response, "可以提现");
            } else {
                return R.fail(result.getErrorMessage());
            }
        } catch (Exception e) {
            return R.fail("检查提现条件失败: " + e.getMessage());
        }
    }

    /**
     * 提现到Stripe账户
     */
    @PostMapping("/withdraw")
    public R<Boolean> withdrawToStripe(@RequestBody Map<String, Object> request) {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("用户未登录");
        }

        try {
            BigDecimal amount = new BigDecimal(request.get("amount").toString());
            boolean success = balanceService.withdrawToStripe(amount);

            if (success) {
                return R.ok(true, "提现成功，资金将在1-2个工作日内到达您的银行账户");
            } else {
                return R.fail("提现失败，请稍后重试");
            }
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        } catch (Exception e) {
            return R.fail("提现失败: " + e.getMessage());
        }
    }

    /**
     * 充值成功处理
     */
    @PostMapping("/recharge/success")
    public R<Boolean> handleRechargeSuccess(@RequestBody Map<String, Object> request) {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("用户未登录");
        }

        try {
            BigDecimal amount = new BigDecimal(request.get("amount").toString());
            String paymentIntentId = request.get("paymentIntentId").toString();

            boolean success = balanceService.handleRechargeSuccess(amount, paymentIntentId);

            if (success) {
                return R.ok(true, "充值成功");
            } else {
                return R.fail("充值处理失败");
            }
        } catch (Exception e) {
            return R.fail("充值处理失败: " + e.getMessage());
        }
    }

    /**
     * 使用余额购买商品
     */
    @PostMapping("/purchase")
    public R<Map<String, Object>> purchaseWithBalance(@RequestBody Map<String, Object> request) {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("User not logged in");
        }

        try {
            BigDecimal amount = new BigDecimal(request.get("amount").toString());
            Integer productId = Integer.valueOf(request.get("productId").toString());
            String productName = request.get("productName").toString();

            BalanceService.PurchaseResult result = balanceService.purchaseWithBalance(productId, amount, productName);

            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", result.isSuccess());
            response.put("message", result.getMessage());
            response.put("orderId", result.getOrderId());

            if (result.isSuccess()) {
                return R.ok(response, "Purchase completed successfully");
            } else {
                return R.fail(result.getMessage());
            }
        } catch (Exception e) {
            return R.fail("Purchase failed: " + e.getMessage());
        }
    }

    /**
     * 使用余额购买寄卖商品
     */
    @PostMapping("/purchase/consignment")
    public R<Map<String, Object>> purchaseWithBalanceForConsignment(@RequestBody Map<String, Object> request) {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("User not logged in");
        }

        try {
            BigDecimal amount = new BigDecimal(request.get("amount").toString());
            Integer productId = Integer.valueOf(request.get("productId").toString());
            String productName = request.get("productName").toString();
            String deliveryAddress = request.get("deliveryAddress").toString();
            String deliveryPhone = request.get("deliveryPhone").toString();
            String deliveryName = request.get("deliveryName").toString();

            BalanceService.PurchaseResult result = balanceService.purchaseWithBalanceForConsignment(
                    productId, amount, productName, deliveryAddress, deliveryPhone, deliveryName);

            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", result.isSuccess());
            response.put("message", result.getMessage());
            response.put("orderId", result.getOrderId());

            if (result.isSuccess()) {
                return R.ok(response, "Consignment purchase completed successfully");
            } else {
                return R.fail(result.getMessage());
            }
        } catch (Exception e) {
            return R.fail("Consignment purchase failed: " + e.getMessage());
        }
    }

    /**
     * 检查余额购买条件
     */
    @PostMapping("/purchase/check")
    public R<Map<String, Object>> checkBalancePurchaseEligibility(@RequestBody Map<String, Object> request) {
        if (!balanceService.isUserLoggedIn()) {
            return R.fail("User not logged in");
        }

        try {
            BigDecimal amount = new BigDecimal(request.get("amount").toString());
            BalanceService.PurchaseCheckResult result = balanceService.checkBalancePurchaseEligibility(amount);

            Map<String, Object> response = new java.util.HashMap<>();
            response.put("eligible", result.isEligible());
            response.put("errorMessage", result.getErrorMessage());
            response.put("currentBalance", result.getCurrentBalance());

            if (result.isEligible()) {
                return R.ok(response, "Balance purchase is available");
            } else {
                return R.fail(result.getErrorMessage());
            }
        } catch (Exception e) {
            return R.fail("Failed to check purchase eligibility: " + e.getMessage());
        }
    }

    /**
     * 为指定用户创建余额明细（系统内部调用）
     * 注意：此接口应该有适当的权限控制，仅供系统内部业务逻辑调用
     */
    @PostMapping("/create-detail")
    public R<Boolean> createBalanceDetail(@RequestBody Map<String, Object> request) {
        try {
            Long userId = Long.valueOf(request.get("userId").toString());
            String transactionType = request.get("transactionType").toString();
            BigDecimal amount = new BigDecimal(request.get("amount").toString());
            String description = request.get("description").toString();

            boolean success = balanceService.createBalanceDetailForUser(userId, transactionType, amount, description);

            if (success) {
                return R.ok(true, "创建余额明细成功");
            } else {
                return R.fail("创建余额明细失败");
            }
        } catch (Exception e) {
            return R.fail("创建余额明细失败: " + e.getMessage());
        }
    }
}