package org.charno.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.system.service.ISysUserStripeAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.common.entity.SysUserStripeAccount;
import org.charno.common.core.R;

import java.util.List;

/**
 * 用户Stripe Express账户控制器
 */
@RestController
@RequestMapping("/api/sys/user-stripe-account")
public class SysUserStripeAccountController {

    @Autowired
    private ISysUserStripeAccountService sysUserStripeAccountService;

    /**
     * 新增用户Stripe账户
     */
    @PostMapping
    public R<Boolean> save(@RequestBody SysUserStripeAccount sysUserStripeAccount) {
        boolean result = sysUserStripeAccountService.save(sysUserStripeAccount);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除用户Stripe账户
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Integer id) {
        boolean result = sysUserStripeAccountService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除用户Stripe账户
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Integer> ids) {
        boolean result = sysUserStripeAccountService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新用户Stripe账户
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody SysUserStripeAccount sysUserStripeAccount) {
        boolean result = sysUserStripeAccountService.updateById(sysUserStripeAccount);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询用户Stripe账户
     */
    @GetMapping("/{id}")
    public R<SysUserStripeAccount> getById(@PathVariable Integer id) {
        SysUserStripeAccount sysUserStripeAccount = sysUserStripeAccountService.getById(id);
        return R.ok(sysUserStripeAccount);
    }
    
    /**
     * 根据用户ID查询Stripe账户
     */
    @GetMapping("/user/{userId}")
    public R<SysUserStripeAccount> getByUserId(@PathVariable Integer userId) {
        SysUserStripeAccount sysUserStripeAccount = sysUserStripeAccountService.getByUserId(userId);
        return R.ok(sysUserStripeAccount);
    }
    
    /**
     * 根据Stripe账户ID查询
     */
    @GetMapping("/stripe/{stripeAccountId}")
    public R<SysUserStripeAccount> getByStripeAccountId(@PathVariable String stripeAccountId) {
        SysUserStripeAccount sysUserStripeAccount = sysUserStripeAccountService.getByStripeAccountId(stripeAccountId);
        return R.ok(sysUserStripeAccount);
    }

    /**
     * 分页条件查询用户Stripe账户
     */
    @GetMapping("/page")
    public R<Page<SysUserStripeAccount>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            SysUserStripeAccount condition) {
        Page<SysUserStripeAccount> page = new Page<>(current, size);
        Page<SysUserStripeAccount> result = sysUserStripeAccountService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询用户Stripe账户
     */
    @GetMapping("/list")
    public R<List<SysUserStripeAccount>> selectListWithCondition(SysUserStripeAccount condition) {
        List<SysUserStripeAccount> result = sysUserStripeAccountService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有用户Stripe账户
     */
    @GetMapping("/all")
    public R<List<SysUserStripeAccount>> list() {
        List<SysUserStripeAccount> result = sysUserStripeAccountService.list();
        return R.ok(result);
    }
} 