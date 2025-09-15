import { z } from 'zod'

// 仓库查询参数schema
export const warehouseQuerySchema = z.object({
    current: z.number().min(1).default(1),
    size: z.number().min(1).max(100).default(10),
    name: z.string().optional(),
    status: z.string().optional(),
    address: z.string().optional(),
})

// 仓库schema，匹配后端RfWarehouse实体
const warehouseSchema = z.object({
    id: z.number().optional(),
    name: z.string().min(1, '仓库名称不能为空'),
    address: z.string().min(1, '仓库地址不能为空'),
    monthlyWarehouseCost: z.number().min(0, '月仓储费用不能为负数'),
    status: z.string().default('ENABLED'),
    createTime: z.string().optional(),
    updateTime: z.string().optional(),
    isDelete: z.boolean().optional(),
})

export type Warehouse = z.infer<typeof warehouseSchema>
export type WarehouseQuery = z.infer<typeof warehouseQuerySchema>

export { warehouseSchema }

// 仓库状态选项
export const warehouseStatusOptions = [
    { label: '启用', value: 'ENABLED' },
    { label: '停用', value: 'DISABLED' },
] 