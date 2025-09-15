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
import { useRolesContext } from '../context/roles-context'
import type { Role } from '../data/schema'

interface DataTableRowActionsProps<TData> {
  row: Row<TData>
}

export function DataTableRowActions<TData>({
  row,
}: DataTableRowActionsProps<TData>) {
  const role = row.original as Role
  const {
    setCurrentRole,
    setActionDialogOpen,
    setDeleteDialogOpen,
    setMenuDialogOpen
  } = useRolesContext()

  // 检查是否为超级管理员
  const isSuperAdmin = role.id === 1

  const handleEdit = () => {
    setCurrentRole(role)
    setActionDialogOpen(true)
  }

  const handleEditMenus = () => {
    setCurrentRole(role)
    setMenuDialogOpen(true)
  }

  const handleDelete = () => {
    setCurrentRole(role)
    setDeleteDialogOpen(true)
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
        <DropdownMenuItem
          onClick={handleEdit}
          disabled={isSuperAdmin}
          className={isSuperAdmin ? 'text-muted-foreground' : ''}
        >
          编辑角色
          {isSuperAdmin && <span className='text-xs ml-auto'>禁用</span>}
        </DropdownMenuItem>
        <DropdownMenuItem
          onClick={handleEditMenus}
          disabled={isSuperAdmin}
          className={isSuperAdmin ? 'text-muted-foreground' : ''}
        >
          编辑菜单
          {isSuperAdmin && <span className='text-xs ml-auto'>禁用</span>}
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => navigator.clipboard.writeText(role.key || '')}>
          复制角色标识
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          onClick={handleDelete}
          disabled={isSuperAdmin}
          className={isSuperAdmin ? 'text-muted-foreground' : 'text-red-600'}
        >
          删除角色
          {isSuperAdmin && <span className='text-xs ml-auto'>禁用</span>}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
