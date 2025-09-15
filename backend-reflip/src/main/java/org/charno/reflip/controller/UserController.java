package org.charno.reflip.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfBillItem;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.service.IUserService;
import org.charno.common.core.R;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import java.util.Map;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private IUserService userService;

    /**
     * 获取当前用户的账单列表
     * 
     * @param status 账单状态 (可选: PENDING, PAID, OVERDUE)
     * @param page   页码 (默认1)
     * @param size   每页大小 (默认10)
     * @return 账单列表
     */
    @GetMapping("/bills")
    public R<Page<RfBillItem>> getUserBills(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            Page<RfBillItem> result = userService.getUserBills(status, page, size);
            return R.ok(result, "Bills retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve bills: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的账单统计信息
     * 
     * @return 账单统计数据
     */
    @GetMapping("/bills/summary")
    public R<Map<String, Object>> getBillsSummary() {
        try {
            Map<String, Object> summary = userService.getBillsSummary();
            return R.ok(summary, "Bill summary retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve bill summary: " + e.getMessage());
        }
    }

    /**
     * 获取账单详情
     * 
     * @param billId 账单ID
     * @return 账单详情
     */
    @GetMapping("/bills/{billId}")
    public R<RfBillItem> getBillDetail(@PathVariable Long billId) {
        try {
            RfBillItem billItem = userService.getBillDetail(billId);
            return R.ok(billItem, "Bill detail retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve bill detail: " + e.getMessage());
        }
    }

    /**
     * 处理账单支付成功
     * 
     * @param billId          账单ID
     * @param paymentIntentId Stripe支付意图ID
     * @return 处理结果
     */
    @PostMapping("/bills/{billId}/payment-success")
    public R<String> handleBillPaymentSuccess(
            @PathVariable Long billId,
            @RequestParam String paymentIntentId) {
        try {
            boolean success = userService.handleBillPaymentSuccess(billId, paymentIntentId);
            if (success) {
                return R.ok("Bill payment processed successfully");
            } else {
                return R.fail("Failed to process bill payment");
            }
        } catch (Exception e) {
            return R.fail("Failed to process bill payment: " + e.getMessage());
        }
    }

    /**
     * 使用余额支付账单
     * 
     * @param billId 账单ID
     * @return 处理结果
     */
    @PostMapping("/bills/{billId}/balance-payment")
    public R<String> handleBillBalancePayment(@PathVariable Long billId) {
        try {
            boolean success = userService.handleBillBalancePayment(billId);
            if (success) {
                return R.ok("Bill paid with balance successfully");
            } else {
                return R.fail("Failed to pay bill with balance");
            }
        } catch (Exception e) {
            return R.fail("Failed to pay bill with balance: " + e.getMessage());
        }
    }

    /**
     * 收藏商品
     * 
     * @param productId 商品ID
     * @return 操作结果
     */
    @PostMapping("/favorites/{productId}")
    public R<String> addFavoriteProduct(@PathVariable Long productId) {
        try {
            boolean success = userService.addFavoriteProduct(productId);
            if (success) {
                return R.ok("Product added to favorites successfully");
            } else {
                return R.fail("Failed to add product to favorites");
            }
        } catch (Exception e) {
            return R.fail("Failed to add product to favorites: " + e.getMessage());
        }
    }

    /**
     * 取消收藏商品
     * 
     * @param productId 商品ID
     * @return 操作结果
     */
    @DeleteMapping("/favorites/{productId}")
    public R<String> removeFavoriteProduct(@PathVariable Long productId) {
        try {
            boolean success = userService.removeFavoriteProduct(productId);
            if (success) {
                return R.ok("Product removed from favorites successfully");
            } else {
                return R.fail("Failed to remove product from favorites");
            }
        } catch (Exception e) {
            return R.fail("Failed to remove product from favorites: " + e.getMessage());
        }
    }

    /**
     * 查询某个商品是否被当前用户收藏
     * 
     * @param productId 商品ID
     * @return 收藏状态
     */
    @GetMapping("/favorites/{productId}/status")
    public R<Boolean> isProductFavorited(@PathVariable Long productId) {
        try {
            boolean isFavorited = userService.isProductFavorited(productId);
            return R.ok(isFavorited, "Favorite status retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to check favorite status: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的收藏商品列表（分页）
     * 
     * @param page 页码 (默认1)
     * @param size 每页大小 (默认10)
     * @return 收藏商品分页数据
     */
    @GetMapping("/favorites")
    public R<Page<RfProduct>> getUserFavoriteProducts(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            Page<RfProduct> result = userService.getUserFavoriteProducts(page, size);
            return R.ok(result, "Favorite products retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve favorite products: " + e.getMessage());
        }
    }

    /**
     * 记录用户浏览商品历史
     * 
     * @param productId 商品ID
     * @return 操作结果
     */
    @PostMapping("/browse-history/{productId}")
    public R<String> recordBrowseHistory(@PathVariable Long productId) {
        try {
            boolean success = userService.recordBrowseHistory(productId);
            if (success) {
                return R.ok("Browse history recorded successfully");
            } else {
                return R.fail("Failed to record browse history");
            }
        } catch (Exception e) {
            return R.fail("Failed to record browse history: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的浏览历史记录（分页）
     * 
     * @param page 页码 (默认1)
     * @param size 每页大小 (默认10)
     * @return 浏览历史分页数据
     */
    @GetMapping("/browse-history")
    public R<Page<RfProduct>> getUserBrowseHistory(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            Page<RfProduct> result = userService.getUserBrowseHistory(page, size);
            return R.ok(result, "Browse history retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve browse history: " + e.getMessage());
        }
    }

    /**
     * 获取某个商品的总浏览数
     * 
     * @param productId 商品ID
     * @return 浏览次数
     */
    @GetMapping("/browse-history/{productId}/count")
    public R<Long> getProductBrowseCount(@PathVariable Long productId) {
        try {
            Long browseCount = userService.getProductBrowseCount(productId);
            return R.ok(browseCount, "Product browse count retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve product browse count: " + e.getMessage());
        }
    }
}