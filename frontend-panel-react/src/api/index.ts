// src/api/index.ts

// 导出所有控制器类
export { AuthController } from './AuthController';
export { SysMenuController } from './SysMenuController';
export { SysRoleController } from './SysRoleController';
export { SysUserController } from './SysUserController';
export { RfProductController } from './RfProductController';
export { rfProductAuctionLogisticsController } from './RfProductAuctionLogisticsController';
export { rfWarehouseStockController } from './RfWarehouseStockController';
export { rfInternalLogisticsTaskController } from './RfInternalLogisticsTaskController';
export { RfProductSellRecordController } from './RfProductSellRecordController';
export { RfProductReturnRecordController } from './RfProductReturnRecordController';
export { RfBalanceDetailController } from './RfBalanceDetailController';
export { RfBillItemController } from './RfBillItemController';
export { PlatformController } from './PlatformController';

// 导出认证相关API
export {
    login,
    logout,
    getUserInfo,
    getMenus,
    register
} from './AuthController';

// 导出菜单相关API
export {
    addMenu,
    deleteMenu,
    updateMenu,
    getMenuById,
    getMenuList,
    getMenuPage
} from './SysMenuController';

// 导出角色相关API
export {
    addRole,
    deleteRole,
    updateRole,
    getRoleById,
    getRoleList,
    getRolePage
} from './SysRoleController';

// 导出用户相关API
export {
    addUser,
    deleteUser,
    updateUser,
    getUserById,
    getUserList,
    getUserPage
} from './SysUserController';

// 导出商品相关API
export {
    addProduct,
    deleteProduct,
    updateProduct,
    getProductById,
    getProductPage,
    getProductList
} from './RfProductController';

// 导出通用类型
export type { PageResponse } from './SysMenuController';

// API 控制器导出
export * from './auth'
export * from './AuthController'
export * from './SysUserController'
export * from './SysRoleController'
export * from './SysMenuController'
export * from './RfProductController'
export * from './RfWarehouseController'
export * from './RfWarehouseStockController'
export * from './RfProductAuctionLogisticsController'
export * from './RfInternalLogisticsTaskController'
export * from './RfCourierController'
export * from './RfProductSellRecordController'
export * from './RfProductReturnRecordController'
export * from './RfProductReturnToSellerController'
export * from './RfBalanceDetailController'
export * from './RfBillItemController'

// API 配置
export interface ApiResponse<T = any> {
    code: number
    data: T
    message: string
    success: boolean
    timestamp: number
}

export interface PaginationParams {
    current?: number
    size?: number
}

export interface PaginationResponse<T> {
    records: T[]
    total: number
    size: number
    current: number
    pages: number
}

// 通用响应处理
export const handleApiResponse = <T>(response: ApiResponse<T>): T => {
    if (response.success && response.code === 200) {
        return response.data
    }
    throw new Error(response.message || 'API 请求失败')
}

// 分页参数构建
export const buildPaginationParams = (params: PaginationParams & Record<string, any>) => {
    return {
        current: params.current || 1,
        size: params.size || 10,
        ...params
    }
} 