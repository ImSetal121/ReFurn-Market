import { get, post, put, del } from '@/utils/request'
import service from '@/utils/request'
import type { PaginationParams, PaginationResponse } from './index'

// 余额明细实体类型定义
export interface RfBalanceDetail {
    id?: number
    userId: number
    prevDetailId?: number
    nextDetailId?: number
    transactionType: string
    amount: number
    balanceBefore: number
    balanceAfter: number
    description?: string
    transactionTime?: string
    createTime?: string
    updateTime?: string
    isDelete?: boolean
}

// 查询参数类型
export interface BalanceDetailQuery extends PaginationParams {
    userId?: number
    transactionType?: string
    startTime?: string
    endTime?: string
}

// 创建余额明细记录（自动维护双链表）
export const createBalanceDetail = (data: RfBalanceDetail): Promise<boolean> => {
    return post('/api/rf/balance-detail/create', data)
}

// 根据ID删除余额明细
export const deleteBalanceDetail = (id: number): Promise<boolean> => {
    return del(`/api/rf/balance-detail/${id}`)
}

// 批量删除余额明细
export const batchDeleteBalanceDetails = (ids: number[]): Promise<boolean> => {
    return service.delete('/api/rf/balance-detail/batch', { data: ids })
}

// 更新余额明细
export const updateBalanceDetail = (data: RfBalanceDetail): Promise<boolean> => {
    return put('/api/rf/balance-detail', data)
}

// 根据ID查询余额明细
export const getBalanceDetailById = (id: number): Promise<RfBalanceDetail> => {
    return get(`/api/rf/balance-detail/${id}`)
}

// 根据用户ID查询余额明细
export const getBalanceDetailsByUserId = (userId: number): Promise<RfBalanceDetail[]> => {
    return get(`/api/rf/balance-detail/user/${userId}`)
}

// 分页查询用户余额明细
export const getBalanceDetailsByUserIdPage = (
    userId: number,
    params: PaginationParams
): Promise<PaginationResponse<RfBalanceDetail>> => {
    return get(`/api/rf/balance-detail/user/${userId}/page`, params as Record<string, unknown>)
}

// 根据用户ID和交易类型查询余额明细
export const getBalanceDetailsByUserIdAndType = (
    userId: number,
    transactionType: string
): Promise<RfBalanceDetail[]> => {
    return get(`/api/rf/balance-detail/user/${userId}/type/${transactionType}`)
}

// 根据时间范围查询用户余额明细
export const getBalanceDetailsByTimeRange = (
    userId: number,
    startTime?: string,
    endTime?: string
): Promise<RfBalanceDetail[]> => {
    return get(`/api/rf/balance-detail/user/${userId}/time-range`, {
        startTime,
        endTime
    })
}

// 获取用户最新的余额明细记录
export const getLatestBalanceDetailByUserId = (userId: number): Promise<RfBalanceDetail> => {
    return get(`/api/rf/balance-detail/user/${userId}/latest`)
}

// 获取用户当前余额
export const getCurrentBalance = (userId: number): Promise<number> => {
    return get(`/api/rf/balance-detail/user/${userId}/current-balance`)
}

// 根据交易类型统计用户总金额
export const sumAmountByUserIdAndType = (
    userId: number,
    transactionType: string
): Promise<number> => {
    return get(`/api/rf/balance-detail/user/${userId}/sum/${transactionType}`)
}

// 获取上一条明细记录
export const getPrevBalanceDetail = (detailId: number): Promise<RfBalanceDetail> => {
    return get(`/api/rf/balance-detail/${detailId}/prev`)
}

// 获取下一条明细记录
export const getNextBalanceDetail = (detailId: number): Promise<RfBalanceDetail> => {
    return get(`/api/rf/balance-detail/${detailId}/next`)
}

// 分页条件查询余额明细
export const getBalanceDetailsPage = (
    params: BalanceDetailQuery
): Promise<PaginationResponse<RfBalanceDetail>> => {
    return get('/api/rf/balance-detail/page', params as Record<string, unknown>)
}

// 不分页条件查询余额明细
export const getBalanceDetailsList = (condition: Partial<RfBalanceDetail>): Promise<RfBalanceDetail[]> => {
    return get('/api/rf/balance-detail/list', condition)
}

// 查询所有余额明细
export const getAllBalanceDetails = (): Promise<RfBalanceDetail[]> => {
    return get('/api/rf/balance-detail/all')
}

// 导出控制器类
export const RfBalanceDetailController = {
    createBalanceDetail,
    deleteBalanceDetail,
    batchDeleteBalanceDetails,
    updateBalanceDetail,
    getBalanceDetailById,
    getBalanceDetailsByUserId,
    getBalanceDetailsByUserIdPage,
    getBalanceDetailsByUserIdAndType,
    getBalanceDetailsByTimeRange,
    getLatestBalanceDetailByUserId,
    getCurrentBalance,
    sumAmountByUserIdAndType,
    getPrevBalanceDetail,
    getNextBalanceDetail,
    getBalanceDetailsPage,
    getBalanceDetailsList,
    getAllBalanceDetails,
} 