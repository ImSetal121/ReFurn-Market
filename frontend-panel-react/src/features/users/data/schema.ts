import { z } from 'zod'

// 用户状态枚举
const userStatusSchema = z.union([
  z.literal('active'),
  z.literal('inactive'),
  z.literal('suspended'),
])
export type UserStatus = z.infer<typeof userStatusSchema>

// 性别枚举
const userSexSchema = z.union([
  z.literal('M'),
  z.literal('F'),
  z.literal(''),
  z.literal('unset'),
])
export type UserSex = z.infer<typeof userSexSchema>

// 用户模式，匹配后端SysUser实体
const userSchema = z.object({
  id: z.number().optional(),
  username: z.string(),
  password: z.string().optional(),
  roleId: z.number().optional(),
  clientRole: z.string().optional(),
  wechatOpenId: z.string().optional(),
  avatar: z.string().optional(),
  nickname: z.string().optional(),
  email: z.string().optional(),
  phoneNumber: z.string().optional(),
  sex: userSexSchema.optional(),
  lastLoginIp: z.string().optional(),
  lastLoginDate: z.string().optional(),
  createBy: z.string().optional(),
  createTime: z.string().optional(),
  updateBy: z.string().optional(),
  updateTime: z.string().optional(),
  isDelete: z.boolean().optional(),
  // Google 登录相关字段
  googleSub: z.string().optional(),
  googleLinkedTime: z.string().optional(),
  // Apple 登录相关字段
  appleSub: z.string().optional(),
  appleLinkedTime: z.string().optional(),
  // 扩展字段用于显示
  roleName: z.string().optional(),
  status: userStatusSchema.optional(),
})

export type User = z.infer<typeof userSchema>

export const userListSchema = z.array(userSchema)

// 用户查询参数模式
export const userQuerySchema = z.object({
  current: z.number().optional(),
  size: z.number().optional(),
  username: z.string().optional(),
  nickname: z.string().optional(),
  email: z.string().optional(),
  phoneNumber: z.string().optional(),
})

export type UserQuery = z.infer<typeof userQuerySchema>
