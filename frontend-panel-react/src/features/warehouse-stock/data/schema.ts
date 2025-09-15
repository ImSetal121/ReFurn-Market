import { z } from 'zod'

// 仓库库存查询参数schema
export const warehouseStockQuerySchema = z.object({
    current: z.number().min(1).default(1),
    size: z.number().min(1).max(100).default(10),
    warehouseId: z.number().optional(),
    productId: z.number().optional(),
    warehouseInApplyId: z.number().optional(),
    warehouseInId: z.number().optional(),
    warehouseOutId: z.number().optional(),
    status: z.enum(['IN_STOCK', 'OUT_OF_STOCK']).optional(),
})

// 仓库库存schema，匹配后端RfWarehouseStock实体
const warehouseStockSchema = z.object({
    id: z.number().optional(),
    warehouseId: z.number().optional(),
    productId: z.number().optional(),
    stockQuantity: z.number().min(0, '库存数量不能为负数').optional(),
    stockPosition: z.string().optional(),
    warehouseInApplyId: z.number().optional(),
    warehouseInId: z.number().optional(),
    inTime: z.string().optional(),
    warehouseOutId: z.number().optional(),
    outTime: z.string().optional(),
    status: z.enum(['IN_STOCK', 'OUT_OF_STOCK']).optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
})

export type WarehouseStock = z.infer<typeof warehouseStockSchema>
export type WarehouseStockQuery = z.infer<typeof warehouseStockQuerySchema>

export { warehouseStockSchema } 