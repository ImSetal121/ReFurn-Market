package org.charno.reflip.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.service.IVisitorService;
import org.charno.system.service.ISysUserService;
import org.charno.common.entity.SysUser;
import org.charno.common.core.R;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

/**
 * 访客控制器
 */
@RestController
@RequestMapping("/api/visitor")
public class VisitorController {

    @Autowired
    private IVisitorService visitorService;
    
    @Autowired
    private ISysUserService sysUserService;

    /**
     * 搜索商品接口
     * 支持多条件查询和分页
     * 
     * @param keyword 搜索关键词
     * @param type 商品类型
     * @param category 商品类别
     * @param minPrice 最低价格
     * @param maxPrice 最高价格
     * @param sortBy 排序方式 (recommended, price_asc, price_desc, distance, condition)
     * @param page 页码 (默认1)
     * @param size 每页大小 (默认10)
     * @return 搜索结果
     */
    @GetMapping("/search")
    public R<Page<RfProduct>> searchProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice,
            @RequestParam(defaultValue = "recommended") String sortBy,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            Page<RfProduct> result = visitorService.searchProducts(
                keyword, type, category, minPrice, maxPrice, sortBy, page, size
            );
            return R.ok(result, "Products retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to search products: " + e.getMessage());
        }
    }

    /**
     * 获取热门搜索关键词
     * 
     * @return 热门关键词列表
     */
    @GetMapping("/hot-keywords")
    public R<java.util.List<String>> getHotKeywords() {
        try {
            java.util.List<String> keywords = visitorService.getHotKeywords();
            return R.ok(keywords, "Hot keywords retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to get hot keywords: " + e.getMessage());
        }
    }

    /**
     * 获取商品详情
     * 
     * @param productId 商品ID
     * @return 商品详情
     */
    @GetMapping("/product/{productId}")
    public R<RfProduct> getProductDetail(@PathVariable Long productId) {
        try {
            RfProduct product = visitorService.getProductDetail(productId);
            if (product != null) {
                return R.ok(product, "Product detail retrieved successfully");
            } else {
                return R.fail("Product not found");
            }
        } catch (Exception e) {
            return R.fail("Failed to get product detail: " + e.getMessage());
        }
    }

    /**
     * 获取用户公开信息
     * 
     * @param userId 用户ID
     * @return 用户公开信息
     */
    @GetMapping("/user/{userId}")
    public R<SysUser> getUserInfo(@PathVariable Long userId) {
        try {
            SysUser user = sysUserService.getPublicUserInfo(userId);
            if (user != null) {
                return R.ok(user, "User information retrieved successfully");
            } else {
                return R.fail("User not found");
            }
        } catch (Exception e) {
            return R.fail("Failed to get user information: " + e.getMessage());
        }
    }
} 