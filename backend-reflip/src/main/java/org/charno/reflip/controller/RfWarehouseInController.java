package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfWarehouseIn;
import org.charno.reflip.service.IRfWarehouseInService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 仓库入库控制器
 */
@RestController
@RequestMapping("/api/rf/warehouse-in")
public class RfWarehouseInController {

    @Autowired
    private IRfWarehouseInService rfWarehouseInService;

    /**
     * 新增仓库入库
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfWarehouseIn rfWarehouseIn) {
        boolean result = rfWarehouseInService.save(rfWarehouseIn);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除仓库入库
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfWarehouseInService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除仓库入库
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfWarehouseInService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新仓库入库
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfWarehouseIn rfWarehouseIn) {
        boolean result = rfWarehouseInService.updateById(rfWarehouseIn);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询仓库入库
     */
    @GetMapping("/{id}")
    public R<RfWarehouseIn> getById(@PathVariable Long id) {
        RfWarehouseIn rfWarehouseIn = rfWarehouseInService.getById(id);
        return R.ok(rfWarehouseIn);
    }

    /**
     * 分页条件查询仓库入库
     */
    @GetMapping("/page")
    public R<Page<RfWarehouseIn>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfWarehouseIn condition) {
        Page<RfWarehouseIn> page = new Page<>(current, size);
        Page<RfWarehouseIn> result = rfWarehouseInService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询仓库入库
     */
    @GetMapping("/list")
    public R<List<RfWarehouseIn>> selectListWithCondition(RfWarehouseIn condition) {
        List<RfWarehouseIn> result = rfWarehouseInService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有仓库入库
     */
    @GetMapping("/all")
    public R<List<RfWarehouseIn>> list() {
        List<RfWarehouseIn> result = rfWarehouseInService.list();
        return R.ok(result);
    }
} 