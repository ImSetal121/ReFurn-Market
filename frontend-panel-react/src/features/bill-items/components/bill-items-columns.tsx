import { ColumnDef } from '@tanstack/react-table'
import { cn } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import LongText from '@/components/long-text'
import { BillItem, getCostTypeName, getBillStatusName } from '../data/schema'
import { DataTableColumnHeader } from './data-table-column-header'
import { DataTableRowActions } from './data-table-row-actions'

export const columns: ColumnDef<BillItem>[] = [
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
        accessorKey: 'costType',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='费用类型' />
        ),
        cell: ({ row }) => {
            const costType = row.getValue('costType') as string
            const typeName = getCostTypeName(costType)

            // 根据费用类型设置不同颜色
            const getTypeColor = (type: string) => {
                switch (type) {
                    case 'SHIPPING': return 'bg-blue-100 text-blue-800'
                    case 'PLATFORM_FEE': return 'bg-purple-100 text-purple-800'
                    case 'COMMISSION': return 'bg-green-100 text-green-800'
                    case 'INSURANCE': return 'bg-yellow-100 text-yellow-800'
                    case 'STORAGE': return 'bg-orange-100 text-orange-800'
                    case 'HANDLING': return 'bg-cyan-100 text-cyan-800'
                    case 'TAX': return 'bg-red-100 text-red-800'
                    case 'OTHER': return 'bg-gray-100 text-gray-800'
                    default: return 'bg-gray-100 text-gray-800'
                }
            }

            return (
                <Badge className={`text-xs ${getTypeColor(costType)}`}>
                    {typeName}
                </Badge>
            )
        },
        enableSorting: false,
        meta: { className: 'w-24' },
        filterFn: (row, _id, value) => {
            const costType = row.getValue('costType') as string
            return value.includes(costType)
        },
    },
    {
        accessorKey: 'costDescription',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='费用描述' />
        ),
        cell: ({ row }) => {
            const description = row.getValue('costDescription') as string
            return <LongText className='max-w-48'>{description || '-'}</LongText>
        },
        enableSorting: false,
        filterFn: 'includesString',
    },
    {
        accessorKey: 'cost',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='费用金额' />
        ),
        cell: ({ row }) => {
            const cost = row.getValue('cost') as number
            return (
                <div className='font-mono text-green-600'>
                    ¥{cost.toFixed(2)}
                </div>
            )
        },
        meta: { className: 'w-24' },
    },
    {
        accessorKey: 'paySubject',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='支付主体' />
        ),
        cell: ({ row }) => {
            const paySubject = row.getValue('paySubject') as string
            return <LongText className='max-w-32'>{paySubject || '-'}</LongText>
        },
        enableSorting: false,
        filterFn: 'includesString',
    },
    {
        accessorKey: 'isPlatformPay',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='支付方式' />
        ),
        cell: ({ row }) => {
            const isPlatformPay = row.getValue('isPlatformPay') as boolean
            return (
                <Badge variant={isPlatformPay ? 'default' : 'secondary'} className='text-xs'>
                    {isPlatformPay ? '平台支付' : '用户支付'}
                </Badge>
            )
        },
        enableSorting: false,
        meta: { className: 'w-20' },
        filterFn: (row, _id, value) => {
            const isPlatformPay = row.getValue('isPlatformPay') as boolean
            return value.includes(isPlatformPay.toString())
        },
    },
    {
        accessorKey: 'payUserName',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='支付用户' />
        ),
        cell: ({ row }) => {
            const payUserName = row.getValue('payUserName') as string
            return <LongText className='max-w-24'>{payUserName || '-'}</LongText>
        },
        enableSorting: false,
        filterFn: 'includesString',
    },
    {
        accessorKey: 'status',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='状态' />
        ),
        cell: ({ row }) => {
            const status = row.getValue('status') as string
            const statusName = getBillStatusName(status)

            // 根据状态设置不同颜色
            const getStatusColor = (status: string) => {
                switch (status) {
                    case 'PENDING': return 'bg-yellow-100 text-yellow-800'
                    case 'PAID': return 'bg-green-100 text-green-800'
                    case 'CANCELLED': return 'bg-gray-100 text-gray-800'
                    case 'REFUNDED': return 'bg-blue-100 text-blue-800'
                    case 'FAILED': return 'bg-red-100 text-red-800'
                    default: return 'bg-gray-100 text-gray-800'
                }
            }

            return (
                <Badge className={`text-xs ${getStatusColor(status)}`}>
                    {statusName}
                </Badge>
            )
        },
        enableSorting: false,
        meta: { className: 'w-20' },
        filterFn: (row, _id, value) => {
            const status = row.getValue('status') as string
            return value.includes(status)
        },
    },
    {
        accessorKey: 'payTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='支付时间' />
        ),
        cell: ({ row }) => {
            const payTime = row.getValue('payTime') as string
            return (
                <div className='text-sm text-muted-foreground'>
                    {payTime ? new Date(payTime).toLocaleString('zh-CN') : '-'}
                </div>
            )
        },
    },
    {
        accessorKey: 'productName',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='关联商品' />
        ),
        cell: ({ row }) => {
            const productName = row.getValue('productName') as string
            return <LongText className='max-w-32'>{productName || '-'}</LongText>
        },
        enableSorting: false,
        filterFn: 'includesString',
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