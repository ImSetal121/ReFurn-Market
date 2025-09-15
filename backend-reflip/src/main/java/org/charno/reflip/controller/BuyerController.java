package org.charno.reflip.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.service.IBuyerService;
import org.charno.common.core.R;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.reflip.dto.ConfirmReceiptRequest;
import org.charno.reflip.dto.RefundApplicationRequest;

import java.util.Map;

/**
 * 买家控制器
 * 处理需要用户登录的买家相关业务
 */
@RestController
@RequestMapping("/api/buyer")
public class BuyerController {

    private static final Logger log = LoggerFactory.getLogger(BuyerController.class);

    @Autowired
    private IBuyerService buyerService;

    /**
     * 锁定商品
     * 锁定成功后，商品将在2分钟内不对其他用户可见
     * 
     * @param productId 商品ID
     * @return 锁定结果
     */
    @PostMapping("/product/{productId}/lock")
    public R<Boolean> lockProduct(@PathVariable Long productId) {
        try {
            boolean success = buyerService.lockProduct(productId);
            if (success) {
                return R.ok(true, "Product locked successfully");
            } else {
                return R.fail("Product is already locked by another user");
            }
        } catch (Exception e) {
            return R.fail("Failed to lock product: " + e.getMessage());
        }
    }

    /**
     * 检查商品锁定状态
     * 
     * @param productId 商品ID
     * @return 锁定状态
     */
    @GetMapping("/product/{productId}/lock-status")
    public R<Boolean> checkProductLockStatus(@PathVariable Long productId) {
        try {
            boolean isLocked = buyerService.isProductLocked(productId);
            return R.ok(isLocked, isLocked ? "Product is locked" : "Product is available");
        } catch (Exception e) {
            return R.fail("Failed to check product lock status: " + e.getMessage());
        }
    }

    /**
     * 解锁商品
     * 允许锁定者提前释放商品锁定
     * 
     * @param productId 商品ID
     * @return 解锁结果
     */
    @DeleteMapping("/product/{productId}/lock")
    public R<Boolean> unlockProduct(@PathVariable Long productId) {
        try {
            boolean success = buyerService.unlockProduct(productId);
            if (success) {
                return R.ok(true, "Product unlocked successfully");
            } else {
                return R.fail("Failed to unlock product or product was not locked by current user");
            }
        } catch (Exception e) {
            return R.fail("Failed to unlock product: " + e.getMessage());
        }
    }

    /**
     * 获取商品锁的剩余时间
     * 
     * @param productId 商品ID
     * @return 剩余时间（秒）
     */
    @GetMapping("/product/{productId}/lock-remaining-time")
    public R<Long> getLockRemainingTime(@PathVariable Long productId) {
        try {
            long remainingTime = buyerService.getLockRemainingTime(productId);
            if (remainingTime >= 0) {
                return R.ok(remainingTime, "Lock remaining time retrieved successfully");
            } else {
                return R.fail("Product is not locked by current user");
            }
        } catch (Exception e) {
            return R.fail("Failed to get lock remaining time: " + e.getMessage());
        }
    }

    /**
     * 处理购买成功
     * 当支付成功后调用此接口完成购买流程
     * 
     * @param request 包含商品ID和支付意图ID的请求体
     * @return 处理结果
     */
    @PostMapping("/purchase/success")
    public R<Boolean> handlePurchaseSuccess(@RequestBody Map<String, Object> request) {
        try {
            Long productId = Long.valueOf(request.get("productId").toString());
            String paymentIntentId = request.get("paymentIntentId").toString();
            
            boolean success = buyerService.handlePurchaseSuccess(productId, paymentIntentId);
            
            if (success) {
                return R.ok(true, "Purchase completed successfully");
            } else {
                return R.fail("Failed to complete purchase");
            }
        } catch (Exception e) {
            log.error("处理购买成功失败", e);
            return R.fail("Purchase processing failed: " + e.getMessage());
        }
    }

    /**
     * 检查当前用户是否为商品拥有者
     * 
     * @param productId 商品ID
     * @return 是否为商品拥有者
     */
    @GetMapping("/product/{productId}/is-owner")
    public R<Boolean> isProductOwner(@PathVariable Long productId) {
        try {
            boolean isOwner = buyerService.isProductOwner(productId);
            return R.ok(isOwner, isOwner ? "User is the product owner" : "User is not the product owner");
        } catch (Exception e) {
            log.error("检查商品拥有者失败", e);
            return R.fail("Failed to check product ownership: " + e.getMessage());
        }
    }

