import { z } from 'zod';

// 状态枚举
export const statuses = [
    { label: '待发货', value: 'PENDING_SHIPMENT' },
    { label: '已发货', value: 'SHIPPED' },
    { label: '已签收', value: 'RECEIVED' },
] as const;

// 是否删除选项
export const deleteStatuses = [
    { label: '未删除', value: false },
    { label: '已删除', value: true },
] as const;

// 商品退回卖家记录模式
export const productReturnToSellerSchema = z.object({
    id: z.number().optional(),
    productId: z.number().min(1, '商品ID必填').optional(),
    productSellRecordId: z.number().min(1, '商品出售记录ID必填').optional(),
    warehouseId: z.number().min(1, '仓库ID必填').optional(),
    warehouseAddress: z.string().min(1, '仓库地址必填').optional(),
    sellerReceiptAddress: z.string().min(1, '卖家收货地址必填').optional(),
    internalLogisticsTaskId: z.number().optional(),
    shipmentTime: z.string().optional(),
    shipmentImageUrlJson: z.string().optional(),
    status: z.enum(['PENDING_SHIPMENT', 'SHIPPED', 'RECEIVED']).optional(),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
});

export type ProductReturnToSeller = z.infer<typeof productReturnToSellerSchema>; 