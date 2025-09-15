package org.charno.system.service.impl;

import org.charno.common.entity.SysMenu;
import org.charno.common.entity.SysRole;
import org.charno.common.entity.SysUser;
import org.charno.common.service.PermissionService;
import org.charno.system.mapper.SysRoleMapper;
import org.charno.system.mapper.SysUserMapper;
import org.charno.system.service.ISysRoleMenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 权限服务实现类
 * 
 * @author charno
 */
@Service
public class PermissionServiceImpl implements PermissionService {
    
    /**
     * 超级管理员角色ID
     */
    private static final Integer SUPER_ADMIN_ROLE_ID = 1;
    
    @Autowired
    private SysRoleMapper roleMapper;
    
    @Autowired
    private SysUserMapper userMapper;
    
    @Autowired
    private ISysRoleMenuService roleMenuService;
    
    /**
     * 检查用户是否为超级管理员
     * 
     * @param userId 用户ID
     * @return 是否为超级管理员
     */
    private boolean isSuperAdmin(Long userId) {
        SysUser user = userMapper.selectById(userId);
        return user != null && SUPER_ADMIN_ROLE_ID.equals(user.getRoleId());
    }
    
    @Override
    public Set<String> getUserRoles(Long userId) {
        Set<String> roleKeys = new HashSet<>();
        
        // 根据用户ID获取用户信息
        SysUser user = userMapper.selectById(userId);
        if (user != null && user.getRoleId() != null) {
            // 根据角色ID获取角色信息
            SysRole role = roleMapper.selectById(user.getRoleId());
            if (role != null && StringUtils.hasText(role.getKey())) {
                roleKeys.add(role.getKey());
            }
        }
        
        return roleKeys;
    }
    
    @Override
    public Set<String> getUserPermissions(Long userId) {
        Set<String> permissions = new HashSet<>();
        
        // 根据用户ID获取用户信息
        SysUser user = userMapper.selectById(userId);
        if (user != null && user.getRoleId() != null) {
            // 根据角色ID获取菜单权限
            List<SysMenu> menus = roleMenuService.getMenusByRoleId(user.getRoleId());
            
            // 提取权限标识
            permissions = menus.stream()
                    .filter(menu -> StringUtils.hasText(menu.getPerms()))
                    .map(SysMenu::getPerms)
                    .collect(Collectors.toSet());
        }
        
        return permissions;
    }
    
    @Override
    public boolean hasRole(Long userId, String[] roleKeys, boolean requireAll) {
        // 超级管理员直接通过验证
        if (isSuperAdmin(userId)) {
            return true;
        }
        
        if (roleKeys == null || roleKeys.length == 0) {
            return true;
        }
        
        Set<String> userRoles = getUserRoles(userId);
        Set<String> requiredRoles = new HashSet<>(Arrays.asList(roleKeys));
        
        if (requireAll) {
            // 必须拥有所有角色
            return userRoles.containsAll(requiredRoles);
        } else {
            // 拥有任意一个角色即可
            return requiredRoles.stream().anyMatch(userRoles::contains);
        }
    }
    
    @Override
    public boolean hasPermission(Long userId, String[] permissions, boolean requireAll) {
        // 超级管理员直接通过验证
        if (isSuperAdmin(userId)) {
            return true;
        }
        
        if (permissions == null || permissions.length == 0) {
            return true;
        }
        
        Set<String> userPermissions = getUserPermissions(userId);
        Set<String> requiredPermissions = new HashSet<>(Arrays.asList(permissions));
        
        if (requireAll) {
            // 必须拥有所有权限
            return userPermissions.containsAll(requiredPermissions);
        } else {
            // 拥有任意一个权限即可
            return requiredPermissions.stream().anyMatch(userPermissions::contains);
        }
    }
} 