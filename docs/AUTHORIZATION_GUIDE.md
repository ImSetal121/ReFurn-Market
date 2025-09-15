# 🔐 ReFlip 权限控制系统使用指南

## 📋 概述

ReFlip项目提供了完整的基于注解的权限控制系统，支持角色权限和操作权限的细粒度控制。

## 🏗️ 系统架构

### 权限模型
```
用户(SysUser) → 角色(SysRole) → 菜单权限(SysMenu)
     ↓              ↓                ↓
   用户ID         角色标识          权限标识
   roleId       role.key         menu.perms
```

### 核心组件
- **@RequireRoles**: 角色权限注解
- **@RequirePermissions**: 操作权限注解
- **PermissionService**: 权限验证服务
- **AuthorizationAspect**: 权限验证切面

### 🔱 超级管理员特性

**ID为1的角色被设定为超级管理员，具有以下特权：**

- ✅ **绕过所有角色验证**: 无论@RequireRoles设置什么角色要求
- ✅ **绕过所有权限验证**: 无论@RequirePermissions设置什么权限要求  
- ✅ **自动通过组合验证**: 同时使用角色和权限注解也会直接通过
- ✅ **无需配置权限**: 不需要在数据库中配置具体的菜单权限

```java
// 示例：即使设置了严格的权限要求，超级管理员也能直接访问
@RequireRoles(value = {"admin", "super_admin"}, logical = RequireRoles.Logical.AND)
@RequirePermissions(value = {"system:super", "admin:all"}, logical = RequirePermissions.Logical.AND)
public R<?> superStrictMethod() {
    // roleId=1的用户可以直接访问，无需满足上述条件
    return R.ok("超级管理员万能通行证");
}
```

## 📝 注解使用

### 1. 角色权限注解 @RequireRoles

```java
// 需要管理员角色
@RequireRoles("admin")
public R<?> adminOnly() { ... }

// 需要管理员或用户角色之一
@RequireRoles(value = {"admin", "user"}, logical = RequireRoles.Logical.OR)
public R<?> adminOrUser() { ... }

// 需要同时拥有多个角色（默认AND逻辑）
@RequireRoles({"admin", "super_admin"})
public R<?> multipleRoles() { ... }
```

### 2. 操作权限注解 @RequirePermissions

```java
// 需要用户查看权限
@RequirePermissions("user:view")
public R<?> viewUsers() { ... }

// 需要同时拥有编辑和删除权限
@RequirePermissions(value = {"user:edit", "user:delete"}, logical = RequirePermissions.Logical.AND)
public R<?> editAndDelete() { ... }

// 需要编辑或删除权限之一
@RequirePermissions(value = {"user:edit", "user:delete"}, logical = RequirePermissions.Logical.OR)
public R<?> editOrDelete() { ... }
```

### 3. 组合使用

```java
// 同时验证角色和权限
@RequireRoles("admin")
@RequirePermissions("user:manage")
public R<?> adminManageUsers() { ... }
```

## 🔧 配置说明

### 1. 数据库表结构

#### sys_user 表
```sql
id          主键
username    用户名
role_id     角色ID（外键关联sys_role.id）
            当role_id=1时，该用户为超级管理员
...
```

#### sys_role 表
```sql
id      主键（id=1为超级管理员角色）
key     角色标识（用于权限验证）
name    角色名称
```

#### sys_menu 表
```sql
id        主键
perms     权限标识（用于权限验证）
...
```

#### sys_role_menu 表
```sql
role_id   角色ID
menu_id   菜单ID
```

### 2. 权限标识规范

建议使用以下格式：
- **模块:操作**: 如 `user:view`, `user:edit`, `user:delete`
- **资源:操作**: 如 `order:create`, `product:manage`

### 3. 超级管理员配置

```sql
-- 创建超级管理员角色（确保ID为1）
INSERT INTO sys_role (id, key, name) VALUES (1, 'super_admin', '超级管理员');

-- 创建超级管理员用户
INSERT INTO sys_user (username, password, role_id, nickname) 
VALUES ('admin', '[加密后的密码]', 1, '系统管理员');
```

## 💡 最佳实践

### 1. 权限粒度设计
```java
// 粗粒度 - 模块级别
@RequirePermissions("user:manage")

// 细粒度 - 操作级别
@RequirePermissions({"user:view", "user:edit"})
```

