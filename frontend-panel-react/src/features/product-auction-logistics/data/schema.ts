import { z } from 'zod'

// 商品寄卖物流记录查询参数schema
export const productAuctionLogisticsQuerySchema = z.object({
    current: z.number().min(1).default(1),
    size: z.number().min(1).max(100).default(10),
    productId: z.number().optional(),
    productSellRecordId: z.number().optional(),
    warehouseId: z.number().optional(),
    isUseLogisticsService: z.boolean().optional(),
    status: z.enum(['PENDING_PICKUP', 'PENDING_WAREHOUSING', 'WAREHOUSED']).optional(),
})

// 商品寄卖物流记录schema，匹配后端RfProductAuctionLogistics实体
const productAuctionLogisticsSchema = z.object({
    id: z.number().optional(),
    productId: z.number().optional(),
    productSellRecordId: z.number().optional(),
    pickupAddress: z.string().optional(),
    warehouseId: z.number().optional(),
    warehouseAddress: z.string().optional(),
    isUseLogisticsService: z.boolean().optional(),
    appointmentPickupDate: z.string().optional(),
    appointmentPickupTimePeriod: z.enum(['MORNING', 'AFTERNOON']).optional(),
    internalLogisticsTaskId: z.number().optional(),
    externalLogisticsServiceName: z.string().optional(),
    externalLogisticsOrderNumber: z.string().optional(),
    status: z.enum(['PENDING_PICKUP', 'PENDING_WAREHOUSING', 'WAREHOUSED']).optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
})

export type ProductAuctionLogistics = z.infer<typeof productAuctionLogisticsSchema>
export type ProductAuctionLogisticsQuery = z.infer<typeof productAuctionLogisticsQuerySchema>

export { productAuctionLogisticsSchema } 