import { get, post, put, del } from '@/utils/request';
import type { SysMenu, MenuQuery } from '@/types/system';

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
 * 系统菜单控制器API
 */
export class SysMenuController {
    /**
     * 添加菜单
     * @param menu 菜单信息
     */
    static add(menu: SysMenu): Promise<SysMenu> {
        return post('/system/menu', menu);
    }

    /**
     * 删除菜单
     * @param id 菜单ID
     */
    static delete(id: number): Promise<void> {
        return del(`/system/menu/${id}`);
    }

    /**
     * 更新菜单
     * @param menu 菜单信息
     */
    static update(menu: SysMenu): Promise<SysMenu> {
        return put('/system/menu', menu);
    }

    /**
     * 根据ID获取菜单
     * @param id 菜单ID
     */
    static getById(id: number): Promise<SysMenu> {
        return get(`/system/menu/${id}`);
    }

    /**
     * 获取菜单列表
     * @param params 查询参数
     */
    static list(params?: {
        menuName?: string;
        status?: string;
    }): Promise<SysMenu[]> {
        return get('/system/menu/list', params);
    }

    /**
     * 分页查询菜单
     * @param params 查询参数
     */
    static page(params: MenuQuery): Promise<PageResponse<SysMenu>> {
        return get('/system/menu/page', params);
    }
}

// 导出默认实例方法
export const addMenu = SysMenuController.add;
export const deleteMenu = SysMenuController.delete;
export const updateMenu = SysMenuController.update;
export const getMenuById = SysMenuController.getById;
export const getMenuList = SysMenuController.list;
export const getMenuPage = SysMenuController.page; 