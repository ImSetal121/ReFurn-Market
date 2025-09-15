import { get, post, put, del } from '@/utils/request';
import type { SysRole, RoleQuery, SysMenu } from '@/types/system';

/**
 * 分页响应接口
 */
export interface PageResponse<T> {
    records: T[];
    total: number;
    size: number;
    current: number;
    pages: number;
}

/**
 * 系统角色控制器API
 */
export class SysRoleController {
    /**
     * 添加角色
     * @param role 角色信息
     */
    static add(role: SysRole): Promise<SysRole> {
        return post('/system/role', role);
    }

    /**
     * 删除角色
     * @param id 角色ID
     */
    static delete(id: number): Promise<void> {
        return del(`/system/role/${id}`);
    }

    /**
     * 更新角色
     * @param role 角色信息
     */
    static update(role: SysRole): Promise<SysRole> {
        return put('/system/role', role);
    }

    /**
     * 根据ID获取角色
     * @param id 角色ID
     */
    static getById(id: number): Promise<SysRole> {
        return get(`/system/role/${id}`);
    }

    /**
     * 获取角色列表
     * @param params 查询参数
     */
    static list(params?: {
        key?: string;
        name?: string;
    }): Promise<SysRole[]> {
        return get('/system/role/list', params);
    }

    /**
     * 分页查询角色
     * @param params 查询参数
     */
    static page(params: RoleQuery): Promise<PageResponse<SysRole>> {
        return get('/system/role/page', params as Record<string, unknown>);
    }

    /**
     * 获取角色拥有的菜单列表
     * @param roleId 角色ID
     */
    static getRoleMenus(roleId: number): Promise<SysMenu[]> {
        return get(`/system/role/${roleId}/menus`);
    }

    /**
     * 设置角色的菜单权限
     * @param roleId 角色ID
     * @param menuIds 菜单ID列表
     */
    static setRoleMenus(roleId: number, menuIds: number[]): Promise<void> {
        return post(`/system/role/${roleId}/menus`, menuIds);
    }
}

// 导出默认实例方法
export const addRole = SysRoleController.add;
export const deleteRole = SysRoleController.delete;
export const updateRole = SysRoleController.update;
export const getRoleById = SysRoleController.getById;
export const getRoleList = SysRoleController.list;
export const getRolePage = SysRoleController.page;
export const getRoleMenus = SysRoleController.getRoleMenus;
export const setRoleMenus = SysRoleController.setRoleMenus; 