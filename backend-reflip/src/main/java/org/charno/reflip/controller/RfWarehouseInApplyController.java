package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfWarehouseInApply;
import org.charno.reflip.service.IRfWarehouseInApplyService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 仓库入库申请控制器
 */
@RestController
@RequestMapping("/api/rf/warehouse-in-apply")
public class RfWarehouseInApplyController {

    @Autowired
    private IRfWarehouseInApplyService rfWarehouseInApplyService;

    /**
     * 新增仓库入库申请
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfWarehouseInApply rfWarehouseInApply) {
        boolean result = rfWarehouseInApplyService.save(rfWarehouseInApply);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除仓库入库申请
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfWarehouseInApplyService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除仓库入库申请
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfWarehouseInApplyService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新仓库入库申请
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfWarehouseInApply rfWarehouseInApply) {
        boolean result = rfWarehouseInApplyService.updateById(rfWarehouseInApply);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询仓库入库申请
     */
    @GetMapping("/{id}")
    public R<RfWarehouseInApply> getById(@PathVariable Long id) {
        RfWarehouseInApply rfWarehouseInApply = rfWarehouseInApplyService.getById(id);
        return R.ok(rfWarehouseInApply);
    }

    /**
     * 分页条件查询仓库入库申请
     */
    @GetMapping("/page")
    public R<Page<RfWarehouseInApply>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfWarehouseInApply condition) {
        Page<RfWarehouseInApply> page = new Page<>(current, size);
        Page<RfWarehouseInApply> result = rfWarehouseInApplyService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询仓库入库申请
     */
    @GetMapping("/list")
    public R<List<RfWarehouseInApply>> selectListWithCondition(RfWarehouseInApply condition) {
        List<RfWarehouseInApply> result = rfWarehouseInApplyService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有仓库入库申请
     */
    @GetMapping("/all")
    public R<List<RfWarehouseInApply>> list() {
        List<RfWarehouseInApply> result = rfWarehouseInApplyService.list();
        return R.ok(result);
    }
} 