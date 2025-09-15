import { z } from 'zod'

// 任务类型枚举
export const TASK_TYPE_OPTIONS = [
    { value: 'PICKUP_SERVICE', label: '上门取货' },
    { value: 'WAREHOUSE_SHIPMENT', label: '仓库发货' },
    { value: 'PRODUCT_RETURN', label: '商品退货' },
    { value: 'RETURN_TO_SELLER', label: '退给卖家' },
    { value: 'OTHER', label: '其他' },
] as const

// 任务类型映射
export const TASK_TYPE_MAP = {
    PICKUP_SERVICE: '取货服务',
    WAREHOUSE_SHIPMENT: '仓库发货',
    PRODUCT_RETURN: '商品退货',
    RETURN_TO_SELLER: '退给卖家',
    OTHER: '其他',
} as const

// 内部物流任务查询参数schema
export const internalLogisticsTaskQuerySchema = z.object({
    current: z.number().min(1).default(1),
    size: z.number().min(1).max(100).default(10),
    productId: z.number().optional(),
    productSellRecordId: z.number().optional(),
    taskType: z.string().optional(),
    logisticsUserId: z.number().optional(),
    status: z.string().optional(),
})

// 内部物流任务schema，匹配后端RfInternalLogisticsTask实体
const internalLogisticsTaskSchema = z.object({
    id: z.number().optional(),
    productId: z.number().optional(),
    productSellRecordId: z.number().optional(),
    productConsignmentRecordId: z.number().optional(),
    productReturnRecordId: z.number().optional(),
    productReturnToSellerRecordId: z.number().optional(),
    taskType: z.enum(['PICKUP_SERVICE', 'WAREHOUSE_SHIPMENT', 'PRODUCT_RETURN', 'RETURN_TO_SELLER', 'OTHER']).optional(),
    logisticsUserId: z.number().optional(),
    sourceAddress: z.string().optional(),
    sourceAddressImageUrlJson: z.string().optional(),
    targetAddress: z.string().optional(),
    targetAddressImageUrlJson: z.string().optional(),
    logisticsCost: z.number().min(0, '物流费用不能为负数').optional(),
    status: z.string().optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
})

export type InternalLogisticsTask = z.infer<typeof internalLogisticsTaskSchema>
export type InternalLogisticsTaskQuery = z.infer<typeof internalLogisticsTaskQuerySchema>

export { internalLogisticsTaskSchema } 