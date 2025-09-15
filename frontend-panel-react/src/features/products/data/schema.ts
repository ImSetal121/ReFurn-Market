import { z } from 'zod'

// 商品查询参数schema
export const productQuerySchema = z.object({
    current: z.number().min(1).default(1),
    size: z.number().min(1).max(100).default(10),
    name: z.string().optional(),
    categoryId: z.number().optional(),
    type: z.string().optional(),
    isAuction: z.boolean().optional(),
    isSelfPickup: z.boolean().optional(),
    status: z.enum(['LISTED', 'UNLISTED', 'SOLD']).optional(),
})

// 商品schema，匹配后端RfProduct实体
const productSchema = z.object({
    id: z.number().optional(),
    userId: z.number().optional(),
    name: z.string().min(1, '商品名称不能为空'),
    categoryId: z.number().optional(),
    type: z.string().optional(),
    category: z.string().optional(),
    price: z.number().min(0, '价格不能为负数').optional(),
    stock: z.number().min(0, '库存不能为负数').optional(),
    description: z.string().optional(),
    imageUrlJson: z.string().optional(),
    isAuction: z.boolean().optional(),
    address: z.string().optional(),
    isSelfPickup: z.boolean().optional(),
    status: z.enum(['LISTED', 'UNLISTED', 'SOLD']).optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
})

export type Product = z.infer<typeof productSchema>
export type ProductQuery = z.infer<typeof productQuerySchema>

export { productSchema } 