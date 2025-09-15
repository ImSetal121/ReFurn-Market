package org.charno.system.controller;

import org.charno.common.annotation.RequirePermissions;
import org.charno.common.annotation.RequireRoles;
import org.charno.common.core.R;
import org.charno.common.service.PermissionService;
import org.charno.common.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 超级管理员专用控制器
 * 这些接口设置了极其严格的权限要求，只有超级管理员(roleId=1)才能绕过验证直接访问
 * 
 * @author charno
 */
@RestController
@RequestMapping("/super-admin")
public class SuperAdminController {
    
    @Autowired
    private PermissionService permissionService;
    
    /**
     * 系统重置 - 需要同时满足多个严格条件
     * 普通用户需要同时拥有super_admin和system_admin角色，以及system:reset和system:danger权限
     * 超级管理员(roleId=1)可以直接通过
     */
    @PostMapping("/system/reset")
    @RequireRoles(value = {"super_admin", "system_admin"}, logical = RequireRoles.Logical.AND)
    @RequirePermissions(value = {"system:reset", "system:danger"}, logical = RequirePermissions.Logical.AND)
    public R<?> resetSystem() {
        Long userId = SecurityUtils.getUserId();
        Map<String, Object> result = new HashMap<>();
        result.put("action", "系统重置");
        result.put("operator", userId);
        result.put("message", "系统已重置，所有数据已清理");
        
        return R.ok(result);
    }
    
    /**
     * 删除所有用户数据 - 极度危险操作
     */
    @DeleteMapping("/users/all")
    @RequireRoles(value = {"super_admin", "data_admin", "system_admin"}, logical = RequireRoles.Logical.AND)
    @RequirePermissions(value = {"user:delete_all", "system:danger", "data:destroy"}, logical = RequirePermissions.Logical.AND)
    public R<?> deleteAllUsers() {
        Long userId = SecurityUtils.getUserId();
        
        Map<String, Object> result = new HashMap<>();
        result.put("action", "删除所有用户");
        result.put("operator", userId);
        result.put("message", "⚠️ 极度危险操作：所有用户数据已删除");
        
        return R.ok(result);
    }
    
    /**
     * 修改系统配置 - 需要多重权限验证
     */
    @PutMapping("/system/config")
    @RequireRoles("config_admin")
    @RequirePermissions(value = {"system:config", "config:modify"}, logical = RequirePermissions.Logical.AND)
    public R<?> updateSystemConfig(@RequestBody Map<String, Object> config) {
        Long userId = SecurityUtils.getUserId();
        
        Map<String, Object> result = new HashMap<>();
        result.put("action", "修改系统配置");
        result.put("operator", userId);
        result.put("config", config);
        result.put("message", "系统配置已更新");
        
        return R.ok(result);
    }
    
    /**
     * 获取系统敏感信息
     */
    @GetMapping("/system/sensitive-info")
    @RequirePermissions(value = {"system:sensitive", "admin:secret"}, logical = RequirePermissions.Logical.OR)
    public R<?> getSensitiveInfo() {
        Long userId = SecurityUtils.getUserId();
        
        Map<String, Object> sensitiveInfo = new HashMap<>();
        sensitiveInfo.put("database_password", "***敏感信息***");
        sensitiveInfo.put("api_keys", "***机密数据***");
        sensitiveInfo.put("system_tokens", "***系统密钥***");
        sensitiveInfo.put("access_user", userId);
        
        return R.ok(sensitiveInfo);
    }
    
    /**
     * 检查当前用户是否为超级管理员
     */
    @GetMapping("/check-super-admin")
    public R<?> checkSuperAdmin() {
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return R.fail("用户未登录");
        }
        
        // 通过尝试一个不存在的权限来检查是否为超级管理员
        boolean isSuperAdmin = permissionService.hasPermission(userId, new String[]{"impossible:permission"}, true);
        
        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("isSuperAdmin", isSuperAdmin);
        result.put("message", isSuperAdmin ? "您是超级管理员，拥有万能通行证" : "您是普通用户");
        
        return R.ok(result);
    }
    
    /**
     * 超级管理员专属功能演示
     * 设置了根本不存在的角色和权限要求
     */
    @GetMapping("/exclusive-feature")
    @RequireRoles(value = {"impossible_role", "non_existent_role"}, logical = RequireRoles.Logical.AND)
    @RequirePermissions(value = {"impossible:permission", "non:existent"}, logical = RequirePermissions.Logical.AND)
    public R<?> exclusiveFeature() {
        return R.ok("🎉 恭喜！只有超级管理员才能看到这个消息，因为普通用户永远无法满足上述权限要求");
    }
} 