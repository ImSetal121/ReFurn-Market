package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfWarehouse;
import org.charno.reflip.service.IRfWarehouseService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 仓库控制器
 */
@RestController
@RequestMapping("/api/rf/warehouse")
public class RfWarehouseController {

    @Autowired
    private IRfWarehouseService rfWarehouseService;

    /**
     * 新增仓库
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfWarehouse rfWarehouse) {
        boolean result = rfWarehouseService.save(rfWarehouse);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除仓库
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfWarehouseService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除仓库
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfWarehouseService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新仓库
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfWarehouse rfWarehouse) {
        boolean result = rfWarehouseService.updateById(rfWarehouse);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询仓库
     */
    @GetMapping("/{id}")
    public R<RfWarehouse> getById(@PathVariable Long id) {
        RfWarehouse rfWarehouse = rfWarehouseService.getById(id);
        return R.ok(rfWarehouse);
    }

    /**
     * 分页条件查询仓库
     */
    @GetMapping("/page")
    public R<Page<RfWarehouse>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfWarehouse condition) {
        Page<RfWarehouse> page = new Page<>(current, size);
        Page<RfWarehouse> result = rfWarehouseService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询仓库
     */
    @GetMapping("/list")
    public R<List<RfWarehouse>> selectListWithCondition(RfWarehouse condition) {
        List<RfWarehouse> result = rfWarehouseService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有仓库
     */
    @GetMapping("/all")
    public R<List<RfWarehouse>> list() {
        List<RfWarehouse> result = rfWarehouseService.list();
        return R.ok(result);
    }
} 