import { get, post, put, del } from '@/utils/request'

// 内部物流任务查询参数接口
export interface InternalLogisticsTaskQuery {
    current?: number
    size?: number
    productId?: number
    productSellRecordId?: number
    productConsignmentRecordId?: number
    productReturnRecordId?: number
    productReturnToSellerRecordId?: number
    taskType?: string
    logisticsUserId?: number
    status?: string
}

// 内部物流任务接口
export interface RfInternalLogisticsTask {
    id?: number
    productId?: number
    productSellRecordId?: number
    productConsignmentRecordId?: number
    productReturnRecordId?: number
    productReturnToSellerRecordId?: number
    taskType?: string
    logisticsUserId?: number
    sourceAddress?: string
    sourceAddressImageUrlJson?: string
    targetAddress?: string
    targetAddressImageUrlJson?: string
    logisticsCost?: number
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

class RfInternalLogisticsTaskController {
    private baseUrl = '/api/rf/internal-logistics-task'

    /**
     * 新增内部物流任务
     */
    async add(data: RfInternalLogisticsTask): Promise<boolean> {
        return post<boolean>(this.baseUrl, data)
    }

    /**
     * 根据ID删除内部物流任务
     */
    async delete(id: number): Promise<boolean> {
        return del<boolean>(`${this.baseUrl}/${id}`)
    }

    /**
     * 批量删除内部物流任务
     */
    async deleteBatch(ids: number[]): Promise<boolean> {
        return del<boolean>(`${this.baseUrl}/batch`, { ids })
    }

    /**
     * 更新内部物流任务
     */
    async update(data: RfInternalLogisticsTask): Promise<boolean> {
        return put<boolean>(this.baseUrl, data)
    }

    /**
     * 根据ID查询内部物流任务
     */
    async getById(id: number): Promise<RfInternalLogisticsTask> {
        return get<RfInternalLogisticsTask>(`${this.baseUrl}/${id}`)
    }

    /**
     * 分页条件查询内部物流任务
     */
    async page(params: InternalLogisticsTaskQuery): Promise<PageResponse<RfInternalLogisticsTask>> {
        return get<PageResponse<RfInternalLogisticsTask>>(`${this.baseUrl}/page`, params as Record<string, unknown>)
    }

    /**
     * 不分页条件查询内部物流任务
     */
    async list(params?: Partial<InternalLogisticsTaskQuery>): Promise<RfInternalLogisticsTask[]> {
        return get<RfInternalLogisticsTask[]>(`${this.baseUrl}/list`, params)
    }

    /**
     * 查询所有内部物流任务
     */
    async all(): Promise<RfInternalLogisticsTask[]> {
        return get<RfInternalLogisticsTask[]>(`${this.baseUrl}/all`)
    }
}

export const rfInternalLogisticsTaskController = new RfInternalLogisticsTaskController() 