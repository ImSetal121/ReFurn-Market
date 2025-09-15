import { useEffect, useState } from 'react'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import { Badge } from '@/components/ui/badge'
import { X, Loader2 } from 'lucide-react'
import { ScrollArea } from '@/components/ui/scroll-area'
import { useRolesContext } from '../context/roles-context'
import { useRoleMenus, useAllMenus, useSetRoleMenus } from '../data/roles-service'
import type { SysMenu } from '@/types/system'

interface RoleMenuDialogProps {
    open: boolean
    onOpenChange: (open: boolean) => void
}

export function RoleMenuDialog({ open, onOpenChange }: RoleMenuDialogProps) {
    const { currentRole } = useRolesContext()
    const [selectedMenuIds, setSelectedMenuIds] = useState<number[]>([])

    // 获取角色的菜单和所有菜单
    const { data: roleMenus, isLoading: roleMenusLoading } = useRoleMenus(currentRole?.id || 0)
    const { data: allMenus, isLoading: allMenusLoading } = useAllMenus()
    const setRoleMenus = useSetRoleMenus()

    // 当对话框打开或角色菜单数据加载时，更新选中的菜单ID
    useEffect(() => {
        if (open && roleMenus) {
            setSelectedMenuIds(roleMenus.map(menu => menu.id!))
        }
    }, [open, roleMenus])

    const handleMenuToggle = (menuId: number, checked: boolean) => {
        if (checked) {
            setSelectedMenuIds(prev => [...prev, menuId])
        } else {
            setSelectedMenuIds(prev => prev.filter(id => id !== menuId))
        }
    }

    const handleMenuRemove = (menuId: number) => {
        setSelectedMenuIds(prev => prev.filter(id => id !== menuId))
    }

    const handleSave = async () => {
        if (!currentRole?.id) return

        try {
            await setRoleMenus.mutateAsync({
                roleId: currentRole.id,
                menuIds: selectedMenuIds
            })
            onOpenChange(false)
        } catch (_error) {
            // 错误已在mutation中处理
        }
    }

    const isLoading = roleMenusLoading || allMenusLoading
    const isPending = setRoleMenus.isPending

    // 获取已选中的菜单用于显示标签
    const selectedMenus = allMenus?.filter(menu => selectedMenuIds.includes(menu.id!)) || []

    // 按菜单类型分组显示
    const groupedMenus = allMenus?.reduce((groups, menu) => {
        const type = menu.menuType || 'C'
        if (!groups[type]) {
            groups[type] = []
        }
        groups[type].push(menu)
        return groups
    }, {} as Record<string, SysMenu[]>) || {}

    const menuTypeLabels = {
        'M': '目录',
        'C': '菜单',
        'F': '按钮'
    }

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className='max-w-4xl max-h-[80vh] overflow-hidden flex flex-col'>
                <DialogHeader>
                    <DialogTitle>编辑角色菜单权限</DialogTitle>
                    <DialogDescription>
                        为角色 "{currentRole?.name}" 配置菜单访问权限
                    </DialogDescription>
                </DialogHeader>

                {isLoading ? (
                    <div className='flex items-center justify-center h-64'>
                        <Loader2 className='h-8 w-8 animate-spin' />
                        <span className='ml-2'>加载中...</span>
                    </div>
                ) : (
                    <div className='flex-1 grid grid-cols-1 lg:grid-cols-2 gap-6 overflow-hidden'>
                        {/* 左侧：菜单选择区域 */}
                        <div className='space-y-4'>
                            <h3 className='font-medium text-sm text-muted-foreground'>选择菜单</h3>
                            <ScrollArea className='h-[400px] pr-4'>
                                <div className='space-y-4'>
                                    {Object.entries(groupedMenus).map(([type, menus]) => (
                                        <div key={type} className='space-y-2'>
                                            <h4 className='font-medium text-sm flex items-center gap-2'>
                                                <Badge variant='outline'>{menuTypeLabels[type as keyof typeof menuTypeLabels]}</Badge>
                                                <span className='text-muted-foreground'>({menus.length})</span>
                                            </h4>
                                            <div className='grid gap-2 pl-4'>
                                                {menus.map((menu) => (
                                                    <div key={menu.id} className='flex items-center space-x-2'>
                                                        <Checkbox
                                                            id={`menu-${menu.id}`}
                                                            checked={selectedMenuIds.includes(menu.id!)}
                                                            onCheckedChange={(checked) =>
                                                                handleMenuToggle(menu.id!, checked as boolean)
                                                            }
                                                        />
                                                        <label
                                                            htmlFor={`menu-${menu.id}`}
                                                            className='text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer flex items-center gap-2 flex-1'
                                                        >
                                                            {menu.icon && <span>{menu.icon}</span>}
                                                            <span>{menu.menuName}</span>
                                                            {menu.perms && (
                                                                <Badge variant='secondary' className='text-xs'>{menu.perms}</Badge>
                                                            )}
                                                        </label>
                                                    </div>
                                                ))}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </ScrollArea>
                        </div>

                        {/* 右侧：已选菜单显示区域 */}
                        <div className='space-y-4'>
                            <div className='flex items-center justify-between'>
                                <h3 className='font-medium text-sm text-muted-foreground'>已选菜单</h3>
                                <Badge variant='secondary'>{selectedMenus.length} 项</Badge>
                            </div>
                            <ScrollArea className='h-[400px] pr-4'>
                                <div className='flex flex-wrap gap-2'>
                                    {selectedMenus.length === 0 ? (
                                        <div className='w-full text-center text-muted-foreground py-8'>
                                            暂无选中的菜单
                                        </div>
                                    ) : (
                                        selectedMenus.map((menu) => (
                                            <div
                                                key={menu.id}
                                                className='inline-flex items-center gap-1 px-2 py-1 border rounded-lg bg-muted/50 text-sm'
                                            >
                                                <div className='flex items-center gap-1'>
                                                    {menu.icon && <span className='text-xs'>{menu.icon}</span>}
                                                    <span className='font-medium truncate max-w-20'>{menu.menuName}</span>
                                                    <Badge
                                                        variant='outline'
                                                        className='text-xs h-4 px-1'
                                                    >
                                                        {menuTypeLabels[menu.menuType as keyof typeof menuTypeLabels]}
                                                    </Badge>
                                                </div>
                                                <Button
                                                    variant='ghost'
                                                    size='sm'
                                                    onClick={() => handleMenuRemove(menu.id!)}
                                                    className='h-4 w-4 p-0 hover:bg-destructive hover:text-destructive-foreground ml-1'
                                                >
                                                    <X className='h-2.5 w-2.5' />
                                                </Button>
                                            </div>
                                        ))
                                    )}
                                </div>
                            </ScrollArea>
                        </div>
                    </div>
                )}

                <DialogFooter>
                    <Button
                        variant='outline'
                        onClick={() => onOpenChange(false)}
                        disabled={isPending}
                    >
                        取消
                    </Button>
                    <Button
                        onClick={handleSave}
                        disabled={isPending || isLoading}
                    >
                        {isPending ? (
                            <>
                                <Loader2 className='w-4 h-4 mr-2 animate-spin' />
                                保存中...
                            </>
                        ) : (
                            '保存'
                        )}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
} 