import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import {
    getBalanceDetailsPage,
    createBalanceDetail,
    updateBalanceDetail,
    deleteBalanceDetail,
    batchDeleteBalanceDetails,
    getBalanceDetailById,
    getCurrentBalance,
    getAllBalanceDetails,
    type RfBalanceDetail,
    type BalanceDetailQuery,
} from '@/api/RfBalanceDetailController'
import { getUserList } from '@/api/SysUserController'
import type { BalanceDetail, BalanceDetailQuery as QueryParams } from './schema'

// 查询键
const BALANCE_DETAILS_KEYS = {
    all: ['balance-details'] as const,
    lists: () => [...BALANCE_DETAILS_KEYS.all, 'list'] as const,
    list: (filters: QueryParams) => [...BALANCE_DETAILS_KEYS.lists(), { filters }] as const,
    details: () => [...BALANCE_DETAILS_KEYS.all, 'detail'] as const,
    detail: (id: number) => [...BALANCE_DETAILS_KEYS.details(), id] as const,
    users: () => ['users'] as const,
}

// 获取余额明细分页数据
export const useBalanceDetailsPage = (params: QueryParams) => {
    return useQuery({
        queryKey: BALANCE_DETAILS_KEYS.list(params),
        queryFn: () => getBalanceDetailsPage(params as BalanceDetailQuery),
        staleTime: 5 * 60 * 1000, // 5分钟
    })
}

// 获取余额明细详情
export const useBalanceDetail = (id: number) => {
    return useQuery({
        queryKey: BALANCE_DETAILS_KEYS.detail(id),
        queryFn: () => getBalanceDetailById(id),
        enabled: !!id,
    })
}

// 获取用户余额
export const useCurrentBalance = (userId: number) => {
    return useQuery({
        queryKey: ['current-balance', userId],
        queryFn: () => getCurrentBalance(userId),
        enabled: !!userId,
        staleTime: 30 * 1000, // 30秒
    })
}

// 获取所有用户列表（用于下拉选择）
export const useUsers = () => {
    return useQuery({
        queryKey: BALANCE_DETAILS_KEYS.users(),
        queryFn: () => getUserList(),
        staleTime: 10 * 60 * 1000, // 10分钟
    })
}

// 创建余额明细
export const useAddBalanceDetail = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: RfBalanceDetail) => createBalanceDetail(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: BALANCE_DETAILS_KEYS.lists() })
            toast.success('余额明细创建成功')
        },
        onError: (error: Error) => {
            toast.error(`创建失败: ${error.message}`)
        },
    })
}

// 更新余额明细
export const useUpdateBalanceDetail = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: RfBalanceDetail) => updateBalanceDetail(data),
        onSuccess: (_, variables) => {
            queryClient.invalidateQueries({ queryKey: BALANCE_DETAILS_KEYS.lists() })
            if (variables.id) {
                queryClient.invalidateQueries({ queryKey: BALANCE_DETAILS_KEYS.detail(variables.id) })
            }
            toast.success('余额明细更新成功')
        },
        onError: (error: Error) => {
            toast.error(`更新失败: ${error.message}`)
        },
    })
}

// 删除余额明细
export const useDeleteBalanceDetail = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => deleteBalanceDetail(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: BALANCE_DETAILS_KEYS.lists() })
            toast.success('余额明细删除成功')
        },
        onError: (error: Error) => {
            toast.error(`删除失败: ${error.message}`)
        },
    })
}

// 批量删除余额明细
export const useBatchDeleteBalanceDetails = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (ids: number[]) => batchDeleteBalanceDetails(ids),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: BALANCE_DETAILS_KEYS.lists() })
            toast.success('批量删除成功')
        },
        onError: (error: Error) => {
            toast.error(`批量删除失败: ${error.message}`)
        },
    })
} 