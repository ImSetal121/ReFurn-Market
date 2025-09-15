package org.charno.reflip.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.service.ISellerService;
import org.charno.reflip.dto.ConsignmentListingRequest;
import org.charno.common.core.R;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.common.entity.SysUserStripeAccount;

import java.util.Map;

/**
 * 卖家控制器
 */
@RestController
@RequestMapping("/api/seller")
public class SellerController {

    @Autowired
    private ISellerService sellerService;

    /**
     * 商品上架接口
     * 接收前端传来的商品信息并上架
     * 
     * @param rfProduct 商品信息
     * @return 上架结果
     */
    @PostMapping("/list-product")
    public R<RfProduct> listProduct(@RequestBody RfProduct rfProduct) {
        try {
            RfProduct listedProduct = sellerService.listProduct(rfProduct);
            return R.ok(listedProduct, "Product listed successfully");
        } catch (Exception e) {
            return R.fail("Product listing failed: " + e.getMessage());
        }
    }

    /**
     * 寄卖上架接口
     * 接收前端传来的寄卖商品信息并处理上架流程
     * 
     * @param request 寄卖上架请求
     * @return 上架结果
     */
    @PostMapping("/consignment-listing")
    public R<RfProduct> consignmentListing(@RequestBody ConsignmentListingRequest request) {
        try {
            RfProduct listedProduct = sellerService.consignmentListing(request);
            return R.ok(listedProduct, "Consignment listing submitted successfully");
        } catch (Exception e) {
            return R.fail("Consignment listing failed: " + e.getMessage());
        }
    }

    /**
     * 自提上架接口
     * 接收前端传来的自提商品信息并处理上架流程
     * 
     * @param rfProduct 商品信息
     * @return 上架结果
     */
    @PostMapping("/self-pickup-listing")
    public R<RfProduct> selfPickupListing(@RequestBody RfProduct rfProduct) {
        try {
            RfProduct listedProduct = sellerService.selfPickupListing(rfProduct);
            return R.ok(listedProduct, "Self-pickup listing submitted successfully");
        } catch (Exception e) {
            return R.fail("Self-pickup listing failed: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的商品列表
     * 
     * @return 用户商品列表
     */
    @GetMapping("/my-products")
    public R<java.util.List<RfProduct>> getMyProducts() {
        try {
            java.util.List<RfProduct> products = sellerService.getMyProducts();
            return R.ok(products, "Products retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve products: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的销售记录
     * 
     * @param page 页码
     * @param size 每页大小
     * @return 销售记录列表
     */
    @GetMapping("/my-sales")
    public R<java.util.List<RfProductSellRecord>> getMySales(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        try {
            java.util.List<RfProductSellRecord> sales = sellerService.getMySales(page, size);
            return R.ok(sales, "Sales records retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve sales records: " + e.getMessage());
        }
    }

    /**
     * 获取Stripe账户信息
     * 
     * @return Stripe账户信息
     */
    @GetMapping("/stripe-account/info")
    public R<SysUserStripeAccount> getStripeAccountInfo() {
        try {
            SysUserStripeAccount accountInfo = sellerService.getStripeAccountInfo();
            return R.ok(accountInfo, "Stripe account info retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve Stripe account info: " + e.getMessage());
        }
    }

    /**
     * 创建Stripe账户
     * 
     * @return 创建结果和账户设置链接
     */
    @PostMapping("/stripe-account/create")
    public R<Map<String, Object>> createStripeAccount() {
        try {
            Map<String, Object> result = sellerService.createStripeAccount();
            return R.ok(result, "Stripe account created successfully");
        } catch (Exception e) {
            return R.fail("Failed to create Stripe account: " + e.getMessage());
        }
    }

    /**
     * 刷新Stripe账户设置链接
     * 
     * @return 新的账户设置链接
     */
    @PostMapping("/stripe-account/refresh-link")
    public R<Map<String, Object>> refreshStripeAccountLink() {
        try {
            Map<String, Object> result = sellerService.refreshStripeAccountLink();
            return R.ok(result, "Account link refreshed successfully");
        } catch (Exception e) {
            return R.fail("Failed to refresh account link: " + e.getMessage());
        }
    }

    /**
     * 同步Stripe账户状态
     * 
     * @return 同步后的账户信息
     */
    @PostMapping("/stripe-account/sync-status")
    public R<SysUserStripeAccount> syncStripeAccountStatus() {
        try {
            SysUserStripeAccount accountInfo = sellerService.syncStripeAccountStatus();
            return R.ok(accountInfo, "Account status synced successfully");
        } catch (Exception e) {
            return R.fail("Failed to sync account status: " + e.getMessage());
        }
    }

    /**
     * 获取退货申请详情
     * 
     * @param sellRecordId 销售记录ID
     * @return 退货申请详情
     */
    @GetMapping("/return-request/{sellRecordId}")
    public R<Map<String, Object>> getReturnRequestDetail(@PathVariable Long sellRecordId) {
        try {
            Map<String, Object> returnRequestDetail = sellerService.getReturnRequestDetail(sellRecordId);
            return R.ok(returnRequestDetail, "Return request detail retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve return request detail: " + e.getMessage());
        }
    }

    /**
     * 处理退货申请
     * 
     * @param sellRecordId 销售记录ID
     * @param request 处理请求
     * @return 处理结果
     */
    @PostMapping("/return-request/{sellRecordId}/handle")
    public R<String> handleReturnRequest(@PathVariable Long sellRecordId, @RequestBody Map<String, Object> request) {
        try {
            boolean accept = (Boolean) request.get("accept");
            String sellerOpinion = (String) request.get("sellerOpinion");
            
            boolean success = sellerService.handleReturnRequest(sellRecordId, accept, sellerOpinion);
            
            if (success) {
                String message = accept ? "Return request accepted successfully" : "Return request rejected successfully";
                return R.ok("success", message);
            } else {
                return R.fail("Failed to process return request");
            }
        } catch (Exception e) {
            return R.fail("Failed to handle return request: " + e.getMessage());
        }
    }

    /**
     * 确认收到退货商品
     * 
     * @param sellRecordId 销售记录ID
     * @return 确认结果
     */
    @PostMapping("/return-confirm/{sellRecordId}")
    public R<String> confirmReturnReceived(@PathVariable Long sellRecordId) {
        try {
            boolean success = sellerService.confirmReturnReceived(sellRecordId);
            
            if (success) {
                return R.ok("success", "Return received confirmed successfully");
            } else {
                return R.fail("Failed to confirm return received");
            }
        } catch (Exception e) {
            return R.fail("Failed to confirm return received: " + e.getMessage());
        }
    }

    /**
     * 请求退回卖家
     * 
     * @param request 退回请求
     * @return 请求结果
     */
    @PostMapping("/request-return-to-seller")
    public R<String> requestReturnToSeller(@RequestBody Map<String, Object> request) {
        try {
            Long productId = Long.valueOf(request.get("productId").toString());
            String returnAddress = (String) request.get("returnAddress");
            
            boolean success = sellerService.requestReturnToSeller(productId, returnAddress);
            
            if (success) {
                return R.ok("success", "Return to seller request submitted successfully");
            } else {
                return R.fail("Failed to submit return to seller request");
            }
        } catch (Exception e) {
            return R.fail("Failed to request return to seller: " + e.getMessage());
        }
    }
} 