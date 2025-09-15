import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { SysMenuController } from '@/api/SysMenuController'
import type { SysMenu, MenuQuery } from '@/types/system'

// 查询键
export const menuKeys = {
    all: ['menus'] as const,
    lists: () => [...menuKeys.all, 'list'] as const,
    list: (filters: string) => [...menuKeys.lists(), { filters }] as const,
    details: () => [...menuKeys.all, 'detail'] as const,
    detail: (id: number) => [...menuKeys.details(), id] as const,
    page: (params: MenuQuery) => [...menuKeys.all, 'page', params] as const,
}

// 获取菜单分页数据
export function useMenusPage(params: MenuQuery) {
    return useQuery({
        queryKey: menuKeys.page(params),
        queryFn: () => SysMenuController.page(params),
    })
}

// 获取菜单列表
export function useMenusList(params?: { menuName?: string; status?: string }) {
    return useQuery({
        queryKey: menuKeys.list(JSON.stringify(params || {})),
        queryFn: () => SysMenuController.list(params),
    })
}

// 获取单个菜单
export function useMenu(id: number) {
    return useQuery({
        queryKey: menuKeys.detail(id),
        queryFn: () => SysMenuController.getById(id),
        enabled: !!id,
    })
}

// 创建菜单
export function useCreateMenu() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (menu: SysMenu) => SysMenuController.add(menu),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: menuKeys.all })
        },
    })
}

// 更新菜单
export function useUpdateMenu() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (menu: SysMenu) => SysMenuController.update(menu),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: menuKeys.all })
        },
    })
}

// 删除菜单
export function useDeleteMenu() {
    const queryClient = useQueryClient()

    return useMutation({
        mutationFn: (id: number) => SysMenuController.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: menuKeys.all })
        },
    })
} 