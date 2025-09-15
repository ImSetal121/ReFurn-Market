package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductCategory;
import org.charno.reflip.service.IRfProductCategoryService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品分类控制器
 */
@RestController
@RequestMapping("/api/rf/product-category")
public class RfProductCategoryController {

    @Autowired
    private IRfProductCategoryService rfProductCategoryService;

    /**
     * 新增商品分类
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductCategory rfProductCategory) {
        boolean result = rfProductCategoryService.save(rfProductCategory);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品分类
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductCategoryService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品分类
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductCategoryService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品分类
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductCategory rfProductCategory) {
        boolean result = rfProductCategoryService.updateById(rfProductCategory);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品分类
     */
    @GetMapping("/{id}")
    public R<RfProductCategory> getById(@PathVariable Long id) {
        RfProductCategory rfProductCategory = rfProductCategoryService.getById(id);
        return R.ok(rfProductCategory);
    }

    /**
     * 分页条件查询商品分类
     */
    @GetMapping("/page")
    public R<Page<RfProductCategory>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductCategory condition) {
        Page<RfProductCategory> page = new Page<>(current, size);
        Page<RfProductCategory> result = rfProductCategoryService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品分类
     */
    @GetMapping("/list")
    public R<List<RfProductCategory>> selectListWithCondition(RfProductCategory condition) {
        List<RfProductCategory> result = rfProductCategoryService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品分类
     */
    @GetMapping("/all")
    public R<List<RfProductCategory>> list() {
        List<RfProductCategory> result = rfProductCategoryService.list();
        return R.ok(result);
    }
} 