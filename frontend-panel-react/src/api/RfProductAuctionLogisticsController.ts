import { get, post, put, del } from '@/utils/request'

// 商品寄卖物流记录查询参数接口
export interface ProductAuctionLogisticsQuery {
    current?: number
    size?: number
    productId?: number
    productSellRecordId?: number
    warehouseId?: number
    isUseLogisticsService?: boolean
    status?: string
}

// 商品寄卖物流记录接口
export interface RfProductAuctionLogistics {
    id?: number
    productId?: number
    productSellRecordId?: number
    pickupAddress?: string
    warehouseId?: number
    warehouseAddress?: string
    isUseLogisticsService?: boolean
    appointmentPickupDate?: string
    appointmentPickupTimePeriod?: string
    internalLogisticsTaskId?: number
    externalLogisticsServiceName?: string
    externalLogisticsOrderNumber?: string
    status?: string
    createTime?: string
    updateTime?: string
    isDelete?: boolean
}

// 分页响应接口
export interface PageResponse<T> {
    records: T[]
    total: number
    size: number
    current: number
    pages: number
}

class RfProductAuctionLogisticsController {
    private baseUrl = '/api/rf/product-auction-logistics'

    /**
     * 新增商品寄卖物流记录
     */
    async add(data: RfProductAuctionLogistics): Promise<boolean> {
        return post<boolean>(this.baseUrl, data)
    }

    /**
     * 根据ID删除商品寄卖物流记录
     */
    async delete(id: number): Promise<boolean> {
        return del<boolean>(`${this.baseUrl}/${id}`)
    }

    /**
     * 批量删除商品寄卖物流记录
     */
    async deleteBatch(ids: number[]): Promise<boolean> {
        return del<boolean>(`${this.baseUrl}/batch`, { ids })
    }

    /**
     * 更新商品寄卖物流记录
     */
    async update(data: RfProductAuctionLogistics): Promise<boolean> {
        return put<boolean>(this.baseUrl, data)
    }

    /**
     * 根据ID查询商品寄卖物流记录
     */
    async getById(id: number): Promise<RfProductAuctionLogistics> {
        return get<RfProductAuctionLogistics>(`${this.baseUrl}/${id}`)
    }

    /**
     * 分页条件查询商品寄卖物流记录
     */
    async page(params: ProductAuctionLogisticsQuery): Promise<PageResponse<RfProductAuctionLogistics>> {
        return get<PageResponse<RfProductAuctionLogistics>>(`${this.baseUrl}/page`, params as Record<string, unknown>)
    }

    /**
     * 不分页条件查询商品寄卖物流记录
     */
    async list(params?: Partial<ProductAuctionLogisticsQuery>): Promise<RfProductAuctionLogistics[]> {
        return get<RfProductAuctionLogistics[]>(`${this.baseUrl}/list`, params)
    }

    /**
     * 查询所有商品寄卖物流记录
     */
    async all(): Promise<RfProductAuctionLogistics[]> {
        return get<RfProductAuctionLogistics[]>(`${this.baseUrl}/all`)
    }
}

export const rfProductAuctionLogisticsController = new RfProductAuctionLogisticsController() 