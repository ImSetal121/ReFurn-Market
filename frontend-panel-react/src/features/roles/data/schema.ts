import { z } from 'zod'

// 角色查询参数schema
export const roleQuerySchema = z.object({
    current: z.number().min(1).default(1),
    size: z.number().min(1).max(100).default(10),
    key: z.string().optional(),
    name: z.string().optional(),
})

// 角色schema，匹配后端SysRole实体
const roleSchema = z.object({
    id: z.number().optional(),
    key: z.string().min(1, '角色标识不能为空'),
    name: z.string().min(1, '角色名称不能为空'),
    description: z.string().optional(),
    order: z.number().optional(),
    status: z.string().optional(),
    createBy: z.string().optional(),
    createTime: z.string().optional(),
    updateBy: z.string().optional(),
    updateTime: z.string().optional(),
})

export type Role = z.infer<typeof roleSchema>
export type RoleQuery = z.infer<typeof roleQuerySchema>

export { roleSchema } 