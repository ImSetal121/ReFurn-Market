package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductSelfPickupLogistics;
import org.charno.reflip.service.IRfProductSelfPickupLogisticsService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品自提物流控制器
 */
@RestController
@RequestMapping("/api/rf/product-self-pickup-logistics")
public class RfProductSelfPickupLogisticsController {

    @Autowired
    private IRfProductSelfPickupLogisticsService rfProductSelfPickupLogisticsService;

    /**
     * 新增商品自提物流
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductSelfPickupLogistics rfProductSelfPickupLogistics) {
        boolean result = rfProductSelfPickupLogisticsService.save(rfProductSelfPickupLogistics);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品自提物流
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductSelfPickupLogisticsService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品自提物流
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductSelfPickupLogisticsService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品自提物流
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductSelfPickupLogistics rfProductSelfPickupLogistics) {
        boolean result = rfProductSelfPickupLogisticsService.updateById(rfProductSelfPickupLogistics);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品自提物流
     */
    @GetMapping("/{id}")
    public R<RfProductSelfPickupLogistics> getById(@PathVariable Long id) {
        RfProductSelfPickupLogistics rfProductSelfPickupLogistics = rfProductSelfPickupLogisticsService.getById(id);
        return R.ok(rfProductSelfPickupLogistics);
    }

    /**
     * 分页条件查询商品自提物流
     */
    @GetMapping("/page")
    public R<Page<RfProductSelfPickupLogistics>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductSelfPickupLogistics condition) {
        Page<RfProductSelfPickupLogistics> page = new Page<>(current, size);
        Page<RfProductSelfPickupLogistics> result = rfProductSelfPickupLogisticsService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品自提物流
     */
    @GetMapping("/list")
    public R<List<RfProductSelfPickupLogistics>> selectListWithCondition(RfProductSelfPickupLogistics condition) {
        List<RfProductSelfPickupLogistics> result = rfProductSelfPickupLogisticsService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品自提物流
     */
    @GetMapping("/all")
    public R<List<RfProductSelfPickupLogistics>> list() {
        List<RfProductSelfPickupLogistics> result = rfProductSelfPickupLogisticsService.list();
        return R.ok(result);
    }
} 