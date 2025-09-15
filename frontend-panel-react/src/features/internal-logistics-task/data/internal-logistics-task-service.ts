import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { rfInternalLogisticsTaskController } from '@/api'
import type { InternalLogisticsTask, InternalLogisticsTaskQuery } from './schema'
import type { RfInternalLogisticsTask, InternalLogisticsTaskQuery as ApiQuery } from '@/api/RfInternalLogisticsTaskController'

// 查询键
export const INTERNAL_LOGISTICS_TASK_QUERY_KEYS = {
    all: ['internal-logistics-task'] as const,
    page: (params: InternalLogisticsTaskQuery) => ['internal-logistics-task', 'page', params] as const,
    list: (params?: Partial<InternalLogisticsTaskQuery>) => ['internal-logistics-task', 'list', params] as const,
    detail: (id: number) => ['internal-logistics-task', 'detail', id] as const,
}

// 类型转换函数
const transformToApi = (data: InternalLogisticsTask): RfInternalLogisticsTask => {
    return {
        ...data,
    }
}

const transformFromApi = (data: RfInternalLogisticsTask): InternalLogisticsTask => {
    return {
        ...data,
    }
}

// 获取分页数据
export const useInternalLogisticsTaskPage = (params: InternalLogisticsTaskQuery) => {
    return useQuery({
        queryKey: INTERNAL_LOGISTICS_TASK_QUERY_KEYS.page(params),
        queryFn: () => {
            const apiParams: ApiQuery = {
                current: params.current,
                size: params.size,
                productId: params.productId,
                productSellRecordId: params.productSellRecordId,
                taskType: params.taskType,
                logisticsUserId: params.logisticsUserId,
                status: params.status,
            }
            return rfInternalLogisticsTaskController.page(apiParams)
        },
        select: (data) => ({
            ...data,
            records: data.records.map(transformFromApi),
        }),
    })
}

// 获取列表数据
export const useInternalLogisticsTaskList = (params?: Partial<InternalLogisticsTaskQuery>) => {
    return useQuery({
        queryKey: INTERNAL_LOGISTICS_TASK_QUERY_KEYS.list(params),
        queryFn: () => rfInternalLogisticsTaskController.list(params),
        select: (data) => data.map(transformFromApi),
    })
}

// 获取详情
export const useInternalLogisticsTaskDetail = (id: number) => {
    return useQuery({
        queryKey: INTERNAL_LOGISTICS_TASK_QUERY_KEYS.detail(id),
        queryFn: () => rfInternalLogisticsTaskController.getById(id),
        select: transformFromApi,
        enabled: !!id,
    })
}

// 新增
export const useAddInternalLogisticsTask = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: InternalLogisticsTask) =>
            rfInternalLogisticsTaskController.add(transformToApi(data)),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: INTERNAL_LOGISTICS_TASK_QUERY_KEYS.all
            })
            toast.success('新增成功')
        },
        onError: (error: Error) => {
            toast.error(`新增失败: ${error.message}`)
        },
    })
}

// 更新
export const useUpdateInternalLogisticsTask = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (data: InternalLogisticsTask) =>
            rfInternalLogisticsTaskController.update(transformToApi(data)),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: INTERNAL_LOGISTICS_TASK_QUERY_KEYS.all
            })
            toast.success('更新成功')
        },
        onError: (error: Error) => {
            toast.error(`更新失败: ${error.message}`)
        },
    })
}

// 删除
export const useDeleteInternalLogisticsTask = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => rfInternalLogisticsTaskController.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: INTERNAL_LOGISTICS_TASK_QUERY_KEYS.all
            })
            toast.success('删除成功')
        },
        onError: (error: Error) => {
            toast.error(`删除失败: ${error.message}`)
        },
    })
}

// 批量删除
export const useDeleteInternalLogisticsTaskBatch = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (ids: number[]) => rfInternalLogisticsTaskController.deleteBatch(ids),
        onSuccess: () => {
            queryClient.invalidateQueries({
                queryKey: INTERNAL_LOGISTICS_TASK_QUERY_KEYS.all
            })
            toast.success('批量删除成功')
        },
        onError: (error: Error) => {
            toast.error(`批量删除失败: ${error.message}`)
        },
    })
} 