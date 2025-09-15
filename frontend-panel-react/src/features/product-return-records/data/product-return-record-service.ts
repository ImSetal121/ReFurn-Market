import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
    RfProductReturnRecordController,
    type RfProductReturnRecord,
    type RfProductReturnRecordPageParams
} from '@/api/RfProductReturnRecordController';

const QUERY_KEY = 'productReturnRecords';

// 分页查询商品退货记录
export function useProductReturnRecords(params: RfProductReturnRecordPageParams) {
    return useQuery({
        queryKey: [QUERY_KEY, 'page', params],
        queryFn: () => RfProductReturnRecordController.getPage(params),
        enabled: !!params,
    });
}

// 获取单个商品退货记录
export function useProductReturnRecord(id: number) {
    return useQuery({
        queryKey: [QUERY_KEY, id],
        queryFn: () => RfProductReturnRecordController.getById(id),
        enabled: !!id,
    });
}

// 创建商品退货记录
export function useCreateProductReturnRecord() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: RfProductReturnRecordController.create,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
            toast.success('商品退货记录创建成功');
        },
        onError: (error: Error) => {
            toast.error(`创建失败: ${error.message}`);
        },
    });
}

// 更新商品退货记录
export function useUpdateProductReturnRecord() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: RfProductReturnRecordController.update,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
            toast.success('商品退货记录更新成功');
        },
        onError: (error: Error) => {
            toast.error(`更新失败: ${error.message}`);
        },
    });
}

// 删除商品退货记录
export function useDeleteProductReturnRecord() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: RfProductReturnRecordController.delete,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
            toast.success('商品退货记录删除成功');
        },
        onError: (error: Error) => {
            toast.error(`删除失败: ${error.message}`);
        },
    });
}

// 批量删除商品退货记录
export function useBatchDeleteProductReturnRecords() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: RfProductReturnRecordController.batchDelete,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
            toast.success('批量删除成功');
        },
        onError: (error: Error) => {
            toast.error(`批量删除失败: ${error.message}`);
        },
    });
} 