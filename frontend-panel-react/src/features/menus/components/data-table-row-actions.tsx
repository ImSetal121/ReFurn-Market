import { Row } from '@tanstack/react-table'
import { MoreHorizontal } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { useMenusContext } from '../context/menus-context'
import type { SysMenu } from '@/types/system'

interface DataTableRowActionsProps<TData> {
    row: Row<TData>
}

export function DataTableRowActions<TData>({
    row,
}: DataTableRowActionsProps<TData>) {
    const menu = row.original as SysMenu
    const { setEditingMenu, setIsEditDialogOpen, setIsDeleteDialogOpen } = useMenusContext()

    const handleEdit = () => {
        setEditingMenu(menu)
        setIsEditDialogOpen(true)
    }

    const handleDelete = () => {
        setEditingMenu(menu)
        setIsDeleteDialogOpen(true)
    }

    return (
        <DropdownMenu>
            <DropdownMenuTrigger asChild>
                <Button
                    variant='ghost'
                    className='flex h-8 w-8 p-0 data-[state=open]:bg-muted'
                >
                    <MoreHorizontal className='h-4 w-4' />
                    <span className='sr-only'>打开菜单</span>
                </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align='end' className='w-[160px]'>
                <DropdownMenuItem onClick={handleEdit}>
                    编辑菜单
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => navigator.clipboard.writeText(menu.menuName || '')}>
                    复制菜单名称
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => navigator.clipboard.writeText(menu.perms || '')}>
                    复制权限标识
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleDelete} className='text-red-600'>
                    删除菜单
                </DropdownMenuItem>
            </DropdownMenuContent>
        </DropdownMenu>
    )
} 