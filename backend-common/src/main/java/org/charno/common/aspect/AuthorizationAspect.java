package org.charno.common.aspect;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.charno.common.annotation.RequirePermissions;
import org.charno.common.annotation.RequireRoles;
import org.charno.common.core.R;
import org.charno.common.core.ResultCode;
import org.charno.common.service.PermissionService;
import org.charno.common.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;

/**
 * 权限验证切面
 * 
 * @author charno
 */
@Aspect
@Component
public class AuthorizationAspect {
    
    @Autowired
    private PermissionService permissionService;
    
    /**
     * 定义切点：标注了@RequireRoles注解的方法
     */
    @Pointcut("@annotation(org.charno.common.annotation.RequireRoles)")
    public void requireRolesPointcut() {}
    
    /**
     * 定义切点：标注了@RequirePermissions注解的方法
     */
    @Pointcut("@annotation(org.charno.common.annotation.RequirePermissions)")
    public void requirePermissionsPointcut() {}
    
    /**
     * 角色权限验证
     */
    @Around("requireRolesPointcut()")
    public Object aroundRequireRoles(ProceedingJoinPoint joinPoint) throws Throwable {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return R.fail(ResultCode.UNAUTHORIZED);
        }
        
        // 获取方法上的@RequireRoles注解
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        RequireRoles requireRoles = method.getAnnotation(RequireRoles.class);
        
        if (requireRoles != null) {
            String[] roleKeys = requireRoles.value();
            boolean requireAll = requireRoles.logical() == RequireRoles.Logical.AND;
            
            // 验证角色权限
            if (!permissionService.hasRole(userId, roleKeys, requireAll)) {
                return R.fail(ResultCode.NO_PERMISSION, "用户角色权限不足");
            }
        }
        
        // 继续执行原方法
        return joinPoint.proceed();
    }
    
    /**
     * 操作权限验证
     */
    @Around("requirePermissionsPointcut()")
    public Object aroundRequirePermissions(ProceedingJoinPoint joinPoint) throws Throwable {
        // 获取当前登录用户ID
        Long userId = SecurityUtils.getUserId();
        if (userId == null) {
            return R.fail(ResultCode.UNAUTHORIZED);
        }
        
        // 获取方法上的@RequirePermissions注解
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        RequirePermissions requirePermissions = method.getAnnotation(RequirePermissions.class);
        
        if (requirePermissions != null) {
            String[] permissions = requirePermissions.value();
            boolean requireAll = requirePermissions.logical() == RequirePermissions.Logical.AND;
            
            // 验证操作权限
            if (!permissionService.hasPermission(userId, permissions, requireAll)) {
                return R.fail(ResultCode.NO_PERMISSION, "用户操作权限不足");
            }
        }
        
        // 继续执行原方法
        return joinPoint.proceed();
    }
} 