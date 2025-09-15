package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductAuctionLogistics;
import org.charno.reflip.service.IRfProductAuctionLogisticsService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品拍卖物流控制器
 */
@RestController
@RequestMapping("/api/rf/product-auction-logistics")
public class RfProductAuctionLogisticsController {

    @Autowired
    private IRfProductAuctionLogisticsService rfProductAuctionLogisticsService;

    /**
     * 新增商品拍卖物流
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductAuctionLogistics rfProductAuctionLogistics) {
        boolean result = rfProductAuctionLogisticsService.save(rfProductAuctionLogistics);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品拍卖物流
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductAuctionLogisticsService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品拍卖物流
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductAuctionLogisticsService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品拍卖物流
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductAuctionLogistics rfProductAuctionLogistics) {
        boolean result = rfProductAuctionLogisticsService.updateById(rfProductAuctionLogistics);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品拍卖物流
     */
    @GetMapping("/{id}")
    public R<RfProductAuctionLogistics> getById(@PathVariable Long id) {
        RfProductAuctionLogistics rfProductAuctionLogistics = rfProductAuctionLogisticsService.getById(id);
        return R.ok(rfProductAuctionLogistics);
    }

    /**
     * 分页条件查询商品拍卖物流
     */
    @GetMapping("/page")
    public R<Page<RfProductAuctionLogistics>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductAuctionLogistics condition) {
        Page<RfProductAuctionLogistics> page = new Page<>(current, size);
        Page<RfProductAuctionLogistics> result = rfProductAuctionLogisticsService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品拍卖物流
     */
    @GetMapping("/list")
    public R<List<RfProductAuctionLogistics>> selectListWithCondition(RfProductAuctionLogistics condition) {
        List<RfProductAuctionLogistics> result = rfProductAuctionLogisticsService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品拍卖物流
     */
    @GetMapping("/all")
    public R<List<RfProductAuctionLogistics>> list() {
        List<RfProductAuctionLogistics> result = rfProductAuctionLogisticsService.list();
        return R.ok(result);
    }
} 