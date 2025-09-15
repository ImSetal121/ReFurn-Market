import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import {
    getBillItemsPage,
    createBillItem,
    updateBillItem,
    deleteBillItem,
    batchDeleteBillItems,
    getBillItemById,
    type RfBillItem,
    type BillItemQuery,
} from '@/api/RfBillItemController'
import { getUserList } from '@/api/SysUserController'
import { getProductList } from '@/api/RfProductController'
import type { BillItemQuery as QueryParams } from './schema'

// 查询键
const BILL_ITEMS_KEYS = {
    all: ['bill-items'] as const,
    lists: () => [...BILL_ITEMS_KEYS.all, 'list'] as const,
    list: (filters: QueryParams) => [...BILL_ITEMS_KEYS.lists(), { filters }] as const,
    details: () => [...BILL_ITEMS_KEYS.all, 'detail'] as const,
    detail: (id: number) => [...BILL_ITEMS_KEYS.details(), id] as const,
    users: () => ['users'] as const,
    products: () => ['products'] as const,
}

// 获取账单项分页数据
export const useBillItemsPage = (params: QueryParams) => {
    return useQuery({
        queryKey: BILL_ITEMS_KEYS.list(params),
        queryFn: () => getBillItemsPage(params as BillItemQuery),
        staleTime: 5 * 60 * 1000, // 5分钟
    })
}

// 获取账单项详情
export const useBillItem = (id: number) => {
    return useQuery({
        queryKey: BILL_ITEMS_KEYS.detail(id),
        queryFn: () => getBillItemById(id),
        enabled: !!id,
    })
}

// 获取所有用户列表（用于下拉选择）
export const useUsers = () => {
    return useQuery({
        queryKey: BILL_ITEMS_KEYS.users(),
        queryFn: () => getUserList(),
        staleTime: 10 * 60 * 1000, // 10分钟
    })
}

// 获取所有商品列表（用于下拉选择）
export const useProducts = () => {
    return useQuery({
        queryKey: BILL_ITEMS_KEYS.products(),
        queryFn: () => getProductList(),
        staleTime: 10 * 60 * 1000, // 10分钟
    })
}

// 创建账单项
export const useAddBillItem = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: RfBillItem) => createBillItem(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: BILL_ITEMS_KEYS.lists() })
            toast.success('账单项创建成功')
        },
        onError: (error: Error) => {
            toast.error(`创建失败: ${error.message}`)
        },
    })
}

// 更新账单项
export const useUpdateBillItem = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: RfBillItem) => updateBillItem(data),
        onSuccess: (_, variables) => {
            queryClient.invalidateQueries({ queryKey: BILL_ITEMS_KEYS.lists() })
            if (variables.id) {
                queryClient.invalidateQueries({ queryKey: BILL_ITEMS_KEYS.detail(variables.id) })
            }
            toast.success('账单项更新成功')
        },
        onError: (error: Error) => {
            toast.error(`更新失败: ${error.message}`)
        },
    })
}

// 删除账单项
export const useDeleteBillItem = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => deleteBillItem(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: BILL_ITEMS_KEYS.lists() })
            toast.success('账单项删除成功')
        },
        onError: (error: Error) => {
            toast.error(`删除失败: ${error.message}`)
        },
    })
}

// 批量删除账单项
export const useBatchDeleteBillItems = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (ids: number[]) => batchDeleteBillItems(ids),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: BILL_ITEMS_KEYS.lists() })
            toast.success('批量删除成功')
        },
        onError: (error: Error) => {
            toast.error(`批量删除失败: ${error.message}`)
        },
    })
} 