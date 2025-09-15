import { z } from 'zod'

// 菜单查询参数schema
export const menuQuerySchema = z.object({
    current: z.number().min(1).default(1),
    size: z.number().min(1).max(100).default(10),
    menuName: z.string().optional(),
    status: z.string().optional(),
})

// 菜单schema，匹配后端SysMenu实体
const menuSchema = z.object({
    id: z.number().optional(),
    menuName: z.string().min(1, '菜单名称不能为空'),
    parentId: z.number().optional(),
    orderNum: z.number().optional(),
    path: z.string().optional(),
    component: z.string().optional(),
    query: z.string().optional(),
    routeName: z.string().optional(),
    isFrame: z.number().optional(),
    isCache: z.number().optional(),
    menuType: z.string().optional(),
    visible: z.string().optional(),
    status: z.string().optional(),
    perms: z.string().optional(),
    icon: z.string().optional(),
    createBy: z.string().optional(),
    createTime: z.string().optional(),
    updateBy: z.string().optional(),
    updateTime: z.string().optional(),
    remark: z.string().optional(),
})

export type Menu = z.infer<typeof menuSchema>
export type MenuQuery = z.infer<typeof menuQuerySchema>

export { menuSchema } 