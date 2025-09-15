import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { rfProductAuctionLogisticsController } from '@/api'
import type { ProductAuctionLogistics, ProductAuctionLogisticsQuery } from './schema'
import type { RfProductAuctionLogistics, ProductAuctionLogisticsQuery as ApiQuery } from '@/api/RfProductAuctionLogisticsController'

// 查询键
export const PRODUCT_AUCTION_LOGISTICS_QUERY_KEYS = {
    all: ['product-auction-logistics'] as const,
    page: (params: ProductAuctionLogisticsQuery) => ['product-auction-logistics', 'page', params] as const,
    list: (params?: Partial<ProductAuctionLogisticsQuery>) => ['product-auction-logistics', 'list', params] as const,
    detail: (id: number) => ['product-auction-logistics', 'detail', id] as const,
}

// 类型转换函数
const transformToApi = (data: ProductAuctionLogistics): RfProductAuctionLogistics => {
    return {
        ...data,
    }
}

const transformFromApi = (data: RfProductAuctionLogistics): ProductAuctionLogistics => {
    return {
        ...data,
    }
}

// 获取分页数据
export const useProductAuctionLogisticsPage = (params: ProductAuctionLogisticsQuery) => {
    const apiParams: ApiQuery = {
        current: params.current,
        size: params.size,
        productId: params.productId,
        productSellRecordId: params.productSellRecordId,
        warehouseId: params.warehouseId,
        isUseLogisticsService: params.isUseLogisticsService,
        status: params.status,
    }

    return useQuery({
        queryKey: PRODUCT_AUCTION_LOGISTICS_QUERY_KEYS.page(params),
        queryFn: () => rfProductAuctionLogisticsController.page(apiParams),
        select: (data) => ({
            ...data,
            records: data.records.map(transformFromApi),
        }),
    })
}

// 获取列表数据
export const useProductAuctionLogisticsList = (params?: Partial<ProductAuctionLogisticsQuery>) => {
    return useQuery({
        queryKey: PRODUCT_AUCTION_LOGISTICS_QUERY_KEYS.list(params),
        queryFn: () => rfProductAuctionLogisticsController.list(params),
        select: (data) => data.map(transformFromApi),
    })
}

// 获取详情
export const useProductAuctionLogisticsDetail = (id: number) => {
    return useQuery({
        queryKey: PRODUCT_AUCTION_LOGISTICS_QUERY_KEYS.detail(id),
        queryFn: () => rfProductAuctionLogisticsController.getById(id),
        select: transformFromApi,
        enabled: !!id,
    })
}

// 新增
export const useAddProductAuctionLogistics = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: ProductAuctionLogistics) =>
            rfProductAuctionLogisticsController.add(transformToApi(data)),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: PRODUCT_AUCTION_LOGISTICS_QUERY_KEYS.all
            })
            toast.success('新增成功')
        },
        onError: (error: Error) => {
            toast.error(`新增失败: ${error.message}`)
        },
    })
}

// 更新
export const useUpdateProductAuctionLogistics = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: ProductAuctionLogistics) =>
            rfProductAuctionLogisticsController.update(transformToApi(data)),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: PRODUCT_AUCTION_LOGISTICS_QUERY_KEYS.all
            })
            toast.success('更新成功')
        },
        onError: (error: Error) => {
            toast.error(`更新失败: ${error.message}`)
        },
    })
}

// 删除
export const useDeleteProductAuctionLogistics = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => rfProductAuctionLogisticsController.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: PRODUCT_AUCTION_LOGISTICS_QUERY_KEYS.all
            })
            toast.success('删除成功')
        },
        onError: (error: Error) => {
            toast.error(`删除失败: ${error.message}`)
        },
    })
}

// 批量删除
export const useDeleteProductAuctionLogisticsBatch = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (ids: number[]) => rfProductAuctionLogisticsController.deleteBatch(ids),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: PRODUCT_AUCTION_LOGISTICS_QUERY_KEYS.all
            })
            toast.success('批量删除成功')
        },
        onError: (error: Error) => {
            toast.error(`批量删除失败: ${error.message}`)
        },
    })
} 