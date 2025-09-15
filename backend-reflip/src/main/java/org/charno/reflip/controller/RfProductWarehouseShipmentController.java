package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductWarehouseShipment;
import org.charno.reflip.service.IRfProductWarehouseShipmentService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品仓库发货控制器
 */
@RestController
@RequestMapping("/api/rf/product-warehouse-shipment")
public class RfProductWarehouseShipmentController {

    @Autowired
    private IRfProductWarehouseShipmentService rfProductWarehouseShipmentService;

    /**
     * 新增商品仓库发货
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductWarehouseShipment rfProductWarehouseShipment) {
        boolean result = rfProductWarehouseShipmentService.save(rfProductWarehouseShipment);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品仓库发货
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductWarehouseShipmentService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品仓库发货
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductWarehouseShipmentService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品仓库发货
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductWarehouseShipment rfProductWarehouseShipment) {
        boolean result = rfProductWarehouseShipmentService.updateById(rfProductWarehouseShipment);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品仓库发货
     */
    @GetMapping("/{id}")
    public R<RfProductWarehouseShipment> getById(@PathVariable Long id) {
        RfProductWarehouseShipment rfProductWarehouseShipment = rfProductWarehouseShipmentService.getById(id);
        return R.ok(rfProductWarehouseShipment);
    }

    /**
     * 分页条件查询商品仓库发货
     */
    @GetMapping("/page")
    public R<Page<RfProductWarehouseShipment>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductWarehouseShipment condition) {
        Page<RfProductWarehouseShipment> page = new Page<>(current, size);
        Page<RfProductWarehouseShipment> result = rfProductWarehouseShipmentService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品仓库发货
     */
    @GetMapping("/list")
    public R<List<RfProductWarehouseShipment>> selectListWithCondition(RfProductWarehouseShipment condition) {
        List<RfProductWarehouseShipment> result = rfProductWarehouseShipmentService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品仓库发货
     */
    @GetMapping("/all")
    public R<List<RfProductWarehouseShipment>> list() {
        List<RfProductWarehouseShipment> result = rfProductWarehouseShipmentService.list();
        return R.ok(result);
    }
} 