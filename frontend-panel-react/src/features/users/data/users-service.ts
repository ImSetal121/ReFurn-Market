import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { SysUserController, SysRoleController, type PageResponse } from '@/api'
import type { SysUser, SysRole, UserQuery } from '@/types/system'
import type { User } from './schema'

// 查询键
export const USERS_QUERY_KEY = 'users'
export const ROLES_QUERY_KEY = 'roles'

// 转换后端SysUser到前端User类型
const transformSysUserToUser = (sysUser: SysUser, roles: SysRole[] = []): User => {
    const role = roles.find(r => r.id === sysUser.roleId)
    return {
        id: sysUser.id,
        username: sysUser.username,
        password: sysUser.password,
        roleId: sysUser.roleId,
        wechatOpenId: sysUser.wechatOpenId,
        avatar: sysUser.avatar,
        nickname: sysUser.nickname,
        email: sysUser.email,
        phoneNumber: sysUser.phoneNumber,
        sex: sysUser.sex as 'M' | 'F' | '',
        lastLoginIp: sysUser.lastLoginIp,
        lastLoginDate: sysUser.lastLoginDate,
        createBy: sysUser.createBy,
        createTime: sysUser.createTime,
        updateBy: sysUser.updateBy,
        updateTime: sysUser.updateTime,
        isDelete: sysUser.isDelete,
        roleName: role?.name,
        status: sysUser.isDelete ? 'inactive' : 'active',
    }
}

// 转换前端User到后端SysUser类型
const transformUserToSysUser = (user: User): SysUser => {
    return {
        id: user.id,
        username: user.username,
        password: user.password,
        roleId: user.roleId,
        wechatOpenId: user.wechatOpenId,
        avatar: user.avatar,
        nickname: user.nickname,
        email: user.email,
        phoneNumber: user.phoneNumber,
        sex: user.sex,
        lastLoginIp: user.lastLoginIp,
        lastLoginDate: user.lastLoginDate,
        createBy: user.createBy,
        createTime: user.createTime,
        updateBy: user.updateBy,
        updateTime: user.updateTime,
        isDelete: user.isDelete,
    }
}

// 获取用户分页数据
export const useUsersPage = (params: UserQuery) => {
    return useQuery({
        queryKey: [USERS_QUERY_KEY, 'page', params],
        queryFn: async (): Promise<PageResponse<User> & { roles: SysRole[] }> => {
            const [pageResult, roles] = await Promise.all([
                SysUserController.page(params),
                SysRoleController.list()
            ])

            return {
                ...pageResult,
                records: pageResult.records.map(user => transformSysUserToUser(user, roles)),
                roles
            }
        },
    })
}

// 获取角色列表
export const useRoles = () => {
    return useQuery({
        queryKey: [ROLES_QUERY_KEY],
        queryFn: () => SysRoleController.list(),
    })
}

// 添加用户
export const useAddUser = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (user: User) => SysUserController.add(transformUserToSysUser(user)),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [USERS_QUERY_KEY] })
            toast.success('用户添加成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '添加用户失败')
        },
    })
}

// 更新用户
export const useUpdateUser = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (user: User) => SysUserController.update(transformUserToSysUser(user)),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [USERS_QUERY_KEY] })
            toast.success('用户更新成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '更新用户失败')
        },
    })
}

// 删除用户
export const useDeleteUser = () => {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => SysUserController.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [USERS_QUERY_KEY] })
            toast.success('用户删除成功')
        },
        onError: (error: Error) => {
            toast.error(error.message || '删除用户失败')
        },
    })
}

// 获取单个用户
export const useUser = (id: number) => {
    return useQuery({
        queryKey: [USERS_QUERY_KEY, id],
        queryFn: async (): Promise<User> => {
            const [user, roles] = await Promise.all([
                SysUserController.getById(id),
                SysRoleController.list()
            ])
            return transformSysUserToUser(user, roles)
        },
        enabled: !!id,
    })
} 