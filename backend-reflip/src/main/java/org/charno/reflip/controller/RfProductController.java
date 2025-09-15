package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.service.IRfProductService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品控制器
 */
@RestController
@RequestMapping("/api/rf/product")
public class RfProductController {

    @Autowired
    private IRfProductService rfProductService;

    /**
     * 新增商品
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProduct rfProduct) {
        boolean result = rfProductService.save(rfProduct);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProduct rfProduct) {
        boolean result = rfProductService.updateById(rfProduct);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品
     */
    @GetMapping("/{id}")
    public R<RfProduct> getById(@PathVariable Long id) {
        RfProduct rfProduct = rfProductService.getById(id);
        return R.ok(rfProduct);
    }

    /**
     * 分页条件查询商品
     */
    @GetMapping("/page")
    public R<Page<RfProduct>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProduct condition) {
        Page<RfProduct> page = new Page<>(current, size);
        Page<RfProduct> result = rfProductService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品
     */
    @GetMapping("/list")
    public R<List<RfProduct>> selectListWithCondition(RfProduct condition) {
        List<RfProduct> result = rfProductService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品
     */
    @GetMapping("/all")
    public R<List<RfProduct>> list() {
        List<RfProduct> result = rfProductService.list();
        return R.ok(result);
    }
} 