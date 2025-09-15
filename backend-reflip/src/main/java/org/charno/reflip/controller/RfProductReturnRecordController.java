package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductReturnRecord;
import org.charno.reflip.service.IRfProductReturnRecordService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品退货记录控制器
 */
@RestController
@RequestMapping("/api/rf/product-return-record")
public class RfProductReturnRecordController {

    @Autowired
    private IRfProductReturnRecordService rfProductReturnRecordService;

    /**
     * 新增商品退货记录
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductReturnRecord rfProductReturnRecord) {
        boolean result = rfProductReturnRecordService.save(rfProductReturnRecord);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品退货记录
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductReturnRecordService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品退货记录
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductReturnRecordService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品退货记录
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductReturnRecord rfProductReturnRecord) {
        boolean result = rfProductReturnRecordService.updateById(rfProductReturnRecord);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品退货记录
     */
    @GetMapping("/{id}")
    public R<RfProductReturnRecord> getById(@PathVariable Long id) {
        RfProductReturnRecord rfProductReturnRecord = rfProductReturnRecordService.getById(id);
        return R.ok(rfProductReturnRecord);
    }

    /**
     * 分页条件查询商品退货记录
     */
    @GetMapping("/page")
    public R<Page<RfProductReturnRecord>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductReturnRecord condition) {
        Page<RfProductReturnRecord> page = new Page<>(current, size);
        Page<RfProductReturnRecord> result = rfProductReturnRecordService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品退货记录
     */
    @GetMapping("/list")
    public R<List<RfProductReturnRecord>> selectListWithCondition(RfProductReturnRecord condition) {
        List<RfProductReturnRecord> result = rfProductReturnRecordService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品退货记录
     */
    @GetMapping("/all")
    public R<List<RfProductReturnRecord>> list() {
        List<RfProductReturnRecord> result = rfProductReturnRecordService.list();
        return R.ok(result);
    }
} 