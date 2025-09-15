import { get, post, put, del } from '@/utils/request'
import type { PageResponse } from '@/types/api'

export interface RfProductSellRecord {
    id?: number
    productId?: number
    product?: {
        id: number
        name: string
        price: number
    }
    sellerUserId?: number
    buyerUserId?: number
    finalProductPrice?: number
    isAuction?: boolean
    productWarehouseShipmentId?: number
    internalLogisticsTaskId?: number
    isSelfPickup?: boolean
    productSelfPickupLogisticsId?: number
    buyerReceiptImageUrlJson?: string
    sellerReturnImageUrlJson?: string
    status?: string
    createTime?: string
    updateTime?: string
    isDelete?: boolean
}

export interface ProductSellRecordQuery {
    current?: number
    size?: number
    productId?: number
    sellerUserId?: number
    buyerUserId?: number
    status?: string
    isAuction?: boolean
    isSelfPickup?: boolean
}

export const RfProductSellRecordController = {
    /**
     * 分页查询商品销售记录
     */
    page: (params: ProductSellRecordQuery): Promise<PageResponse<RfProductSellRecord>> => {
        return get('/api/rf/product-sell-record/page', params as Record<string, unknown>)
    },

    /**
     * 查询所有商品销售记录
     */
    list: (condition?: Partial<RfProductSellRecord>): Promise<RfProductSellRecord[]> => {
        return get('/api/rf/product-sell-record/list', condition)
    },

    /**
     * 根据ID查询商品销售记录
     */
    getById: (id: number): Promise<RfProductSellRecord> => {
        return get(`/api/rf/product-sell-record/${id}`)
    },

    /**
     * 新增商品销售记录
     */
    add: (data: RfProductSellRecord): Promise<boolean> => {
        return post('/api/rf/product-sell-record', data)
    },

    /**
     * 更新商品销售记录
     */
    update: (data: RfProductSellRecord): Promise<boolean> => {
        return put('/api/rf/product-sell-record', data)
    },

    /**
     * 删除商品销售记录
     */
    delete: (id: number): Promise<boolean> => {
        return del(`/api/rf/product-sell-record/${id}`)
    },

    /**
     * 批量删除商品销售记录
     */
    deleteBatch: (ids: number[]): Promise<boolean> => {
        return del('/api/rf/product-sell-record/batch', { ids })
    }
} 