package org.charno.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.charno.common.entity.SysMenu;
import org.charno.common.entity.SysRoleMenu;
import org.charno.system.mapper.SysMenuMapper;
import org.charno.system.mapper.SysRoleMenuMapper;
import org.charno.system.service.ISysRoleMenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SysRoleMenuServiceImpl implements ISysRoleMenuService {

    @Autowired
    private SysRoleMenuMapper roleMenuMapper;

    @Autowired
    private SysMenuMapper menuMapper;

    @Override
    public List<SysMenu> getMenusByRoleId(Integer roleId) {
        // 查询角色-菜单关联关系
        List<SysRoleMenu> roleMenus = roleMenuMapper.selectList(
                new LambdaQueryWrapper<SysRoleMenu>()
                        .eq(SysRoleMenu::getRoleId, roleId));

        // 获取菜单ID列表
        List<Integer> menuIds = roleMenus.stream()
                .map(SysRoleMenu::getMenuId)
                .collect(Collectors.toList());

        // 如果没有关联的菜单，返回空列表
        if (menuIds.isEmpty()) {
            return List.of();
        }

        // 查询菜单详情并按orderNum排序
        return menuMapper.selectList(
                new LambdaQueryWrapper<SysMenu>()
                        .in(SysMenu::getId, menuIds)
                        .orderByAsc(SysMenu::getOrderNum));
    }

    @Override
    @Transactional
    public void setRoleMenus(Long roleId, List<Integer> menuIds) {
        // 1. 删除角色原有的菜单关联关系
        roleMenuMapper.delete(
                new LambdaQueryWrapper<SysRoleMenu>()
                        .eq(SysRoleMenu::getRoleId, roleId)
        );

        // 2. 如果菜单ID列表不为空，则插入新的关联关系
        if (menuIds != null && !menuIds.isEmpty()) {
            List<SysRoleMenu> roleMenus = menuIds.stream()
                    .map(menuId -> {
                        SysRoleMenu roleMenu = new SysRoleMenu();
                        roleMenu.setRoleId(roleId);
                        roleMenu.setMenuId(menuId);
                        return roleMenu;
                    })
                    .collect(Collectors.toList());

            // 批量插入
            for (SysRoleMenu roleMenu : roleMenus) {
                roleMenuMapper.insert(roleMenu);
            }
        }
    }
}
