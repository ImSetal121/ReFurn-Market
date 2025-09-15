import { get, post, put, del } from '@/utils/request'
import type { PaginationParams, PaginationResponse } from './index'

// 账单项实体类型定义
export interface RfBillItem {
    id?: number
    productId?: number
    productSellRecordId?: number
    costType: string
    costDescription?: string
    cost: number
    paySubject?: string
    isPlatformPay?: boolean
    payUserId?: number
    status: string
    payTime?: string
    paymentRecordId?: number
    createTime?: string
    updateTime?: string
    isDelete?: boolean
    // 扩展字段用于显示
    productName?: string
    payUserName?: string
}

// 查询参数类型
export interface BillItemQuery extends PaginationParams {
    productId?: number
    productSellRecordId?: number
    costType?: string
    status?: string
    payUserId?: number
    isPlatformPay?: boolean
    startTime?: string
    endTime?: string
}

// 新增账单项
export const createBillItem = (data: RfBillItem): Promise<boolean> => {
    return post('/api/rf/bill-item', data)
}

// 根据ID删除账单项
export const deleteBillItem = (id: number): Promise<boolean> => {
    return del(`/api/rf/bill-item/${id}`)
}

// 批量删除账单项
export const batchDeleteBillItems = (ids: number[]): Promise<boolean> => {
    return del('/api/rf/bill-item/batch', { ids })
}

// 更新账单项
export const updateBillItem = (data: RfBillItem): Promise<boolean> => {
    return put('/api/rf/bill-item', data)
}

// 根据ID查询账单项
export const getBillItemById = (id: number): Promise<RfBillItem> => {
    return get(`/api/rf/bill-item/${id}`)
}

// 分页条件查询账单项
export const getBillItemsPage = (
    params: BillItemQuery
): Promise<PaginationResponse<RfBillItem>> => {
    return get('/api/rf/bill-item/page', params as Record<string, unknown>)
}

// 不分页条件查询账单项
export const getBillItemsList = (condition: Partial<RfBillItem>): Promise<RfBillItem[]> => {
    return get('/api/rf/bill-item/list', condition)
}

// 查询所有账单项
export const getAllBillItems = (): Promise<RfBillItem[]> => {
    return get('/api/rf/bill-item/all')
}

// 导出控制器类
export const RfBillItemController = {
    createBillItem,
    deleteBillItem,
    batchDeleteBillItems,
    updateBillItem,
    getBillItemById,
    getBillItemsPage,
    getBillItemsList,
    getAllBillItems,
} 