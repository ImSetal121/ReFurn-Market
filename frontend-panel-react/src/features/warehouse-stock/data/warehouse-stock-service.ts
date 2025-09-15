import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { rfWarehouseStockController } from '@/api'
import type { WarehouseStock, WarehouseStockQuery } from './schema'
import type { RfWarehouseStock, WarehouseStockQuery as ApiQuery } from '@/api/RfWarehouseStockController'

// 查询键
export const WAREHOUSE_STOCK_QUERY_KEYS = {
    all: ['warehouse-stock'] as const,
    page: (params: WarehouseStockQuery) => ['warehouse-stock', 'page', params] as const,
    list: (params?: Partial<WarehouseStockQuery>) => ['warehouse-stock', 'list', params] as const,
    detail: (id: number) => ['warehouse-stock', 'detail', id] as const,
}

// 类型转换函数
const transformToApi = (data: WarehouseStock): RfWarehouseStock => {
    return {
        ...data,
    }
}

const transformFromApi = (data: RfWarehouseStock): WarehouseStock => {
    return {
        ...data,
    }
}

// 获取分页数据
export const useWarehouseStockPage = (params: WarehouseStockQuery) => {
    const apiParams: ApiQuery = {
        current: params.current,
        size: params.size,
        warehouseId: params.warehouseId,
        productId: params.productId,
        warehouseInApplyId: params.warehouseInApplyId,
        warehouseInId: params.warehouseInId,
        warehouseOutId: params.warehouseOutId,
        status: params.status,
    }

    return useQuery({
        queryKey: WAREHOUSE_STOCK_QUERY_KEYS.page(params),
        queryFn: () => rfWarehouseStockController.page(apiParams),
        select: (data) => ({
            ...data,
            records: data.records.map(transformFromApi),
        }),
    })
}

// 获取列表数据
export const useWarehouseStockList = (params?: Partial<WarehouseStockQuery>) => {
    return useQuery({
        queryKey: WAREHOUSE_STOCK_QUERY_KEYS.list(params),
        queryFn: () => rfWarehouseStockController.list(params),
        select: (data) => data.map(transformFromApi),
    })
}

// 获取详情
export const useWarehouseStockDetail = (id: number) => {
    return useQuery({
        queryKey: WAREHOUSE_STOCK_QUERY_KEYS.detail(id),
        queryFn: () => rfWarehouseStockController.getById(id),
        select: transformFromApi,
        enabled: !!id,
    })
}

// 新增
export const useAddWarehouseStock = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: WarehouseStock) =>
            rfWarehouseStockController.add(transformToApi(data)),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: WAREHOUSE_STOCK_QUERY_KEYS.all
            })
            toast.success('新增成功')
        },
        onError: (error: Error) => {
            toast.error(`新增失败: ${error.message}`)
        },
    })
}

// 更新
export const useUpdateWarehouseStock = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: WarehouseStock) =>
            rfWarehouseStockController.update(transformToApi(data)),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: WAREHOUSE_STOCK_QUERY_KEYS.all
            })
            toast.success('更新成功')
        },
        onError: (error: Error) => {
            toast.error(`更新失败: ${error.message}`)
        },
    })
}

// 删除
export const useDeleteWarehouseStock = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => rfWarehouseStockController.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: WAREHOUSE_STOCK_QUERY_KEYS.all
            })
            toast.success('删除成功')
        },
        onError: (error: Error) => {
            toast.error(`删除失败: ${error.message}`)
        },
    })
}

// 批量删除
export const useDeleteWarehouseStockBatch = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (ids: number[]) => rfWarehouseStockController.deleteBatch(ids),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: WAREHOUSE_STOCK_QUERY_KEYS.all
            })
            toast.success('批量删除成功')
        },
        onError: (error: Error) => {
            toast.error(`批量删除失败: ${error.message}`)
        },
    })
} 