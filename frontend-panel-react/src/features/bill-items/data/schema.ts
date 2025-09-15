import { z } from 'zod'

// 费用类型枚举
const _costTypeSchema = z.union([
    z.literal('SHIPPING'),      // 运费
    z.literal('PLATFORM_FEE'),  // 平台费用
    z.literal('COMMISSION'),    // 佣金
    z.literal('INSURANCE'),     // 保险费
    z.literal('STORAGE'),       // 仓储费
    z.literal('HANDLING'),      // 处理费
    z.literal('TAX'),          // 税费
    z.literal('OTHER'),        // 其他
])
export type CostType = z.infer<typeof _costTypeSchema>

// 账单状态枚举
const _billStatusSchema = z.union([
    z.literal('PENDING'),      // 待支付
    z.literal('PAID'),         // 已支付
    z.literal('CANCELLED'),    // 已取消
    z.literal('REFUNDED'),     // 已退款
    z.literal('FAILED'),       // 支付失败
])
export type BillStatus = z.infer<typeof _billStatusSchema>

// 账单项模式，匹配后端RfBillItem实体
const billItemSchema = z.object({
    id: z.number().optional(),
    productId: z.number().optional(),
    productSellRecordId: z.number().optional(),
    costType: z.string(),
    costDescription: z.string().optional(),
    cost: z.number(),
    paySubject: z.string().optional(),
    isPlatformPay: z.boolean().optional(),
    payUserId: z.number().optional(),
    status: z.string(),
    payTime: z.string().optional(),
    paymentRecordId: z.number().optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
    // 扩展字段用于显示
    productName: z.string().optional(),
    payUserName: z.string().optional(),
})

export type BillItem = z.infer<typeof billItemSchema>

export const billItemListSchema = z.array(billItemSchema)

// 账单项查询参数模式
export const billItemQuerySchema = z.object({
    current: z.number().optional(),
    size: z.number().optional(),
    productId: z.number().optional(),
    productSellRecordId: z.number().optional(),
    costType: z.string().optional(),
    status: z.string().optional(),
    payUserId: z.number().optional(),
    isPlatformPay: z.boolean().optional(),
    startTime: z.string().optional(),
    endTime: z.string().optional(),
    minCost: z.number().optional(),
    maxCost: z.number().optional(),
})

export type BillItemQuery = z.infer<typeof billItemQuerySchema>

// 费用类型选项
export const costTypeOptions = [
    { label: '运费', value: 'SHIPPING' },
    { label: '平台费用', value: 'PLATFORM_FEE' },
    { label: '佣金', value: 'COMMISSION' },
    { label: '保险费', value: 'INSURANCE' },
    { label: '仓储费', value: 'STORAGE' },
    { label: '处理费', value: 'HANDLING' },
    { label: '税费', value: 'TAX' },
    { label: '其他', value: 'OTHER' },
]

// 账单状态选项
export const billStatusOptions = [
    { label: '待支付', value: 'PENDING' },
    { label: '已支付', value: 'PAID' },
    { label: '已取消', value: 'CANCELLED' },
    { label: '已退款', value: 'REFUNDED' },
    { label: '支付失败', value: 'FAILED' },
]

// 支付方式选项
export const paymentOptions = [
    { label: '平台支付', value: true },
    { label: '用户支付', value: false },
]

// 获取费用类型显示名称
export const getCostTypeName = (type: string): string => {
    const option = costTypeOptions.find(opt => opt.value === type)
    return option?.label || type
}

// 获取账单状态显示名称
export const getBillStatusName = (status: string): string => {
    const option = billStatusOptions.find(opt => opt.value === status)
    return option?.label || status
} 