import { ColumnDef } from '@tanstack/react-table'
import { Checkbox } from '@/components/ui/checkbox'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import { DataTableColumnHeader } from './data-table-column-header'
import { DataTableRowActions } from './data-table-row-actions'
import LongText from '@/components/long-text'
import type { Role } from '../data/schema'

export const columns: ColumnDef<Role>[] = [
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
        cell: ({ row }) => {
            const role = row.original as Role
            const isSuperAdmin = role.id === 1

            return (
                <Checkbox
                    checked={row.getIsSelected()}
                    onCheckedChange={(value) => row.toggleSelected(!!value)}
                    aria-label='选择行'
                    className='translate-y-[2px]'
                    disabled={isSuperAdmin}
                />
            )
        },
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
        accessorKey: 'key',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='角色标识' />
        ),
        cell: ({ row }) => (
            <LongText className='max-w-36 font-medium'>{row.getValue('key')}</LongText>
        ),
        meta: {
            className: cn(
                'drop-shadow-[0_1px_2px_rgb(0_0_0_/_0.1)] dark:drop-shadow-[0_1px_2px_rgb(255_255_255_/_0.1)] lg:drop-shadow-none',
                'bg-background transition-colors duration-200 group-hover/row:bg-muted group-data-[state=selected]/row:bg-muted',
                'sticky left-6 md:table-cell'
            ),
        },
        enableHiding: false,
    },
    {
        accessorKey: 'name',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='角色名称' />
        ),
        cell: ({ row }) => {
            const name = row.getValue('name') as string
            const role = row.original as Role
            const isSuperAdmin = role.id === 1

            return (
                <div className='flex items-center gap-2'>
                    <LongText className='max-w-36'>{name}</LongText>
                    {isSuperAdmin && (
                        <Badge variant='destructive' className='text-xs'>
                            超级管理员
                        </Badge>
                    )}
                </div>
            )
        },
        meta: { className: 'w-36' },
        filterFn: 'includesString',
    },
    {
        accessorKey: 'description',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='描述' />
        ),
        cell: ({ row }) => {
            const description = row.getValue('description') as string
            return <LongText className='max-w-48'>{description || '-'}</LongText>
        },
        enableSorting: false,
    },
    {
        accessorKey: 'order',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='排序' />
        ),
        cell: ({ row }) => {
            const order = row.getValue('order') as number
            return <div className='text-center'>{order || '-'}</div>
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

            const variant = status === 'active' ? 'default' : 'secondary'
            const text = status === 'active' ? '启用' : '禁用'

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