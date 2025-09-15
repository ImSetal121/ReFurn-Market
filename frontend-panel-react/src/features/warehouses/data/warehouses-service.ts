import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
    getWarehousePage,
    addWarehouse,
    updateWarehouse,
    deleteWarehouse,
    batchDeleteWarehouses,
    getAllWarehouses
} from '@/api/RfWarehouseController'
import type { WarehouseQuery } from '@/api/RfWarehouseController'
import { toast } from 'sonner'

// 查询键
const QUERY_KEYS = {
    warehouses: 'warehouses',
    warehousePage: 'warehousePage',
    allWarehouses: 'allWarehouses',
}

/**
 * 获取仓库分页数据
 */
export function useWarehousesPage(params: WarehouseQuery) {
    return useQuery({
        queryKey: [QUERY_KEYS.warehousePage, params],
        queryFn: () => getWarehousePage(params),
        select: (data) => data,
    })
}

/**
 * 获取所有仓库数据
 */
export function useAllWarehouses() {
    return useQuery({
        queryKey: [QUERY_KEYS.allWarehouses],
        queryFn: getAllWarehouses,
        select: (data) => data,
    })
}

/**
 * 新增仓库
 */
export function useAddWarehouse() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: addWarehouse,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.warehousePage] })
            queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.allWarehouses] })
            toast.success('仓库添加成功')
        },
        onError: (error: Error) => {
            toast.error(error?.message || '仓库添加失败')
        },
    })
}

/**
 * 更新仓库
 */
export function useUpdateWarehouse() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: updateWarehouse,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.warehousePage] })
            queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.allWarehouses] })
            toast.success('仓库更新成功')
        },
        onError: (error: Error) => {
            toast.error(error?.message || '仓库更新失败')
        },
    })
}

/**
 * 删除仓库
 */
export function useDeleteWarehouse() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: deleteWarehouse,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.warehousePage] })
            queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.allWarehouses] })
            toast.success('仓库删除成功')
        },
        onError: (error: Error) => {
            toast.error(error?.message || '仓库删除失败')
        },
    })
}

/**
 * 批量删除仓库
 */
export function useBatchDeleteWarehouses() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: batchDeleteWarehouses,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.warehousePage] })
            queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.allWarehouses] })
            toast.success('仓库批量删除成功')
        },
        onError: (error: Error) => {
            toast.error(error?.message || '仓库批量删除失败')
        },
    })
} 