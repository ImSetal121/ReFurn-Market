import { ColumnDef } from '@tanstack/react-table'
import { Checkbox } from '@/components/ui/checkbox'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import { DataTableColumnHeader } from './data-table-column-header'
import { DataTableRowActions } from './data-table-row-actions'
import LongText from '@/components/long-text'
import type { SysMenu } from '@/types/system'

// 菜单类型映射
const menuTypeMap = {
    'M': '目录',
    'C': '菜单',
    'F': '按钮'
}

// 显示状态映射
const visibleMap = {
    '0': '显示',
    '1': '隐藏'
}

export const columns: ColumnDef<SysMenu>[] = [
    {
        id: 'select',
        header: ({ table }) => (
            <Checkbox
                checked={table.getIsAllPageRowsSelected()}
                onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
                aria-label='全选'
                className='translate-y-[2px]'
            />
        ),
        cell: ({ row }) => (
            <Checkbox
                checked={row.getIsSelected()}
                onCheckedChange={(value) => row.toggleSelected(!!value)}
                aria-label='选择行'
                className='translate-y-[2px]'
            />
        ),
        enableSorting: false,
        enableHiding: false,
        meta: {
            className: cn(
                'drop-shadow-[0_1px_2px_rgb(0_0_0_/_0.1)] dark:drop-shadow-[0_1px_2px_rgb(255_255_255_/_0.1)] lg:drop-shadow-none',
                'bg-background transition-colors duration-200 group-hover/row:bg-muted group-data-[state=selected]/row:bg-muted',
                'sticky left-0 z-10 lg:table-cell'
            ),
        },
    },
    {
        accessorKey: 'menuName',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='菜单名称' />
        ),
        cell: ({ row }) => (
            <LongText className='max-w-36 font-medium'>{row.getValue('menuName')}</LongText>
        ),
        meta: {
            className: cn(
                'drop-shadow-[0_1px_2px_rgb(0_0_0_/_0.1)] dark:drop-shadow-[0_1px_2px_rgb(255_255_255_/_0.1)] lg:drop-shadow-none',
                'bg-background transition-colors duration-200 group-hover/row:bg-muted group-data-[state=selected]/row:bg-muted',
                'sticky left-6 md:table-cell'
            ),
        },
        enableHiding: false,
        filterFn: 'includesString',
    },
    {
        accessorKey: 'icon',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='图标' />
        ),
        cell: ({ row }) => {
            const icon = row.getValue('icon') as string
            return (
                <div className='flex justify-center'>
                    {icon ? (
                        <span className='text-lg'>{icon}</span>
                    ) : (
                        <span className='text-muted-foreground'>-</span>
                    )}
                </div>
            )
        },
        meta: { className: 'w-16' },
        enableSorting: false,
    },
    {
        accessorKey: 'orderNum',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='排序' />
        ),
        cell: ({ row }) => {
            const orderNum = row.getValue('orderNum') as number
            return <div className='text-center'>{orderNum || '-'}</div>
        },
        meta: { className: 'w-20' },
    },
    {
        accessorKey: 'menuType',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='类型' />
        ),
        cell: ({ row }) => {
            const menuType = row.getValue('menuType') as string
            const text = menuTypeMap[menuType as keyof typeof menuTypeMap] || menuType || '-'

            let variant: 'default' | 'secondary' | 'outline' = 'default'
            if (menuType === 'M') variant = 'default'
            else if (menuType === 'C') variant = 'secondary'
            else if (menuType === 'F') variant = 'outline'

            return (
                <div className='flex justify-center'>
                    <Badge variant={variant} className='min-w-12 justify-center'>
                        {text}
                    </Badge>
                </div>
            )
        },
        meta: { className: 'w-20' },
        filterFn: (row, id, value) => {
            return value.includes(row.getValue(id))
        },
    },
    {
        accessorKey: 'visible',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='显示' />
        ),
        cell: ({ row }) => {
            const visible = row.getValue('visible') as string
            const text = visibleMap[visible as keyof typeof visibleMap] || visible || '显示'
            const variant = visible === '0' ? 'default' : 'secondary'

            return (
                <div className='flex justify-center'>
                    <Badge variant={variant} className='min-w-12 justify-center'>
                        {text}
                    </Badge>
                </div>
            )
        },
        meta: { className: 'w-20' },
    },
    {
        accessorKey: 'status',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='状态' />
        ),
        cell: ({ row }) => {
            const status = row.getValue('status') as string

            if (!status) return <div className='text-center'>-</div>

            const variant = status === '0' ? 'default' : 'secondary'
            const text = status === '0' ? '正常' : '停用'

            return (
                <div className='flex justify-center'>
                    <Badge variant={variant} className='min-w-16 justify-center'>
                        {text}
                    </Badge>
                </div>
            )
        },
        meta: { className: 'w-20' },
        filterFn: (row, id, value) => {
            return value.includes(row.getValue(id))
        },
    },
    {
        accessorKey: 'path',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='路径' />
        ),
        cell: ({ row }) => {
            const path = row.getValue('path') as string
            return <LongText className='max-w-32 font-mono text-sm'>{path || '-'}</LongText>
        },
        enableSorting: false,
    },
    {
        accessorKey: 'perms',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='权限标识' />
        ),
        cell: ({ row }) => {
            const perms = row.getValue('perms') as string
            return <LongText className='max-w-32 font-mono text-sm'>{perms || '-'}</LongText>
        },
        enableSorting: false,
    },
    {
        accessorKey: 'createTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='创建时间' />
        ),
        cell: ({ row }) => {
            const createTime = row.getValue('createTime') as string
            if (!createTime) return <div>-</div>

            const date = new Date(createTime)
            return (
                <div className='text-sm text-muted-foreground'>
                    {date.toLocaleDateString('zh-CN')}
                </div>
            )
        },
        meta: { className: 'w-32' },
    },
    {
        id: 'actions',
        cell: ({ row }) => <DataTableRowActions row={row} />,
        meta: { className: 'w-16' },
        enableSorting: false,
        enableHiding: false,
    },
] 