package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfPurchaseReview;
import org.charno.reflip.service.IRfPurchaseReviewService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 购买评价控制器
 */
@RestController
@RequestMapping("/api/rf/purchase-review")
public class RfPurchaseReviewController {

    @Autowired
    private IRfPurchaseReviewService rfPurchaseReviewService;

    /**
     * 新增购买评价
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfPurchaseReview rfPurchaseReview) {
        boolean result = rfPurchaseReviewService.save(rfPurchaseReview);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除购买评价
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfPurchaseReviewService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除购买评价
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfPurchaseReviewService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新购买评价
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfPurchaseReview rfPurchaseReview) {
        boolean result = rfPurchaseReviewService.updateById(rfPurchaseReview);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询购买评价
     */
    @GetMapping("/{id}")
    public R<RfPurchaseReview> getById(@PathVariable Long id) {
        RfPurchaseReview rfPurchaseReview = rfPurchaseReviewService.getById(id);
        return R.ok(rfPurchaseReview);
    }

    /**
     * 分页条件查询购买评价
     */
    @GetMapping("/page")
    public R<Page<RfPurchaseReview>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfPurchaseReview condition) {
        Page<RfPurchaseReview> page = new Page<>(current, size);
        Page<RfPurchaseReview> result = rfPurchaseReviewService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询购买评价
     */
    @GetMapping("/list")
    public R<List<RfPurchaseReview>> selectListWithCondition(RfPurchaseReview condition) {
        List<RfPurchaseReview> result = rfPurchaseReviewService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有购买评价
     */
    @GetMapping("/all")
    public R<List<RfPurchaseReview>> list() {
        List<RfPurchaseReview> result = rfPurchaseReviewService.list();
        return R.ok(result);
    }
} 