package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfUserFavoriteProduct;
import org.charno.reflip.service.IRfUserFavoriteProductService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 用户收藏商品控制器
 */
@RestController
@RequestMapping("/api/rf/user-favorite-product")
public class RfUserFavoriteProductController {

    @Autowired
    private IRfUserFavoriteProductService rfUserFavoriteProductService;

    /**
     * 用户收藏商品
     */
    @PostMapping("/add/{userId}/{productId}")
    public R<Boolean> addFavorite(@PathVariable Long userId, @PathVariable Long productId) {
        boolean result = rfUserFavoriteProductService.addFavorite(userId, productId);
        return result ? R.ok(result) : R.fail("收藏失败");
    }

    /**
     * 用户取消收藏商品
     */
    @DeleteMapping("/remove/{userId}/{productId}")
    public R<Boolean> removeFavorite(@PathVariable Long userId, @PathVariable Long productId) {
        boolean result = rfUserFavoriteProductService.removeFavorite(userId, productId);
        return result ? R.ok(result) : R.fail("取消收藏失败");
    }

    /**
     * 批量取消收藏
     */
    @DeleteMapping("/remove-batch/{userId}")
    public R<Boolean> removeFavoritesBatch(@PathVariable Long userId, @RequestBody List<Long> productIds) {
        boolean result = rfUserFavoriteProductService.removeFavoritesBatch(userId, productIds);
        return result ? R.ok(result) : R.fail("批量取消收藏失败");
    }

    /**
     * 判断用户是否已收藏某商品
     */
    @GetMapping("/is-favorited/{userId}/{productId}")
    public R<Boolean> isFavorited(@PathVariable Long userId, @PathVariable Long productId) {
        boolean result = rfUserFavoriteProductService.isFavorited(userId, productId);
        return R.ok(result);
    }

    /**
     * 获取用户的所有收藏商品
     */
    @GetMapping("/user/{userId}")
    public R<List<RfUserFavoriteProduct>> getUserFavorites(@PathVariable Long userId) {
        List<RfUserFavoriteProduct> result = rfUserFavoriteProductService.getUserFavorites(userId);
        return R.ok(result);
    }

    /**
     * 分页获取用户的收藏商品
     */
    @GetMapping("/user/{userId}/page")
    public R<Page<RfUserFavoriteProduct>> getUserFavoritesPage(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "20") Integer size) {
        Page<RfUserFavoriteProduct> page = new Page<>(current, size);
        Page<RfUserFavoriteProduct> result = rfUserFavoriteProductService.getUserFavoritesPage(page, userId);
        return R.ok(result);
    }

    /**
     * 获取商品的收藏用户列表
     */
    @GetMapping("/product/{productId}")
    public R<List<RfUserFavoriteProduct>> getProductFavorites(@PathVariable Long productId) {
        List<RfUserFavoriteProduct> result = rfUserFavoriteProductService.getProductFavorites(productId);
        return R.ok(result);
    }

    /**
     * 获取用户收藏商品数量
     */
    @GetMapping("/user/{userId}/count")
    public R<Long> getUserFavoriteCount(@PathVariable Long userId) {
        Long count = rfUserFavoriteProductService.getUserFavoriteCount(userId);
        return R.ok(count);
    }

    /**
     * 获取商品被收藏次数
     */
    @GetMapping("/product/{productId}/count")
    public R<Long> getProductFavoriteCount(@PathVariable Long productId) {
        Long count = rfUserFavoriteProductService.getProductFavoriteCount(productId);
        return R.ok(count);
    }

    /**
     * 根据ID删除收藏记录
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfUserFavoriteProductService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除收藏记录
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfUserFavoriteProductService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新收藏记录
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfUserFavoriteProduct rfUserFavoriteProduct) {
        boolean result = rfUserFavoriteProductService.updateById(rfUserFavoriteProduct);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询收藏记录
     */
    @GetMapping("/{id}")
    public R<RfUserFavoriteProduct> getById(@PathVariable Long id) {
        RfUserFavoriteProduct rfUserFavoriteProduct = rfUserFavoriteProductService.getById(id);
        return R.ok(rfUserFavoriteProduct);
    }

    /**
     * 分页条件查询收藏记录
     */
    @GetMapping("/page")
    public R<Page<RfUserFavoriteProduct>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfUserFavoriteProduct condition) {
        Page<RfUserFavoriteProduct> page = new Page<>(current, size);
        Page<RfUserFavoriteProduct> result = rfUserFavoriteProductService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询收藏记录
     */
    @GetMapping("/list")
    public R<List<RfUserFavoriteProduct>> selectListWithCondition(RfUserFavoriteProduct condition) {
        List<RfUserFavoriteProduct> result = rfUserFavoriteProductService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有收藏记录
     */
    @GetMapping("/all")
    public R<List<RfUserFavoriteProduct>> list() {
        List<RfUserFavoriteProduct> result = rfUserFavoriteProductService.list();
        return R.ok(result);
    }
}