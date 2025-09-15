import { get, post, put, del } from '@/utils/request';
import type { SysUser, UserQuery } from '@/types/system';

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
 * 系统用户控制器API
 */
export class SysUserController {
    /**
     * 添加用户
     * @param user 用户信息
     */
    static add(user: SysUser): Promise<SysUser> {
        return post('/system/user', user);
    }

    /**
     * 删除用户（软删除）
     * @param id 用户ID
     */
    static delete(id: number): Promise<void> {
        return del(`/system/user/${id}`);
    }

    /**
     * 更新用户
     * @param user 用户信息
     */
    static update(user: SysUser): Promise<SysUser> {
        return put('/system/user', user);
    }

    /**
     * 根据ID获取用户
     * @param id 用户ID
     */
    static getById(id: number): Promise<SysUser> {
        return get(`/system/user/${id}`);
    }

    /**
     * 获取用户列表
     * @param params 查询参数
     */
    static list(params?: {
        username?: string;
        nickname?: string;
        email?: string;
        phoneNumber?: string;
    }): Promise<SysUser[]> {
        return get('/system/user/list', params);
    }

    /**
     * 分页查询用户
     * @param params 查询参数
     */
    static page(params: UserQuery): Promise<PageResponse<SysUser>> {
        return get('/system/user/page', params);
    }
}

// 导出默认实例方法
export const addUser = SysUserController.add;
export const deleteUser = SysUserController.delete;
export const updateUser = SysUserController.update;
export const getUserById = SysUserController.getById;
export const getUserList = SysUserController.list;
export const getUserPage = SysUserController.page; 