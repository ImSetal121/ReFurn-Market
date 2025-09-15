package org.charno.system.controller;

import org.charno.common.annotation.RequirePermissions;
import org.charno.common.annotation.RequireRoles;
import org.charno.common.core.R;
import org.charno.common.service.PermissionService;
import org.charno.common.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * 权限注解使用示例控制器
 * 
 * @author charno
 */
@RestController
@RequestMapping("/example")
public class ExampleController {
    
    @Autowired
    private PermissionService permissionService;
    
    /**
     * 需要管理员角色才能访问
     */
    @GetMapping("/admin-only")
    @RequireRoles("admin")
    public R<?> adminOnly() {
        return R.ok("只有管理员可以访问此接口");
    }
    
    /**
     * 需要管理员或普通用户角色之一即可访问
     */
    @GetMapping("/admin-or-user")
    @RequireRoles(value = {"admin", "user"}, logical = RequireRoles.Logical.OR)
    public R<?> adminOrUser() {
        return R.ok("管理员或用户都可以访问此接口");
    }
    
    /**
     * 需要用户查看权限
     */
    @GetMapping("/user-view")
    @RequirePermissions("user:view")
    public R<?> userView() {
        return R.ok("拥有用户查看权限可以访问此接口");
    }
    
    /**
     * 需要用户编辑和删除权限（必须同时拥有）
     */
    @GetMapping("/user-edit-delete")
    @RequirePermissions(value = {"user:edit", "user:delete"}, logical = RequirePermissions.Logical.AND)
    public R<?> userEditAndDelete() {
        return R.ok("拥有用户编辑和删除权限可以访问此接口");
    }
    
    /**
     * 需要用户编辑或删除权限之一即可
     */
    @GetMapping("/user-edit-or-delete")
    @RequirePermissions(value = {"user:edit", "user:delete"}, logical = RequirePermissions.Logical.OR)
    public R<?> userEditOrDelete() {
        return R.ok("拥有用户编辑或删除权限之一可以访问此接口");
    }
    
    /**
     * 同时需要管理员角色和用户管理权限
     */
    @GetMapping("/admin-with-permission")
    @RequireRoles("admin")
    @RequirePermissions("user:manage")
    public R<?> adminWithPermission() {
        return R.ok("需要管理员角色且拥有用户管理权限");
    }
    
    /**
     * 超级严格的权限验证 - 但超级管理员可以直接通过
     */
    @GetMapping("/super-strict")
    @RequireRoles(value = {"admin", "super_admin"}, logical = RequireRoles.Logical.AND)
    @RequirePermissions(value = {"system:super", "admin:all"}, logical = RequirePermissions.Logical.AND)
    public R<?> superStrict() {
        return R.ok("超级严格的权限验证，但超级管理员(roleId=1)可以直接通过");
    }
    
    /**
     * 获取当前用户的权限信息
     */
    @GetMapping("/current-permissions")
    public R<?> getCurrentPermissions() {
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return R.fail("用户未登录");
        }
        
        Set<String> roles = permissionService.getUserRoles(userId);
        Set<String> permissions = permissionService.getUserPermissions(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("roles", roles);
        result.put("permissions", permissions);
        result.put("isSuperAdmin", userId != null && permissionService.hasRole(userId, new String[]{"any_role"}, false));
        
        return R.ok(result);
    }
    
    /**
     * 无需任何权限的公开接口
     */
    @GetMapping("/public")
    public R<?> publicEndpoint() {
        return R.ok("公开接口，无需权限验证");
    }
} 