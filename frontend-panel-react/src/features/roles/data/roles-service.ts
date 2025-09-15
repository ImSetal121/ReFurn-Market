import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { SysRoleController } from '@/api/SysRoleController'
import { SysMenuController } from '@/api/SysMenuController'
import { toast } from 'sonner'
import type { Role, RoleQuery } from './schema'

// 查询键
const ROLES_QUERY_KEY = 'roles'

/**
 * 获取角色分页数据
 */
export function useRolesPage(params: RoleQuery) {
    return useQuery({
        queryKey: [ROLES_QUERY_KEY, 'page', params],
        queryFn: () => SysRoleController.page(params),
    })
}

/**
 * 获取角色列表（不分页）
 */
export function useRolesList(params?: { key?: string; name?: string }) {
    return useQuery({
        queryKey: [ROLES_QUERY_KEY, 'list', params],
        queryFn: () => SysRoleController.list(params),
    })
}

/**
 * 根据ID获取角色
 */
export function useRole(id: number) {
    return useQuery({
        queryKey: [ROLES_QUERY_KEY, id],
        queryFn: () => SysRoleController.getById(id),
        enabled: !!id,
    })
}

/**
 * 获取角色拥有的菜单列表
 */
export function useRoleMenus(roleId: number) {
    return useQuery({
        queryKey: [ROLES_QUERY_KEY, roleId, 'menus'],
        queryFn: () => SysRoleController.getRoleMenus(roleId),
        enabled: !!roleId,
    })
}

/**
 * 获取所有菜单列表
 */
export function useAllMenus() {
    return useQuery({
        queryKey: ['menus', 'all'],
        queryFn: () => SysMenuController.list(),
    })
}

/**
 * 创建角色
 */
export function useCreateRole() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (role: Role) => SysRoleController.add(role),
        onSuccess: () => {
            // 使所有角色相关查询失效
            queryClient.invalidateQueries({ queryKey: [ROLES_QUERY_KEY] })
            toast.success('角色创建成功')
        },
        onError: (error) => {
            const message = error instanceof Error ? error.message : '创建角色失败'
            toast.error(message)
        },
    })
}

/**
 * 更新角色
 */
export function useUpdateRole() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (role: Role) => SysRoleController.update(role),
        onSuccess: () => {
            // 使所有角色相关查询失效
            queryClient.invalidateQueries({ queryKey: [ROLES_QUERY_KEY] })
            toast.success('角色更新成功')
        },
        onError: (error) => {
            const message = error instanceof Error ? error.message : '更新角色失败'
            toast.error(message)
        },
    })
}

/**
 * 设置角色菜单权限
 */
export function useSetRoleMenus() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: ({ roleId, menuIds }: { roleId: number; menuIds: number[] }) =>
            SysRoleController.setRoleMenus(roleId, menuIds),
        onSuccess: (_, { roleId }) => {
            // 使角色菜单查询失效
            queryClient.invalidateQueries({ queryKey: [ROLES_QUERY_KEY, roleId, 'menus'] })
            toast.success('角色菜单权限设置成功')
        },
        onError: (error) => {
            const message = error instanceof Error ? error.message : '设置角色菜单权限失败'
            toast.error(message)
        },
    })
}

/**
 * 删除角色
 */
export function useDeleteRole() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => SysRoleController.delete(id),
        onSuccess: () => {
            // 使所有角色相关查询失效
            queryClient.invalidateQueries({ queryKey: [ROLES_QUERY_KEY] })
            toast.success('角色删除成功')
        },
        onError: (error) => {
            const message = error instanceof Error ? error.message : '删除角色失败'
            toast.error(message)
        },
    })
}

/**
 * 批量删除角色
 */
export function useBatchDeleteRoles() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: async (ids: number[]) => {
            await Promise.all(ids.map(id => SysRoleController.delete(id)))
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: [ROLES_QUERY_KEY] })
            toast.success('批量删除成功')
        },
        onError: (error) => {
            const message = error instanceof Error ? error.message : '批量删除失败'
            toast.error(message)
        },
    })
} 