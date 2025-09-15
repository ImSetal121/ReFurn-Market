package org.charno.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.core.R;
import org.charno.common.entity.SysRole;
import org.charno.common.entity.SysMenu;
import org.charno.system.service.ISysRoleService;
import org.charno.system.service.ISysRoleMenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/system/role")
public class SysRoleController {

    @Autowired
    private ISysRoleService roleService;

    @Autowired
    private ISysRoleMenuService roleMenuService;

    @PostMapping
    public R<SysRole> add(@RequestBody SysRole role) {
        roleService.save(role);
        return R.ok(role);
    }

    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Integer id) {
        // 超级管理员保护：禁止删除ID为1的角色
        if (id == 1) {
            return R.fail("超级管理员角色不允许删除");
        }
        roleService.removeById(id);
        return R.ok();
    }

    @PutMapping
    public R<SysRole> update(@RequestBody SysRole role) {
        // 超级管理员保护：禁止修改ID为1的角色
        if (role.getId() != null && role.getId() == 1) {
            return R.fail("超级管理员角色不允许修改");
        }
        roleService.updateById(role);
        return R.ok(role);
    }

    @GetMapping("/{id}")
    public R<SysRole> getById(@PathVariable Integer id) {
        return R.ok(roleService.getById(id));
    }

    @GetMapping("/list")
    public R<List<SysRole>> list(@RequestParam(required = false) String key,
            @RequestParam(required = false) String name) {
        QueryWrapper<SysRole> queryWrapper = new QueryWrapper<>();
        if (key != null) {
            queryWrapper.like("key", key);
        }
        if (name != null) {
            queryWrapper.like("name", name);
        }
        return R.ok(roleService.listQuery(queryWrapper));
    }

    @GetMapping("/page")
    public R<Page<SysRole>> page(@RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String key,
            @RequestParam(required = false) String name) {
        Page<SysRole> page = new Page<>(current, size);
        QueryWrapper<SysRole> queryWrapper = new QueryWrapper<>();
        if (key != null) {
            queryWrapper.like("key", key);
        }
        if (name != null) {
            queryWrapper.like("name", name);
        }
        return R.ok(roleService.pageQuery(page, queryWrapper));
    }

    /**
     * 获取角色拥有的菜单列表
     * @param roleId 角色ID
     * @return 菜单列表
     */
    @GetMapping("/{roleId}/menus")
    public R<List<SysMenu>> getRoleMenus(@PathVariable Integer roleId) {
        List<SysMenu> menus = roleMenuService.getMenusByRoleId(roleId);
        return R.ok(menus);
    }

    /**
     * 设置角色的菜单权限
     * @param roleId 角色ID
     * @param menuIds 菜单ID列表
     * @return 响应结果
     */
    @PostMapping("/{roleId}/menus")
    public R<Void> setRoleMenus(@PathVariable Long roleId, @RequestBody List<Integer> menuIds) {
        // 超级管理员保护：禁止修改ID为1的角色菜单权限
        if (roleId == 1) {
            return R.fail("超级管理员角色菜单权限不允许修改");
        }
        roleMenuService.setRoleMenus(roleId, menuIds);
        return R.ok();
    }
}
