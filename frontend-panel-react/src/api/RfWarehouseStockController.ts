import { get, post, put, del } from '@/utils/request'

// 仓库库存查询参数接口
export interface WarehouseStockQuery {
    current?: number
    size?: number
    warehouseId?: number
    productId?: number
    warehouseInApplyId?: number
    warehouseInId?: number
    warehouseOutId?: number
    status?: 'IN_STOCK' | 'OUT_OF_STOCK'
}

// 仓库库存接口
export interface RfWarehouseStock {
    id?: number
    warehouseId?: number
    productId?: number
    stockQuantity?: number
    stockPosition?: string
    warehouseInApplyId?: number
    warehouseInId?: number
    inTime?: string
    warehouseOutId?: number
    outTime?: string
    status?: 'IN_STOCK' | 'OUT_OF_STOCK'
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

class RfWarehouseStockController {
    private baseUrl = '/api/rf/warehouse-stock'

    /**
     * 新增仓库库存
     */
    async add(data: RfWarehouseStock): Promise<boolean> {
        return post<boolean>(this.baseUrl, data)
    }

    /**
     * 根据ID删除仓库库存
     */
    async delete(id: number): Promise<boolean> {
        return del<boolean>(`${this.baseUrl}/${id}`)
    }

    /**
     * 批量删除仓库库存
     */
    async deleteBatch(ids: number[]): Promise<boolean> {
        return del<boolean>(`${this.baseUrl}/batch`, { ids })
    }

    /**
     * 更新仓库库存
     */
    async update(data: RfWarehouseStock): Promise<boolean> {
        return put<boolean>(this.baseUrl, data)
    }

    /**
     * 根据ID查询仓库库存
     */
    async getById(id: number): Promise<RfWarehouseStock> {
        return get<RfWarehouseStock>(`${this.baseUrl}/${id}`)
    }

    /**
     * 分页条件查询仓库库存
     */
    async page(params: WarehouseStockQuery): Promise<PageResponse<RfWarehouseStock>> {
        return get<PageResponse<RfWarehouseStock>>(`${this.baseUrl}/page`, params as Record<string, unknown>)
    }

    /**
     * 不分页条件查询仓库库存
     */
    async list(params?: Partial<WarehouseStockQuery>): Promise<RfWarehouseStock[]> {
        return get<RfWarehouseStock[]>(`${this.baseUrl}/list`, params)
    }

    /**
     * 查询所有仓库库存
     */
    async all(): Promise<RfWarehouseStock[]> {
        return get<RfWarehouseStock[]>(`${this.baseUrl}/all`)
    }
}

export const rfWarehouseStockController = new RfWarehouseStockController() 