    /**
     * 处理寄卖商品购买成功
     * 当寄卖商品支付成功后调用此接口完成购买流程
     * 
     * @param request 包含商品ID、支付意图ID和收货地址的请求体
     * @return 处理结果
     */
    @PostMapping("/consignment/purchase/success")
    public R<Boolean> handleConsignmentPurchaseSuccess(@RequestBody Map<String, Object> request) {
        try {
            Long productId = Long.valueOf(request.get("productId").toString());
            String paymentIntentId = request.get("paymentIntentId").toString();
            String deliveryAddress = request.get("deliveryAddress").toString();
            String deliveryPhone = request.get("deliveryPhone").toString();
            String deliveryName = request.get("deliveryName").toString();
            
            boolean success = buyerService.handleConsignmentPurchaseSuccess(
                productId, paymentIntentId, deliveryAddress, deliveryPhone, deliveryName);
            
            if (success) {
                return R.ok(true, "Consignment purchase completed successfully");
            } else {
                return R.fail("Failed to complete consignment purchase");
            }
        } catch (Exception e) {
            log.error("处理寄卖商品购买成功失败", e);
            return R.fail("Consignment purchase processing failed: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的购买记录
     * 
     * @param page 页码（从1开始，默认为1）
     * @param size 每页大小（默认为10）
     * @return 购买记录分页数据
     */
    @GetMapping("/my-orders")
    public R<Page<RfProductSellRecord>> getMyOrders(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        try {
            Page<RfProductSellRecord> orders = buyerService.getMyOrders(page, size);
            return R.ok(orders, "Orders retrieved successfully");
        } catch (Exception e) {
            log.error("获取用户购买记录失败", e);
            return R.fail("Failed to get user orders: " + e.getMessage());
        }
    }

    /**
     * 确认收货接口
     * 买家确认收到商品，更新订单状态，创建评价，并向卖家付款
     *
     * @param request 确认收货请求，包含订单ID、评价内容和收货凭证图片
     * @return 确认结果
     */
    @PostMapping("/confirm-receipt")
    public R<Boolean> confirmReceipt(@RequestBody ConfirmReceiptRequest request) {
        try {
            log.info("接收到确认收货请求: {}", request.getOrderId());
            boolean success = buyerService.confirmReceipt(
                request.getOrderId(),
                request.getComment(),
                request.getReceiptImages()
            );
            
            if (success) {
                return R.ok(true, "确认收货成功");
            } else {
                return R.fail("确认收货失败，请检查订单状态");
            }
        } catch (RuntimeException e) {
            log.error("确认收货处理失败: {}", e.getMessage());
            // 返回具体的错误信息给前端
            return R.fail(e.getMessage());
        } catch (Exception e) {
            log.error("确认收货处理发生未知错误", e);
            return R.fail("确认收货失败: 系统处理异常，请联系客服");
        }
    }

    /**
     * 申请退货接口
     * 买家申请退货，需要填写退货原因和详细说明
     *
     * @param request 退货申请请求，包含订单ID、退货原因和详细说明
     * @return 申请结果
     */
    @PostMapping("/apply-refund")
    public R<Boolean> applyRefund(@RequestBody RefundApplicationRequest request) {
        try {
            log.info("接收到退货申请请求: {}", request.getOrderId());
            
            boolean success = buyerService.applyRefund(
                request.getOrderId(),
                request.getReason(),
                request.getDescription(),
                request.getPickupAddress()
            );
            
            if (success) {
                return R.ok(true, "退货申请提交成功，我们将在24小时内处理您的申请");
            } else {
                return R.fail("退货申请提交失败，请稍后再试");
            }
            
        } catch (RuntimeException e) {
            log.error("退货申请处理失败: {}", e.getMessage());
            return R.fail(e.getMessage());
        } catch (Exception e) {
            log.error("退货申请处理发生未知错误", e);
            return R.fail("退货申请失败: 系统处理异常，请联系客服");
        }
    }
} 