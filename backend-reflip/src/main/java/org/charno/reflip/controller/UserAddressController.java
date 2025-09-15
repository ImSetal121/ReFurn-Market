package org.charno.reflip.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfUserAddress;
import org.charno.reflip.service.IUserAddressService;
import org.charno.common.core.R;
import org.charno.common.core.ResultCode;

import java.util.List;

/**
 * 用户地址控制器（用户端）
 */
@RestController
@RequestMapping("/api/user/address")
public class UserAddressController {

    @Autowired
    private IUserAddressService userAddressService;

    /**
     * 获取当前用户的地址列表
     */
    @GetMapping("/list")
    public R<List<RfUserAddress>> getUserAddressList() {
        try {
            List<RfUserAddress> addresses = userAddressService.getUserAddressList();
            return R.ok(addresses);
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    /**
     * 获取当前用户的默认地址
     */
    @GetMapping("/default")
    public R<RfUserAddress> getDefaultAddress() {
        try {
            RfUserAddress address = userAddressService.getDefaultAddress();
            return R.ok(address);
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    /**
     * 根据ID获取地址详情
     */
    @GetMapping("/{id}")
    public R<RfUserAddress> getAddressById(@PathVariable Long id) {
        try {
            RfUserAddress address = userAddressService.getAddressById(id);
            return R.ok(address);
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    /**
     * 添加地址
     */
    @PostMapping
    public R<Boolean> addAddress(@RequestBody RfUserAddress address) {
        try {
            boolean result = userAddressService.addAddress(address);
            return result ? R.ok(result, "地址添加成功") : R.fail("地址添加失败");
        } catch (RuntimeException e) {
            return R.fail(ResultCode.VALIDATE_FAILED, e.getMessage());
        }
    }

    /**
     * 更新地址
     */
    @PutMapping
    public R<Boolean> updateAddress(@RequestBody RfUserAddress address) {
        try {
            boolean result = userAddressService.updateAddress(address);
            return result ? R.ok(result, "地址更新成功") : R.fail("地址更新失败");
        } catch (RuntimeException e) {
            return R.fail(ResultCode.VALIDATE_FAILED, e.getMessage());
        }
    }

    /**
     * 删除地址
     */
    @DeleteMapping("/{id}")
    public R<Boolean> deleteAddress(@PathVariable Long id) {
        try {
            boolean result = userAddressService.deleteAddress(id);
            return result ? R.ok(result, "地址删除成功") : R.fail("地址删除失败");
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }

    /**
     * 设置默认地址
     */
    @PutMapping("/{id}/default")
    public R<Boolean> setDefaultAddress(@PathVariable Long id) {
        try {
            boolean result = userAddressService.setDefaultAddress(id);
            return result ? R.ok(result, "默认地址设置成功") : R.fail("默认地址设置失败");
        } catch (RuntimeException e) {
            return R.fail(e.getMessage());
        }
    }
} 