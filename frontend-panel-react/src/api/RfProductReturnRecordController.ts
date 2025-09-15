import { get, post, put, del } from '@/utils/request';

export interface RfProductReturnRecord {
    id?: number;
    productId?: number;
    productSellRecordId?: number;
    returnReasonType?: string;
    returnReasonDetail?: string;
    pickupAddress?: string;
    sellerAcceptReturn?: boolean;
    sellerOpinionDetail?: string;
    auditResult?: string;
    auditDetail?: string;
    freightBearer?: string;
    freightBearerUserId?: number;
    needCompensateProduct?: boolean;
    compensationBearer?: string;
    compensationBearerUserId?: number;
    isAuction?: boolean;
    isUseLogisticsService?: boolean;
    appointmentPickupTime?: string;
    internalLogisticsTaskId?: number;
    externalLogisticsServiceName?: string;
    externalLogisticsOrderNumber?: string;
    status?: string;
    createTime?: string;
    updateTime?: string;
    isDelete?: boolean;
}

export interface RfProductReturnRecordPageResponse {
    records: RfProductReturnRecord[];
    total: number;
    size: number;
    current: number;
    pages: number;
}

export interface RfProductReturnRecordPageParams {
    current?: number;
    size?: number;
    id?: number;
    productId?: number;
    productSellRecordId?: number;
    returnReasonType?: string;
    pickupAddress?: string;
    sellerAcceptReturn?: boolean;
    auditResult?: string;
    freightBearer?: string;
    compensationBearer?: string;
    status?: string;
    isAuction?: boolean;
    isUseLogisticsService?: boolean;
    needCompensateProduct?: boolean;
    isDelete?: boolean;
    [key: string]: unknown;
}

const BASE_URL = '/api/rf/product-return-record';

export const RfProductReturnRecordController = {
    // 分页查询
    getPage: (params: RfProductReturnRecordPageParams): Promise<RfProductReturnRecordPageResponse> =>
        get(`${BASE_URL}/page`, params),

    // 获取所有记录
    getList: (params?: Partial<RfProductReturnRecord>): Promise<RfProductReturnRecord[]> =>
        get(`${BASE_URL}/list`, params),

    // 获取单个记录
    getById: (id: number): Promise<RfProductReturnRecord> =>
        get(`${BASE_URL}/${id}`),

    // 创建记录
    create: (data: Omit<RfProductReturnRecord, 'id' | 'createTime' | 'updateTime'>): Promise<boolean> =>
        post(`${BASE_URL}`, data),

    // 更新记录
    update: (data: RfProductReturnRecord): Promise<boolean> =>
        put(`${BASE_URL}`, data),

    // 删除记录
    delete: (id: number): Promise<boolean> =>
        del(`${BASE_URL}/${id}`),

    // 批量删除
    batchDelete: (ids: number[]): Promise<boolean> =>
        del(`${BASE_URL}/batch`, { ids }),
}; 