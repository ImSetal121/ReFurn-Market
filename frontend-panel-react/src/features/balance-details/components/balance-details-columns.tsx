import { ColumnDef } from '@tanstack/react-table'
import { cn } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import LongText from '@/components/long-text'
import { BalanceDetail, getTransactionTypeName } from '../data/schema'
import { DataTableColumnHeader } from './data-table-column-header'
import { DataTableRowActions } from './data-table-row-actions'

export const columns: ColumnDef<BalanceDetail>[] = [
    {
        id: 'select',
        header: ({ table }) => (
            <Checkbox
                checked={
                    table.getIsAllPageRowsSelected() ||
                    (table.getIsSomePageRowsSelected() && 'indeterminate')
                }
                onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
                aria-label='Select all'
                className='translate-y-[2px]'
            />
        ),
        meta: {
            className: cn(
                'sticky md:table-cell left-0 z-10 rounded-tl',
                'bg-background transition-colors duration-200 group-hover/row:bg-muted group-data-[state=selected]/row:bg-muted'
            ),
        },
        cell: ({ row }) => (
            <Checkbox
                checked={row.getIsSelected()}
                onCheckedChange={(value) => row.toggleSelected(!!value)}
                aria-label='Select row'
                className='translate-y-[2px]'
            />
        ),
        enableSorting: false,
        enableHiding: false,
    },
    {
        accessorKey: 'id',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='ID' />
        ),
        cell: ({ row }) => (
            <div className='w-fit text-nowrap font-mono text-sm'>{row.getValue('id')}</div>
        ),
        meta: { className: 'w-16' },
    },
    {
        accessorKey: 'userId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='用户ID' />
        ),
        cell: ({ row }) => (
            <div className='w-fit text-nowrap font-mono text-sm'>{row.getValue('userId')}</div>
        ),
        meta: { className: 'w-20' },
    },
    {
        accessorKey: 'username',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='用户名' />
        ),
        cell: ({ row }) => {
            const username = row.getValue('username') as string
            return <LongText className='max-w-24 font-medium'>{username || '-'}</LongText>
        },
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
        accessorKey: 'transactionType',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='交易类型' />
        ),
        cell: ({ row }) => {
            const transactionType = row.getValue('transactionType') as string
            const typeName = getTransactionTypeName(transactionType)

            // 根据交易类型设置不同颜色
            const getTypeColor = (type: string) => {
                switch (type) {
                    case 'DEPOSIT': return 'bg-green-100 text-green-800'
                    case 'WITHDRAW': return 'bg-red-100 text-red-800'
                    case 'PURCHASE': return 'bg-blue-100 text-blue-800'
                    case 'REFUND': return 'bg-yellow-100 text-yellow-800'
                    case 'COMMISSION': return 'bg-purple-100 text-purple-800'
                    case 'TRANSFER_IN': return 'bg-emerald-100 text-emerald-800'
                    case 'TRANSFER_OUT': return 'bg-orange-100 text-orange-800'
                    case 'ADJUSTMENT': return 'bg-gray-100 text-gray-800'
                    default: return 'bg-gray-100 text-gray-800'
                }
            }

            return (
                <Badge className={`text-xs ${getTypeColor(transactionType)}`}>
                    {typeName}
                </Badge>
            )
        },
        enableSorting: false,
        meta: { className: 'w-24' },
        filterFn: (row, _id, value) => {
            const transactionType = row.getValue('transactionType') as string
            return value.includes(transactionType)
        },
    },
    {
        accessorKey: 'amount',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='交易金额' />
        ),
        cell: ({ row }) => {
            const amount = row.getValue('amount') as number
            const isPositive = amount >= 0
            return (
                <div className={`font-mono ${isPositive ? 'text-green-600' : 'text-red-600'}`}>
                    {isPositive ? '+' : ''}{amount.toFixed(2)}
                </div>
            )
        },
        meta: { className: 'w-24' },
    },
    {
        accessorKey: 'balanceBefore',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='变动前余额' />
        ),
        cell: ({ row }) => {
            const balance = row.getValue('balanceBefore') as number
            return <div className='font-mono text-sm'>{balance.toFixed(2)}</div>
        },
        meta: { className: 'w-24' },
    },
    {
        accessorKey: 'balanceAfter',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='变动后余额' />
        ),
        cell: ({ row }) => {
            const balance = row.getValue('balanceAfter') as number
            return <div className='font-mono text-sm font-medium'>{balance.toFixed(2)}</div>
        },
        meta: { className: 'w-24' },
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
        filterFn: 'includesString',
    },
    {
        accessorKey: 'transactionTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='交易时间' />
        ),
        cell: ({ row }) => {
            const transactionTime = row.getValue('transactionTime') as string
            return (
                <div className='text-sm text-muted-foreground'>
                    {transactionTime ? new Date(transactionTime).toLocaleString('zh-CN') : '-'}
                </div>
            )
        },
    },
    {
        accessorKey: 'createTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='创建时间' />
        ),
        cell: ({ row }) => {
            const createTime = row.getValue('createTime') as string
            return (
                <div className='text-sm text-muted-foreground'>
                    {createTime ? new Date(createTime).toLocaleString('zh-CN') : '-'}
                </div>
            )
        },
    },
    {
        id: 'actions',
        header: () => <div className='text-center'>操作</div>,
        cell: ({ row }) => <DataTableRowActions row={row} />,
        enableSorting: false,
        enableHiding: false,
        meta: { className: 'w-16' },
    },
] 