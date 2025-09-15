package org.charno.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.core.R;
import org.charno.common.entity.SysUser;
import org.charno.system.service.ISysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/system/user")
public class SysUserController {

    @Autowired
    private ISysUserService userService;

    @PostMapping
    public R<SysUser> add(@RequestBody SysUser user) {
        userService.save(user);
        return R.ok(user);
    }

    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Integer id) {
        // 使用MyBatis-Plus的逻辑删除
        userService.removeById(id);
        return R.ok();
    }

    @PutMapping
    public R<SysUser> update(@RequestBody SysUser user) {
        userService.updateById(user);
        return R.ok(user);
    }

    @GetMapping("/{id}")
    public R<SysUser> getById(@PathVariable Integer id) {
        return R.ok(userService.getById(id));
    }

    @GetMapping("/list")
    public R<List<SysUser>> list(@RequestParam(required = false) String username,
            @RequestParam(required = false) String nickname,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String phoneNumber) {
        QueryWrapper<SysUser> queryWrapper = new QueryWrapper<>();
        if (username != null) {
            queryWrapper.like("username", username);
        }
        if (nickname != null) {
            queryWrapper.like("nickname", nickname);
        }
        if (email != null) {
            queryWrapper.like("email", email);
        }
        if (phoneNumber != null) {
            queryWrapper.like("phone_number", phoneNumber);
        }
        return R.ok(userService.listQuery(queryWrapper));
    }

    @GetMapping("/page")
    public R<Page<SysUser>> page(@RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String nickname,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String phoneNumber) {
        Page<SysUser> page = new Page<>(current, size);
        QueryWrapper<SysUser> queryWrapper = new QueryWrapper<>();
        if (username != null) {
            queryWrapper.like("username", username);
        }
        if (nickname != null) {
            queryWrapper.like("nickname", nickname);
        }
        if (email != null) {
            queryWrapper.like("email", email);
        }
        if (phoneNumber != null) {
            queryWrapper.like("phone_number", phoneNumber);
        }
        return R.ok(userService.pageQuery(page, queryWrapper));
    }
}
