import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { RfProductController, type PageResponse, type RfProduct, type ProductQuery } from '@/api/RfProductController'
import type { Product } from './schema'

// 查询键
export const PRODUCTS_QUERY_KEY = 'products'

// 转换后端商品数据到前端商品数据
function transformRfProductToProduct(rfProduct: RfProduct): Product {
    return {
        id: rfProduct.id,
        userId: rfProduct.userId,
        name: rfProduct.name,
        type: rfProduct.type,
        price: rfProduct.price,
        stock: rfProduct.stock,
        isAuction: rfProduct.isAuction,
        status: rfProduct.status as 'LISTED' | 'UNLISTED' | 'SOLD',
        description: rfProduct.description,
        imageUrlJson: rfProduct.imageUrlJson,
        address: rfProduct.address,
        isSelfPickup: rfProduct.isSelfPickup,
        categoryId: rfProduct.categoryId,
        category: rfProduct.category,
        createTime: rfProduct.createTime,
        updateTime: rfProduct.updateTime,
        isDelete: rfProduct.isDelete,
    }
}

// 转换前端Product到后端RfProduct类型
const transformProductToRfProduct = (product: Product): RfProduct => {
    return {
        id: product.id,
        userId: product.userId,
        name: product.name,
        categoryId: product.categoryId,
        type: product.type,
        category: product.category,
        price: product.price,
        stock: product.stock,
        description: product.description,
        imageUrlJson: product.imageUrlJson,
        isAuction: product.isAuction,
        address: product.address,
        isSelfPickup: product.isSelfPickup,
        status: product.status,
        createTime: product.createTime,
        updateTime: product.updateTime,
        isDelete: product.isDelete,
    }
}

// 获取商品分页数据
export function useProductsPage(params: ProductQuery) {
    return useQuery({
        queryKey: ['products', params],
        queryFn: async () => {
            const result = await RfProductController.page(params)
            return {
                ...result,
                records: result.records.map(transformRfProductToProduct),
            }
        },
    })
}

// 获取商品列表
export function useProductsList(params?: Partial<RfProduct>) {
    return useQuery({
        queryKey: ['products', 'list', params],
        queryFn: async () => {
            const products = await RfProductController.list(params)
            return products.map(transformRfProductToProduct)
        },
    })
}

// 获取单个商品
export function useProductById(id: number) {
    return useQuery({
        queryKey: ['product', id],
        queryFn: async () => {
            const product = await RfProductController.getById(id)
            return transformRfProductToProduct(product)
        },
        enabled: !!id,
    })
}

// 添加商品
export const useAddProduct = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (product: Product) => RfProductController.add(transformProductToRfProduct(product)),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [PRODUCTS_QUERY_KEY] })
            toast.success('商品添加成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '添加商品失败')
        },
    })
}

// 更新商品
export const useUpdateProduct = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (product: Product) => RfProductController.update(transformProductToRfProduct(product)),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [PRODUCTS_QUERY_KEY] })
            toast.success('商品更新成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '更新商品失败')
        },
    })
}

// 删除商品
export const useDeleteProduct = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => RfProductController.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [PRODUCTS_QUERY_KEY] })
            toast.success('商品删除成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '删除商品失败')
        },
    })
}

export function useAllProducts() {
    return useQuery({
        queryKey: ['products', 'all'],
        queryFn: async () => {
            const products = await RfProductController.all()
            return products.map(transformRfProductToProduct)
        },
    })
} 