### 2. 角色层次设计
```java
// 超级管理员（roleId=1，万能通行证）
// 不需要使用注解，系统自动识别

// 管理角色
@RequireRoles("admin")

// 基础角色
@RequireRoles("user")
```

### 3. 错误处理
```java
// 权限不足时返回统一错误码
{
    "code": 2001,
    "message": "用户角色权限不足",
    "data": null
}
```

## 🛠️ 扩展使用

### 1. 编程式权限检查
```java
@Autowired
private PermissionService permissionService;

public R<?> someMethod() {
    // 检查当前用户是否有特定角色
    if (!permissionService.hasRole(new String[]{"admin"}, false)) {
        return R.fail(ResultCode.NO_PERMISSION);
    }
    
    // 检查当前用户是否有特定权限
    if (!permissionService.hasPermission(new String[]{"user:view"}, true)) {
        return R.fail(ResultCode.NO_PERMISSION);
    }
    
    // 业务逻辑
    return R.ok();
}
```

### 2. 获取用户权限信息
```java
// 获取当前用户所有角色
Set<String> userRoles = permissionService.getUserRoles(userId);

// 获取当前用户所有权限
Set<String> userPermissions = permissionService.getUserPermissions(userId);

// 检查是否为超级管理员
// 超级管理员会自动通过hasRole和hasPermission验证
```

## 🎯 常见场景

### 1. 用户管理接口
```java
@RestController
@RequestMapping("/system/user")
public class SysUserController {
    
    @GetMapping("/list")
    @RequirePermissions("user:view")
    public R<?> list() { ... }
    
    @PostMapping
    @RequirePermissions("user:create")
    public R<?> create() { ... }
    
    @PutMapping
    @RequirePermissions("user:edit")
    public R<?> update() { ... }
    
    @DeleteMapping("/{id}")
    @RequirePermissions("user:delete")
    public R<?> delete() { ... }
}
```

### 2. 管理员专用接口
```java
@RestController
@RequestMapping("/admin")
@RequireRoles("admin")  // 类级别注解，整个控制器都需要管理员权限
public class AdminController {
    
    @GetMapping("/dashboard")
    public R<?> dashboard() { ... }
    
    @GetMapping("/statistics")
    @RequirePermissions("admin:statistics")  // 额外的权限要求
    public R<?> statistics() { ... }
}
```

### 3. 超级管理员场景
```java
@RestController
@RequestMapping("/super")
public class SuperController {
    
    // 只有超级管理员才能访问的危险操作
    @GetMapping("/reset-system")
    @RequireRoles(value = {"super_admin", "system_admin"}, logical = RequireRoles.Logical.AND)
    @RequirePermissions(value = {"system:reset", "system:danger"}, logical = RequirePermissions.Logical.AND)
    public R<?> resetSystem() {
        // 普通用户即使拥有super_admin角色和相关权限也需要同时满足所有条件
        // 但roleId=1的超级管理员可以直接通过验证
        return R.ok("系统重置完成");
    }
}
```

## ⚠️ 注意事项

1. **注解只在Spring管理的Bean中生效**
2. **类内部方法调用不会触发AOP**
3. **权限验证失败会直接返回错误响应，不会执行业务方法**
4. **建议在Controller层使用权限注解**
5. **权限标识区分大小写**
6. **⚠️ 超级管理员权限很危险，请谨慎分配roleId=1**
7. **超级管理员绕过所有验证，包括业务逻辑中的编程式权限检查**

## 🔍 调试技巧

1. 启用DEBUG日志查看权限验证过程
2. 使用`/auth/info`接口查看当前用户的角色和权限
3. 使用`/example/current-permissions`接口检查用户权限状态
4. 检查数据库中的角色菜单关联关系
5. 验证权限标识的准确性
6. 确认超级管理员用户的roleId确实为1

## 📚 相关文件

- 注解定义: `backend-common/src/main/java/org/charno/common/annotation/`
- 权限服务: `backend-common/src/main/java/org/charno/common/service/PermissionService.java`
- 切面实现: `backend-common/src/main/java/org/charno/common/aspect/AuthorizationAspect.java`
- 使用示例: `backend-system/src/main/java/org/charno/system/controller/ExampleController.java` 