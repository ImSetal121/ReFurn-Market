package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfBillItem;
import org.charno.reflip.service.IRfBillItemService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 账单项控制器
 */
@RestController
@RequestMapping("/api/rf/bill-item")
public class RfBillItemController {

    @Autowired
    private IRfBillItemService rfBillItemService;

    /**
     * 新增账单项
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfBillItem rfBillItem) {
        boolean result = rfBillItemService.save(rfBillItem);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除账单项
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfBillItemService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除账单项
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfBillItemService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新账单项
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfBillItem rfBillItem) {
        boolean result = rfBillItemService.updateById(rfBillItem);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询账单项
     */
    @GetMapping("/{id}")
    public R<RfBillItem> getById(@PathVariable Long id) {
        RfBillItem rfBillItem = rfBillItemService.getById(id);
        return R.ok(rfBillItem);
    }

    /**
     * 分页条件查询账单项
     */
    @GetMapping("/page")
    public R<Page<RfBillItem>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfBillItem condition) {
        Page<RfBillItem> page = new Page<>(current, size);
        Page<RfBillItem> result = rfBillItemService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询账单项
     */
    @GetMapping("/list")
    public R<List<RfBillItem>> selectListWithCondition(RfBillItem condition) {
        List<RfBillItem> result = rfBillItemService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有账单项
     */
    @GetMapping("/all")
    public R<List<RfBillItem>> list() {
        List<RfBillItem> result = rfBillItemService.list();
        return R.ok(result);
    }
} 