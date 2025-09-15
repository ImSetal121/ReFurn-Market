import { get, post, put, del } from '@/utils/request';

export interface RfProductReturnToSeller {
    id?: number;
    productId?: number;
    productSellRecordId?: number;
    warehouseId?: number;
    warehouseAddress?: string;
    sellerReceiptAddress?: string;
    internalLogisticsTaskId?: number;
    shipmentTime?: string;
    shipmentImageUrlJson?: string;
    status?: string;
    createTime?: string;
    updateTime?: string;
    isDelete?: boolean;
}

export interface RfProductReturnToSellerPageResponse {
    records: RfProductReturnToSeller[];
    total: number;
    size: number;
    current: number;
    pages: number;
}

export interface RfProductReturnToSellerPageParams {
    current?: number;
    size?: number;
    id?: number;
    productId?: number;
    productSellRecordId?: number;
    warehouseId?: number;
    warehouseAddress?: string;
    sellerReceiptAddress?: string;
    internalLogisticsTaskId?: number;
    status?: string;
    isDelete?: boolean;
    [key: string]: unknown;
}

const BASE_URL = '/api/rf/product-return-to-seller';

export const RfProductReturnToSellerController = {
    // 分页查询
    getPage: (params: RfProductReturnToSellerPageParams): Promise<RfProductReturnToSellerPageResponse> =>
        get(`${BASE_URL}/page`, params),

    // 获取所有记录
    getList: (params?: Partial<RfProductReturnToSeller>): Promise<RfProductReturnToSeller[]> =>
        get(`${BASE_URL}/list`, params),

    // 获取单个记录
    getById: (id: number): Promise<RfProductReturnToSeller> =>
        get(`${BASE_URL}/${id}`),

    // 创建记录
    create: (data: Omit<RfProductReturnToSeller, 'id' | 'createTime' | 'updateTime'>): Promise<boolean> =>
        post(`${BASE_URL}`, data),

    // 更新记录
    update: (data: RfProductReturnToSeller): Promise<boolean> =>
        put(`${BASE_URL}`, data),

    // 删除记录
    delete: (id: number): Promise<boolean> =>
        del(`${BASE_URL}/${id}`),

    // 批量删除
    batchDelete: (ids: number[]): Promise<boolean> =>
        del(`${BASE_URL}/batch`, { ids }),
}; 