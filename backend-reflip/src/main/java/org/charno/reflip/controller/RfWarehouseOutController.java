package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfWarehouseOut;
import org.charno.reflip.service.IRfWarehouseOutService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 仓库出库控制器
 */
@RestController
@RequestMapping("/api/rf/warehouse-out")
public class RfWarehouseOutController {

    @Autowired
    private IRfWarehouseOutService rfWarehouseOutService;

    /**
     * 新增仓库出库
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfWarehouseOut rfWarehouseOut) {
        boolean result = rfWarehouseOutService.save(rfWarehouseOut);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除仓库出库
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfWarehouseOutService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除仓库出库
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfWarehouseOutService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新仓库出库
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfWarehouseOut rfWarehouseOut) {
        boolean result = rfWarehouseOutService.updateById(rfWarehouseOut);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询仓库出库
     */
    @GetMapping("/{id}")
    public R<RfWarehouseOut> getById(@PathVariable Long id) {
        RfWarehouseOut rfWarehouseOut = rfWarehouseOutService.getById(id);
        return R.ok(rfWarehouseOut);
    }

    /**
     * 分页条件查询仓库出库
     */
    @GetMapping("/page")
    public R<Page<RfWarehouseOut>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfWarehouseOut condition) {
        Page<RfWarehouseOut> page = new Page<>(current, size);
        Page<RfWarehouseOut> result = rfWarehouseOutService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询仓库出库
     */
    @GetMapping("/list")
    public R<List<RfWarehouseOut>> selectListWithCondition(RfWarehouseOut condition) {
        List<RfWarehouseOut> result = rfWarehouseOutService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有仓库出库
     */
    @GetMapping("/all")
    public R<List<RfWarehouseOut>> list() {
        List<RfWarehouseOut> result = rfWarehouseOutService.list();
        return R.ok(result);
    }
} 