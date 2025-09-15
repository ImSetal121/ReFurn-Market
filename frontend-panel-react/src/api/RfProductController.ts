import { get, post, put, del } from '@/utils/request';

export interface RfProduct {
    id?: number;
    userId?: number;
    name: string;
    categoryId?: number;
    type?: string;
    category?: string;
    price?: number;
    stock?: number;
    description?: string;
    imageUrlJson?: string;
    isAuction?: boolean;
    address?: string;
    isSelfPickup?: boolean;
    status?: string;
    createTime?: string;
    updateTime?: string;
    isDelete?: boolean;
}

export interface ProductQuery {
    current?: number;
    size?: number;
    name?: string;
    categoryId?: number;
    type?: string;
    isAuction?: boolean;
    isSelfPickup?: boolean;
    status?: string;
}

export interface PageResponse<T> {
    records: T[];
    total: number;
    size: number;
    current: number;
    pages: number;
}

/**
 * 商品控制器API
 */
export class RfProductController {
    /**
     * 新增商品
     * @param data 商品数据
     */
    static add(data: RfProduct): Promise<boolean> {
        return post('/api/rf/product', data);
    }

    /**
     * 删除商品
     * @param id 商品ID
     */
    static delete(id: number): Promise<boolean> {
        return del(`/api/rf/product/${id}`);
    }

    /**
     * 批量删除商品
     * @param ids 商品ID数组
     */
    static deleteByIds(ids: number[]): Promise<boolean> {
        return del('/api/rf/product/batch', { ids });
    }

    /**
     * 更新商品
     * @param data 商品数据
     */
    static update(data: RfProduct): Promise<boolean> {
        return put('/api/rf/product', data);
    }

    /**
     * 根据ID查询商品
     * @param id 商品ID
     */
    static getById(id: number): Promise<RfProduct> {
        return get(`/api/rf/product/${id}`);
    }

    /**
     * 分页查询商品
     * @param params 查询参数
     */
    static page(params: ProductQuery): Promise<PageResponse<RfProduct>> {
        // 确保分页参数存在且为数字
        const queryParams = {
            ...params,
            current: params.current || 1,
            size: params.size || 10
        };
        return get('/api/rf/product/page', queryParams);
    }

    /**
     * 查询商品列表
     * @param params 查询参数
     */
    static list(params?: Partial<RfProduct>): Promise<RfProduct[]> {
        return get('/api/rf/product/list', params);
    }

    /**
     * 查询所有商品
     */
    static all(): Promise<RfProduct[]> {
        return get('/api/rf/product/all');
    }
}

// 导出默认实例方法（兼容现有代码）
export const addProduct = RfProductController.add;
export const deleteProduct = RfProductController.delete;
export const updateProduct = RfProductController.update;
export const getProductById = RfProductController.getById;
export const getProductPage = RfProductController.page;
export const getProductList = RfProductController.list; 