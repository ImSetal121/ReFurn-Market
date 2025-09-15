package org.charno.system.service;

import org.charno.common.entity.SysMenu;

import java.util.List;

public interface ISysRoleMenuService {

    /**
     * 获取指定角色的所有菜单
     *
     * @param roleId 角色ID
     * @return 菜单列表
     */
    List<SysMenu> getMenusByRoleId(Integer roleId);

    /**
     * 设置角色的菜单权限
     *
     * @param roleId 角色ID
     * @param menuIds 菜单ID列表
     */
    void setRoleMenus(Long roleId, List<Integer> menuIds);
}
