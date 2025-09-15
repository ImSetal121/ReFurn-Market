package org.charno.common.service;

import org.charno.common.utils.SecurityUtils;

import java.util.Set;

/**
 * 权限服务接口
 * 
 * @author charno
 */
public interface PermissionService {
    
    /**
     * 获取用户的所有角色标识
     * 
     * @param userId 用户ID
     * @return 角色标识集合
     */
    Set<String> getUserRoles(Long userId);
    
    /**
     * 获取用户的所有权限标识
     * 
     * @param userId 用户ID
     * @return 权限标识集合
     */
    Set<String> getUserPermissions(Long userId);
    
    /**
     * 检查用户是否拥有指定角色
     * 
     * @param userId 用户ID
     * @param roleKeys 角色标识数组
     * @param requireAll 是否需要拥有所有角色
     * @return 是否拥有权限
     */
    boolean hasRole(Long userId, String[] roleKeys, boolean requireAll);
    
    /**
     * 检查用户是否拥有指定权限
     * 
     * @param userId 用户ID
     * @param permissions 权限标识数组
     * @param requireAll 是否需要拥有所有权限
     * @return 是否拥有权限
     */
    boolean hasPermission(Long userId, String[] permissions, boolean requireAll);
    
    /**
     * 检查当前登录用户是否拥有指定角色
     * 
     * @param roleKeys 角色标识数组
     * @param requireAll 是否需要拥有所有角色
     * @return 是否拥有权限
     */
    default boolean hasRole(String[] roleKeys, boolean requireAll) {
        Long userId = SecurityUtils.getUserId();
        return userId != null && hasRole(userId, roleKeys, requireAll);
    }
    
    /**
     * 检查当前登录用户是否拥有指定权限
     * 
     * @param permissions 权限标识数组
     * @param requireAll 是否需要拥有所有权限
     * @return 是否拥有权限
     */
    default boolean hasPermission(String[] permissions, boolean requireAll) {
        Long userId = SecurityUtils.getUserId();
        return userId != null && hasPermission(userId, permissions, requireAll);
    }
} 