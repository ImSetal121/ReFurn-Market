import { z } from 'zod';

// 审核结果枚举
export const auditResults = [
    { label: '拒绝', value: 'REJECTED' },
    { label: '同意', value: 'APPROVED' },
] as const;

// 运费承担方枚举
export const freightBearers = [
    { label: '卖方', value: 'SELLER' },
    { label: '买方', value: 'BUYER' },
    { label: '平台', value: 'PLATFORM' },
] as const;

// 赔偿承担方枚举
export const compensationBearers = [
    { label: '卖方', value: 'SELLER' },
    { label: '买方', value: 'BUYER' },
    { label: '平台', value: 'PLATFORM' },
] as const;

// 状态枚举
export const statuses = [
    { label: '发起退货', value: 'RETURN_INITIATED' },
    { label: '退货协商不一致', value: 'RETURN_NEGOTIATION_FAILED' },
    { label: '退回仓库', value: 'RETURNED_TO_WAREHOUSE' },
    { label: '退回卖家', value: 'RETURNED_TO_SELLER' },
    { label: '已退回', value: 'RETURN_COMPLETED' },
] as const;

// 是否删除选项
export const deleteStatuses = [
    { label: '未删除', value: false },
    { label: '已删除', value: true },
] as const;

// 布尔选项
export const booleanOptions = [
    { label: '是', value: true },
    { label: '否', value: false },
] as const;

// 商品退货记录模式
export const productReturnRecordSchema = z.object({
    id: z.number().optional(),
    productId: z.number().min(1, '商品ID必填').optional(),
    productSellRecordId: z.number().min(1, '商品出售记录ID必填').optional(),
    returnReasonType: z.string().min(1, '退货原因类型必填').optional(),
    returnReasonDetail: z.string().optional(),
    pickupAddress: z.string().optional(),
    sellerAcceptReturn: z.boolean().optional(),
    sellerOpinionDetail: z.string().optional(),
    auditResult: z.enum(['REJECTED', 'APPROVED']).optional(),
    auditDetail: z.string().optional(),
    freightBearer: z.enum(['SELLER', 'BUYER', 'PLATFORM']).optional(),
    freightBearerUserId: z.number().optional(),
    needCompensateProduct: z.boolean().optional(),
    compensationBearer: z.enum(['SELLER', 'BUYER', 'PLATFORM']).optional(),
    compensationBearerUserId: z.number().optional(),
    isAuction: z.boolean().optional(),
    isUseLogisticsService: z.boolean().optional(),
    appointmentPickupTime: z.string().optional(),
    internalLogisticsTaskId: z.number().optional().nullable(),
    externalLogisticsServiceName: z.string().optional().nullable(),
    externalLogisticsOrderNumber: z.string().optional().nullable(),
    status: z.enum(['RETURN_INITIATED', 'RETURN_NEGOTIATION_FAILED', 'RETURNED_TO_WAREHOUSE', 'RETURNED_TO_SELLER', 'RETURN_COMPLETED']).optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
});

export type ProductReturnRecord = z.infer<typeof productReturnRecordSchema>; 