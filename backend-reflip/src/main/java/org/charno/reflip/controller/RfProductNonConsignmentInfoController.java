package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductNonConsignmentInfo;
import org.charno.reflip.service.IRfProductNonConsignmentInfoService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 非寄卖信息控制器
 */
@RestController
@RequestMapping("/api/rf/product-non-consignment-info")
public class RfProductNonConsignmentInfoController {

    @Autowired
    private IRfProductNonConsignmentInfoService rfProductNonConsignmentInfoService;

    /**
     * 新增非寄卖信息
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductNonConsignmentInfo rfProductNonConsignmentInfo) {
        boolean result = rfProductNonConsignmentInfoService.save(rfProductNonConsignmentInfo);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除非寄卖信息
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductNonConsignmentInfoService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除非寄卖信息
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductNonConsignmentInfoService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新非寄卖信息
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductNonConsignmentInfo rfProductNonConsignmentInfo) {
        boolean result = rfProductNonConsignmentInfoService.updateById(rfProductNonConsignmentInfo);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询非寄卖信息
     */
    @GetMapping("/{id}")
    public R<RfProductNonConsignmentInfo> getById(@PathVariable Long id) {
        RfProductNonConsignmentInfo rfProductNonConsignmentInfo = rfProductNonConsignmentInfoService.getById(id);
        return R.ok(rfProductNonConsignmentInfo);
    }

    /**
     * 分页条件查询非寄卖信息
     */
    @GetMapping("/page")
    public R<Page<RfProductNonConsignmentInfo>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductNonConsignmentInfo condition) {
        Page<RfProductNonConsignmentInfo> page = new Page<>(current, size);
        Page<RfProductNonConsignmentInfo> result = rfProductNonConsignmentInfoService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询非寄卖信息
     */
    @GetMapping("/list")
    public R<List<RfProductNonConsignmentInfo>> selectListWithCondition(RfProductNonConsignmentInfo condition) {
        List<RfProductNonConsignmentInfo> result = rfProductNonConsignmentInfoService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有非寄卖信息
     */
    @GetMapping("/all")
    public R<List<RfProductNonConsignmentInfo>> list() {
        List<RfProductNonConsignmentInfo> result = rfProductNonConsignmentInfoService.list();
        return R.ok(result);
    }
} 