import { z } from 'zod'

// 交易类型枚举
const transactionTypeSchema = z.union([
    z.literal('DEPOSIT'),      // 充值
    z.literal('WITHDRAW'),     // 提现
    z.literal('PURCHASE'),     // 购买
    z.literal('REFUND'),       // 退款
    z.literal('COMMISSION'),   // 佣金
    z.literal('TRANSFER_IN'),  // 转入
    z.literal('TRANSFER_OUT'), // 转出
    z.literal('ADJUSTMENT'),   // 调整
])
export type TransactionType = z.infer<typeof transactionTypeSchema>

// 余额明细模式，匹配后端RfBalanceDetail实体
const balanceDetailSchema = z.object({
    id: z.number().optional(),
    userId: z.number(),
    prevDetailId: z.number().optional(),
    nextDetailId: z.number().optional(),
    transactionType: z.string(),
    amount: z.number(),
    balanceBefore: z.number(),
    balanceAfter: z.number(),
    description: z.string().optional(),
    transactionTime: z.string().optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
    // 扩展字段用于显示
    username: z.string().optional(),
    nickname: z.string().optional(),
})

export type BalanceDetail = z.infer<typeof balanceDetailSchema>

export const balanceDetailListSchema = z.array(balanceDetailSchema)

// 余额明细查询参数模式
export const balanceDetailQuerySchema = z.object({
    current: z.number().optional(),
    size: z.number().optional(),
    userId: z.number().optional(),
    transactionType: z.string().optional(),
    startTime: z.string().optional(),
    endTime: z.string().optional(),
    minAmount: z.number().optional(),
    maxAmount: z.number().optional(),
})

export type BalanceDetailQuery = z.infer<typeof balanceDetailQuerySchema>

// 交易类型选项
export const transactionTypeOptions = [
    { label: '充值', value: 'DEPOSIT' },
    { label: '提现', value: 'WITHDRAW' },
    { label: '购买', value: 'PURCHASE' },
    { label: '退款', value: 'REFUND' },
    { label: '佣金', value: 'COMMISSION' },
    { label: '转入', value: 'TRANSFER_IN' },
    { label: '转出', value: 'TRANSFER_OUT' },
    { label: '调整', value: 'ADJUSTMENT' },
]

// 获取交易类型显示名称
export const getTransactionTypeName = (type: string): string => {
    const option = transactionTypeOptions.find(opt => opt.value === type)
    return option?.label || type
} 