package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfInternalLogisticsTask;
import org.charno.reflip.service.IRfInternalLogisticsTaskService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 内部物流任务控制器
 */
@RestController
@RequestMapping("/api/rf/internal-logistics-task")
public class RfInternalLogisticsTaskController {

    @Autowired
    private IRfInternalLogisticsTaskService rfInternalLogisticsTaskService;

    /**
     * 新增内部物流任务
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfInternalLogisticsTask rfInternalLogisticsTask) {
        boolean result = rfInternalLogisticsTaskService.save(rfInternalLogisticsTask);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除内部物流任务
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfInternalLogisticsTaskService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除内部物流任务
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfInternalLogisticsTaskService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新内部物流任务
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfInternalLogisticsTask rfInternalLogisticsTask) {
        boolean result = rfInternalLogisticsTaskService.updateById(rfInternalLogisticsTask);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询内部物流任务
     */
    @GetMapping("/{id}")
    public R<RfInternalLogisticsTask> getById(@PathVariable Long id) {
        RfInternalLogisticsTask rfInternalLogisticsTask = rfInternalLogisticsTaskService.getById(id);
        return R.ok(rfInternalLogisticsTask);
    }

    /**
     * 分页条件查询内部物流任务
     */
    @GetMapping("/page")
    public R<Page<RfInternalLogisticsTask>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfInternalLogisticsTask condition) {
        Page<RfInternalLogisticsTask> page = new Page<>(current, size);
        Page<RfInternalLogisticsTask> result = rfInternalLogisticsTaskService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询内部物流任务
     */
    @GetMapping("/list")
    public R<List<RfInternalLogisticsTask>> selectListWithCondition(RfInternalLogisticsTask condition) {
        List<RfInternalLogisticsTask> result = rfInternalLogisticsTaskService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有内部物流任务
     */
    @GetMapping("/all")
    public R<List<RfInternalLogisticsTask>> list() {
        List<RfInternalLogisticsTask> result = rfInternalLogisticsTaskService.list();
        return R.ok(result);
    }
} 