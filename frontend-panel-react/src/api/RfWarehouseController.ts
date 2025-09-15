import { get, post, put, del } from '@/utils/request'
import type { ApiResponse, PageResponse } from '@/types/api'

// 地址信息接口
export interface AddressInfo {
    formattedAddress: string  // 格式化的地址文本
    latitude: number         // 纬度
    longitude: number        // 经度
    placeId?: string        // Google Places ID (可选)
}

export interface RfWarehouse {
    id?: number
    name: string
    address: string  // JSON字符串，包含AddressInfo信息
    monthlyWarehouseCost: number
    status: string
    createTime?: string
    updateTime?: string
    isDelete?: boolean
}

export interface WarehouseQuery {
    current?: number
    size?: number
    name?: string
    status?: string
    address?: string
    [key: string]: unknown
}

/**
 * 新增仓库
 */
export function addWarehouse(data: RfWarehouse): Promise<ApiResponse<boolean>> {
    return post('/api/rf/warehouse', data)
}

/**
 * 根据ID删除仓库
 */
export function deleteWarehouse(id: number): Promise<ApiResponse<boolean>> {
    return del(`/api/rf/warehouse/${id}`)
}

/**
 * 批量删除仓库
 */
export function batchDeleteWarehouses(ids: number[]): Promise<ApiResponse<boolean>> {
    return del('/api/rf/warehouse/batch', { ids })
}

/**
 * 更新仓库
 */
export function updateWarehouse(data: RfWarehouse): Promise<ApiResponse<boolean>> {
    return put('/api/rf/warehouse', data)
}

/**
 * 根据ID查询仓库
 */
export function getWarehouseById(id: number): Promise<ApiResponse<RfWarehouse>> {
    return get(`/api/rf/warehouse/${id}`)
}

/**
 * 分页条件查询仓库
 */
export function getWarehousePage(params: WarehouseQuery): Promise<ApiResponse<PageResponse<RfWarehouse>>> {
    return get('/api/rf/warehouse/page', params)
}

/**
 * 不分页条件查询仓库
 */
export function getWarehouseList(params?: Partial<RfWarehouse>): Promise<ApiResponse<RfWarehouse[]>> {
    return get('/api/rf/warehouse/list', params)
}

/**
 * 查询所有仓库
 */
export function getAllWarehouses(): Promise<ApiResponse<RfWarehouse[]>> {
    return get('/api/rf/warehouse/all')
} 