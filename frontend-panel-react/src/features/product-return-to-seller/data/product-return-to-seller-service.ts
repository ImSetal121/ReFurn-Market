import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
    RfProductReturnToSellerController,
    type RfProductReturnToSeller,
    type RfProductReturnToSellerPageParams
} from '@/api/RfProductReturnToSellerController';

const QUERY_KEY = 'productReturnToSellerRecords';

// 分页查询商品退回卖家记录
export function useProductReturnToSellerRecords(params: RfProductReturnToSellerPageParams) {
    return useQuery({
        queryKey: [QUERY_KEY, 'page', params],
        queryFn: () => RfProductReturnToSellerController.getPage(params),
        enabled: !!params,
    });
}

// 获取单个商品退回卖家记录
export function useProductReturnToSellerRecord(id: number) {
    return useQuery({
        queryKey: [QUERY_KEY, id],
        queryFn: () => RfProductReturnToSellerController.getById(id),
        enabled: !!id,
    });
}

// 创建商品退回卖家记录
export function useCreateProductReturnToSellerRecord() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: RfProductReturnToSellerController.create,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
            toast.success('商品退回卖家记录创建成功');
        },
        onError: (error: Error) => {
            toast.error(`创建失败: ${error.message}`);
        },
    });
}

// 更新商品退回卖家记录
export function useUpdateProductReturnToSellerRecord() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: RfProductReturnToSellerController.update,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
            toast.success('商品退回卖家记录更新成功');
        },
        onError: (error: Error) => {
            toast.error(`更新失败: ${error.message}`);
        },
    });
}

// 删除商品退回卖家记录
export function useDeleteProductReturnToSellerRecord() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: RfProductReturnToSellerController.delete,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
            toast.success('商品退回卖家记录删除成功');
        },
        onError: (error: Error) => {
            toast.error(`删除失败: ${error.message}`);
        },
    });
}

// 批量删除商品退回卖家记录
export function useBatchDeleteProductReturnToSellerRecords() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: RfProductReturnToSellerController.batchDelete,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
            toast.success('批量删除成功');
        },
        onError: (error: Error) => {
            toast.error(`批量删除失败: ${error.message}`);
        },
    });
} 