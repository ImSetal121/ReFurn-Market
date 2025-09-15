package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfWarehouseStock;
import org.charno.reflip.service.IRfWarehouseStockService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 仓库库存控制器
 */
@RestController
@RequestMapping("/api/rf/warehouse-stock")
public class RfWarehouseStockController {

    @Autowired
    private IRfWarehouseStockService rfWarehouseStockService;

    /**
     * 新增仓库库存
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfWarehouseStock rfWarehouseStock) {
        boolean result = rfWarehouseStockService.save(rfWarehouseStock);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除仓库库存
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfWarehouseStockService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除仓库库存
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfWarehouseStockService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新仓库库存
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfWarehouseStock rfWarehouseStock) {
        boolean result = rfWarehouseStockService.updateById(rfWarehouseStock);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询仓库库存
     */
    @GetMapping("/{id}")
    public R<RfWarehouseStock> getById(@PathVariable Long id) {
        RfWarehouseStock rfWarehouseStock = rfWarehouseStockService.getById(id);
        return R.ok(rfWarehouseStock);
    }

    /**
     * 分页条件查询仓库库存
     */
    @GetMapping("/page")
    public R<Page<RfWarehouseStock>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfWarehouseStock condition) {
        Page<RfWarehouseStock> page = new Page<>(current, size);
        Page<RfWarehouseStock> result = rfWarehouseStockService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询仓库库存
     */
    @GetMapping("/list")
    public R<List<RfWarehouseStock>> selectListWithCondition(RfWarehouseStock condition) {
        List<RfWarehouseStock> result = rfWarehouseStockService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有仓库库存
     */
    @GetMapping("/all")
    public R<List<RfWarehouseStock>> list() {
        List<RfWarehouseStock> result = rfWarehouseStockService.list();
        return R.ok(result);
    }
} 