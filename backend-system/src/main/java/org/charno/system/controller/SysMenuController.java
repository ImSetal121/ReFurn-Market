package org.charno.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.core.R;
import org.charno.common.entity.SysMenu;
import org.charno.system.service.ISysMenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/system/menu")
public class SysMenuController {

    @Autowired
    private ISysMenuService menuService;

    @PostMapping
    public R<SysMenu> add(@RequestBody SysMenu menu) {
        menuService.save(menu);
        return R.ok(menu);
    }

    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Integer id) {
        menuService.removeById(id);
        return R.ok();
    }

    @PutMapping
    public R<SysMenu> update(@RequestBody SysMenu menu) {
        menuService.updateById(menu);
        return R.ok(menu);
    }

    @GetMapping("/{id}")
    public R<SysMenu> getById(@PathVariable Integer id) {
        return R.ok(menuService.getById(id));
    }

    @GetMapping("/list")
    public R<List<SysMenu>> list(@RequestParam(required = false) String menuName,
            @RequestParam(required = false) String status) {
        QueryWrapper<SysMenu> queryWrapper = new QueryWrapper<>();
        if (menuName != null) {
            queryWrapper.like("menu_name", menuName);
        }
        if (status != null) {
            queryWrapper.eq("status", status);
        }
        return R.ok(menuService.listQuery(queryWrapper));
    }

    @GetMapping("/page")
    public R<Page<SysMenu>> page(@RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String menuName,
            @RequestParam(required = false) String status) {
        Page<SysMenu> page = new Page<>(current, size);
        QueryWrapper<SysMenu> queryWrapper = new QueryWrapper<>();
        if (menuName != null) {
            queryWrapper.like("menu_name", menuName);
        }
        if (status != null) {
            queryWrapper.eq("status", status);
        }
        return R.ok(menuService.pageQuery(page, queryWrapper));
    }
}
