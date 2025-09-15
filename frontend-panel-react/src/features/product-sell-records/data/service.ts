import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { RfProductSellRecordController, type PageResponse } from '@/api'
import type { ProductSellRecord, ProductSellRecordQuery } from './schema'

// 查询键
export const PRODUCT_SELL_RECORDS_QUERY_KEY = 'product-sell-records'

// 获取商品销售记录分页数据
export const useProductSellRecordsPage = (params: ProductSellRecordQuery) => {
    return useQuery({
        queryKey: [PRODUCT_SELL_RECORDS_QUERY_KEY, 'page', params],
        queryFn: async () => {
            const result = await RfProductSellRecordController.page(params)
            return result as unknown as PageResponse<ProductSellRecord>
        },
    })
}

// 获取商品销售记录列表
export const useProductSellRecordsList = (condition?: Partial<ProductSellRecord>) => {
    return useQuery({
        queryKey: [PRODUCT_SELL_RECORDS_QUERY_KEY, 'list', condition],
        queryFn: () => RfProductSellRecordController.list(condition),
    })
}

// 添加商品销售记录
export const useAddProductSellRecord = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (record: ProductSellRecord) => RfProductSellRecordController.add(record),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [PRODUCT_SELL_RECORDS_QUERY_KEY] })
            toast.success('销售记录添加成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '添加销售记录失败')
        },
    })
}

// 更新商品销售记录
export const useUpdateProductSellRecord = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (record: ProductSellRecord) => RfProductSellRecordController.update(record),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [PRODUCT_SELL_RECORDS_QUERY_KEY] })
            toast.success('销售记录更新成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '更新销售记录失败')
        },
    })
}

// 删除商品销售记录
export const useDeleteProductSellRecord = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => RfProductSellRecordController.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [PRODUCT_SELL_RECORDS_QUERY_KEY] })
            toast.success('销售记录删除成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '删除销售记录失败')
        },
    })
}

// 获取单个商品销售记录
export const useProductSellRecord = (id: number) => {
    return useQuery({
        queryKey: [PRODUCT_SELL_RECORDS_QUERY_KEY, id],
        queryFn: () => RfProductSellRecordController.getById(id),
        enabled: !!id,
    })
} 