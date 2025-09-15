import { z } from 'zod'

// 商品销售记录状态枚举
const sellRecordStatusSchema = z.union([
    z.literal('PENDING_SHIPMENT'),
    z.literal('PENDING_RECEIPT'),
    z.literal('DELIVERED'),
    z.literal('CONFIRMED'),
    z.literal('RETURN_INITIATED'),
    z.literal('RETURNED_TO_WAREHOUSE'),
    z.literal('RETURNED_TO_SELLER'),
    z.literal('RETURN_COMPLETED'),
])
export type SellRecordStatus = z.infer<typeof sellRecordStatusSchema>

// 商品销售记录模式
const productSellRecordSchema = z.object({
    id: z.number().optional(),
    productId: z.number().optional(),
    product: z.object({
        id: z.number(),
        name: z.string(),
        price: z.number(),
    }).optional(),
    sellerUserId: z.number().optional(),
    buyerUserId: z.number().optional(),
    finalProductPrice: z.number().optional(),
    isAuction: z.boolean().optional(),
    productWarehouseShipmentId: z.number().optional(),
    internalLogisticsTaskId: z.number().optional(),
    isSelfPickup: z.boolean().optional(),
    productSelfPickupLogisticsId: z.number().optional(),
    buyerReceiptImageUrlJson: z.string().optional(),
    sellerReturnImageUrlJson: z.string().optional(),
    status: sellRecordStatusSchema.optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
})

export type ProductSellRecord = z.infer<typeof productSellRecordSchema>

// 导出schema用于表单验证
export { productSellRecordSchema }

export const productSellRecordListSchema = z.array(productSellRecordSchema)

// 商品销售记录查询参数模式
export const productSellRecordQuerySchema = z.object({
    current: z.number().optional(),
    size: z.number().optional(),
    productId: z.number().optional(),
    sellerUserId: z.number().optional(),
    buyerUserId: z.number().optional(),
    status: sellRecordStatusSchema.optional(),
    isAuction: z.boolean().optional(),
    isSelfPickup: z.boolean().optional(),
})

export type ProductSellRecordQuery = z.infer<typeof productSellRecordQuerySchema>

// 状态选项配置
export const statusOptions = [
    { label: '待发货', value: 'PENDING_SHIPMENT' },
    { label: '待收货', value: 'PENDING_RECEIPT' },
    { label: '已送达', value: 'DELIVERED' },
    { label: '确认收货', value: 'CONFIRMED' },
    { label: '发起退货', value: 'RETURN_INITIATED' },
    { label: '退回仓库', value: 'RETURNED_TO_WAREHOUSE' },
    { label: '退回卖家', value: 'RETURNED_TO_SELLER' },
    { label: '已退回', value: 'RETURN_COMPLETED' },
]

// 状态映射
export const statusLabels: Record<SellRecordStatus, string> = {
    'PENDING_SHIPMENT': '待发货',
    'PENDING_RECEIPT': '待收货',
    'DELIVERED': '已送达',
    'CONFIRMED': '确认收货',
    'RETURN_INITIATED': '发起退货',
    'RETURNED_TO_WAREHOUSE': '退回仓库',
    'RETURNED_TO_SELLER': '退回卖家',
    'RETURN_COMPLETED': '已退回',
}

// 状态颜色映射
export const statusColors: Record<SellRecordStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
    'PENDING_SHIPMENT': 'outline',
    'PENDING_RECEIPT': 'secondary',
    'DELIVERED': 'default',
    'CONFIRMED': 'default',
    'RETURN_INITIATED': 'destructive',
    'RETURNED_TO_WAREHOUSE': 'destructive',
    'RETURNED_TO_SELLER': 'destructive',
    'RETURN_COMPLETED': 'destructive',
}

// 删除状态选项
export const deleteStatusOptions = [
    { label: '正常', value: 'false' },
    { label: '已删除', value: 'true' },
]

// 交易类型选项
export const auctionTypeOptions = [
    { label: '拍卖', value: 'true' },
    { label: '直购', value: 'false' },
]

// 配送方式选项
export const pickupTypeOptions = [
    { label: '自提', value: 'true' },
    { label: '快递', value: 'false' },
] 