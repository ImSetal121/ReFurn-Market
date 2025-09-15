package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfWarehouseCost;
import org.charno.reflip.service.IRfWarehouseCostService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 仓库费用控制器
 */
@RestController
@RequestMapping("/api/rf/warehouse-cost")
public class RfWarehouseCostController {

    @Autowired
    private IRfWarehouseCostService rfWarehouseCostService;

    /**
     * 新增仓库费用
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfWarehouseCost rfWarehouseCost) {
        boolean result = rfWarehouseCostService.save(rfWarehouseCost);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除仓库费用
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfWarehouseCostService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除仓库费用
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfWarehouseCostService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新仓库费用
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfWarehouseCost rfWarehouseCost) {
        boolean result = rfWarehouseCostService.updateById(rfWarehouseCost);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询仓库费用
     */
    @GetMapping("/{id}")
    public R<RfWarehouseCost> getById(@PathVariable Long id) {
        RfWarehouseCost rfWarehouseCost = rfWarehouseCostService.getById(id);
        return R.ok(rfWarehouseCost);
    }

    /**
     * 分页条件查询仓库费用
     */
    @GetMapping("/page")
    public R<Page<RfWarehouseCost>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfWarehouseCost condition) {
        Page<RfWarehouseCost> page = new Page<>(current, size);
        Page<RfWarehouseCost> result = rfWarehouseCostService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询仓库费用
     */
    @GetMapping("/list")
    public R<List<RfWarehouseCost>> selectListWithCondition(RfWarehouseCost condition) {
        List<RfWarehouseCost> result = rfWarehouseCostService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有仓库费用
     */
    @GetMapping("/all")
    public R<List<RfWarehouseCost>> list() {
        List<RfWarehouseCost> result = rfWarehouseCostService.list();
        return R.ok(result);
    }
} 