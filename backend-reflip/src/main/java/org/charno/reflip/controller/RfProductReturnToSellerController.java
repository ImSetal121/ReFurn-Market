package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductReturnToSeller;
import org.charno.reflip.service.IRfProductReturnToSellerService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品退回卖家记录控制器
 */
@RestController
@RequestMapping("/api/rf/product-return-to-seller")
public class RfProductReturnToSellerController {

    @Autowired
    private IRfProductReturnToSellerService rfProductReturnToSellerService;

    /**
     * 新增商品退回卖家记录
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductReturnToSeller rfProductReturnToSeller) {
        boolean result = rfProductReturnToSellerService.save(rfProductReturnToSeller);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品退回卖家记录
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductReturnToSellerService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品退回卖家记录
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductReturnToSellerService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品退回卖家记录
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductReturnToSeller rfProductReturnToSeller) {
        boolean result = rfProductReturnToSellerService.updateById(rfProductReturnToSeller);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品退回卖家记录
     */
    @GetMapping("/{id}")
    public R<RfProductReturnToSeller> getById(@PathVariable Long id) {
        RfProductReturnToSeller rfProductReturnToSeller = rfProductReturnToSellerService.getById(id);
        return R.ok(rfProductReturnToSeller);
    }

    /**
     * 分页条件查询商品退回卖家记录
     */
    @GetMapping("/page")
    public R<Page<RfProductReturnToSeller>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductReturnToSeller condition) {
        Page<RfProductReturnToSeller> page = new Page<>(current, size);
        Page<RfProductReturnToSeller> result = rfProductReturnToSellerService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品退回卖家记录
     */
    @GetMapping("/list")
    public R<List<RfProductReturnToSeller>> selectListWithCondition(RfProductReturnToSeller condition) {
        List<RfProductReturnToSeller> result = rfProductReturnToSellerService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品退回卖家记录
     */
    @GetMapping("/all")
    public R<List<RfProductReturnToSeller>> list() {
        List<RfProductReturnToSeller> result = rfProductReturnToSellerService.list();
        return R.ok(result);
    }
} 