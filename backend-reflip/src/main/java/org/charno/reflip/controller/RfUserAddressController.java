package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfUserAddress;
import org.charno.reflip.service.IRfUserAddressService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 用户地址控制器
 */
@RestController
@RequestMapping("/api/rf/user-address")
public class RfUserAddressController {

    @Autowired
    private IRfUserAddressService rfUserAddressService;

    /**
     * 新增用户地址
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfUserAddress rfUserAddress) {
        boolean result = rfUserAddressService.save(rfUserAddress);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除用户地址
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfUserAddressService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除用户地址
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfUserAddressService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新用户地址
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfUserAddress rfUserAddress) {
        boolean result = rfUserAddressService.updateById(rfUserAddress);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询用户地址
     */
    @GetMapping("/{id}")
    public R<RfUserAddress> getById(@PathVariable Long id) {
        RfUserAddress rfUserAddress = rfUserAddressService.getById(id);
        return R.ok(rfUserAddress);
    }

    /**
     * 分页条件查询用户地址
     */
    @GetMapping("/page")
    public R<Page<RfUserAddress>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfUserAddress condition) {
        Page<RfUserAddress> page = new Page<>(current, size);
        Page<RfUserAddress> result = rfUserAddressService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询用户地址
     */
    @GetMapping("/list")
    public R<List<RfUserAddress>> selectListWithCondition(RfUserAddress condition) {
        List<RfUserAddress> result = rfUserAddressService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有用户地址
     */
    @GetMapping("/all")
    public R<List<RfUserAddress>> list() {
        List<RfUserAddress> result = rfUserAddressService.list();
        return R.ok(result);
    }
} 