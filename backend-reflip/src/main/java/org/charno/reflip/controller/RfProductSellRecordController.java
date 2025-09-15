package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.reflip.service.IRfProductSellRecordService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品销售记录控制器
 */
@RestController
@RequestMapping("/api/rf/product-sell-record")
public class RfProductSellRecordController {

    @Autowired
    private IRfProductSellRecordService rfProductSellRecordService;

    /**
     * 新增商品销售记录
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductSellRecord rfProductSellRecord) {
        boolean result = rfProductSellRecordService.save(rfProductSellRecord);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品销售记录
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductSellRecordService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品销售记录
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductSellRecordService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品销售记录
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductSellRecord rfProductSellRecord) {
        boolean result = rfProductSellRecordService.updateById(rfProductSellRecord);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品销售记录
     */
    @GetMapping("/{id}")
    public R<RfProductSellRecord> getById(@PathVariable Long id) {
        RfProductSellRecord rfProductSellRecord = rfProductSellRecordService.getById(id);
        return R.ok(rfProductSellRecord);
    }

    /**
     * 分页条件查询商品销售记录
     */
    @GetMapping("/page")
    public R<Page<RfProductSellRecord>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductSellRecord condition) {
        Page<RfProductSellRecord> page = new Page<>(current, size);
        Page<RfProductSellRecord> result = rfProductSellRecordService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品销售记录
     */
    @GetMapping("/list")
    public R<List<RfProductSellRecord>> selectListWithCondition(RfProductSellRecord condition) {
        List<RfProductSellRecord> result = rfProductSellRecordService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品销售记录
     */
    @GetMapping("/all")
    public R<List<RfProductSellRecord>> list() {
        List<RfProductSellRecord> result = rfProductSellRecordService.list();
        return R.ok(result);
    }
} 