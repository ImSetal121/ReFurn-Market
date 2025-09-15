package org.charno.common.annotation;

import java.lang.annotation.*;

/**
 * 权限注解
 * 用于标记需要特定权限才能访问的方法或类
 * 
 * @author charno
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequirePermissions {
    
    /**
     * 需要的权限标识数组
     * 对应 SysMenu.perms 字段
     */
    String[] value() default {};
    
    /**
     * 逻辑关系
     * AND: 必须拥有所有指定的权限
     * OR: 拥有任意一个指定的权限即可
     */
    Logical logical() default Logical.AND;
    
    /**
     * 逻辑关系枚举
     */
    enum Logical {
        AND, OR
    }
} 