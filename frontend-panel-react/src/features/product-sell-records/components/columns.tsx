import { ColumnDef } from '@tanstack/react-table'
import { cn } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import { Button } from '@/components/ui/button'
import { MoreHorizontal, Eye, Edit, Trash2 } from 'lucide-react'
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import LongText from '@/components/long-text'
import { ProductSellRecord, statusLabels, statusColors } from '../data/schema'
import { useProductSellRecords } from '../context/context'
import { DataTableColumnHeader } from './data-table-column-header'

const DataTableRowActions = ({ row }: { row: { original: ProductSellRecord } }) => {
    const { setOpen, setCurrentRow } = useProductSellRecords()

    const handleView = () => {
        setCurrentRow(row.original)
        setOpen('view')
    }

    const handleEdit = () => {
        setCurrentRow(row.original)
        setOpen('edit')
    }

    const handleDelete = () => {
        setCurrentRow(row.original)
        setOpen('delete')
    }

    return (
        <DropdownMenu>
            <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="h-8 w-8 p-0">
                    <span className="sr-only">打开菜单</span>
                    <MoreHorizontal className="h-4 w-4" />
                </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={handleView}>
                    <Eye className="mr-2 h-4 w-4" />
                    查看详情
                </DropdownMenuItem>
                <DropdownMenuItem onClick={handleEdit}>
                    <Edit className="mr-2 h-4 w-4" />
                    编辑
                </DropdownMenuItem>
                <DropdownMenuItem onClick={handleDelete}>
                    <Trash2 className="mr-2 h-4 w-4" />
                    删除
                </DropdownMenuItem>
            </DropdownMenuContent>
        </DropdownMenu>
    )
}

export const columns: ColumnDef<ProductSellRecord>[] = [
    {
        id: 'select',
        header: ({ table }) => (
            <Checkbox
                checked={
                    table.getIsAllPageRowsSelected() ||
                    (table.getIsSomePageRowsSelected() && 'indeterminate')
                }
                onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
                aria-label="全选"
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
                aria-label="选择行"
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
            <div className="w-fit text-nowrap font-mono text-sm">{row.getValue('id')}</div>
        ),
        meta: { className: 'w-16' },
    },
    {
        accessorKey: 'productId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='商品ID' />
        ),
        cell: ({ row }) => {
            const productId = row.getValue('productId') as number
            return productId ? (
                <div className="font-mono text-sm">{productId}</div>
            ) : (
                <span className="text-muted-foreground">-</span>
            )
        },
        meta: { className: 'w-24' },
        filterFn: 'includesString',
    },
    {
        accessorKey: 'product',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='商品信息' />
        ),
        cell: ({ row }) => {
            const product = row.getValue('product') as ProductSellRecord['product']
            return (
                <div className="max-w-48">
                    {product ? (
                        <div>
                            <LongText className="font-medium">{product.name}</LongText>
                            <div className="text-sm text-muted-foreground">
                                ID: {product.id}
                            </div>
                        </div>
                    ) : (
                        <span className="text-muted-foreground">未关联商品</span>
                    )}
                </div>
            )
        },
        enableSorting: false,
    },
    {
        accessorKey: 'finalProductPrice',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='成交价格' />
        ),
        cell: ({ row }) => {
            const price = row.getValue('finalProductPrice') as number
            return (
                <div className="font-mono">
                    {price ? `$${price.toFixed(2)}` : '-'}
                </div>
            )
        },
        meta: { className: 'w-32' },
        filterFn: 'includesString',
    },
    {
        accessorKey: 'isAuction',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='交易类型' />
        ),
        cell: ({ row }) => {
            const isAuction = row.getValue('isAuction') as boolean
            return (
                <Badge variant={isAuction ? 'default' : 'secondary'}>
                    {isAuction ? '拍卖' : '直购'}
                </Badge>
            )
        },
        meta: { className: 'w-24' },
        filterFn: (row, _id, value) => {
            const isAuction = row.getValue('isAuction') as boolean
            return value.includes(isAuction ? 'true' : 'false')
        },
    },
    {
        accessorKey: 'isSelfPickup',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='配送方式' />
        ),
        cell: ({ row }) => {
            const isSelfPickup = row.getValue('isSelfPickup') as boolean
            return (
                <Badge variant="outline">
                    {isSelfPickup ? '自提' : '快递'}
                </Badge>
            )
        },
        meta: { className: 'w-24' },
        filterFn: (row, _id, value) => {
            const isSelfPickup = row.getValue('isSelfPickup') as boolean
            return value.includes(isSelfPickup ? 'true' : 'false')
        },
    },
    {
        accessorKey: 'status',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='状态' />
        ),
        cell: ({ row }) => {
            const status = row.getValue('status') as keyof typeof statusLabels
            if (!status) return <span className="text-muted-foreground">-</span>

            return (
                <Badge variant={statusColors[status] || 'default'}>
                    {statusLabels[status] || status}
                </Badge>
            )
        },
        meta: { className: 'w-32' },
        filterFn: (row, _id, value) => {
            const status = row.getValue('status') as string
            return value.includes(status)
        },
    },
    {
        accessorKey: 'sellerUserId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='卖家ID' />
        ),
        cell: ({ row }) => {
            const sellerId = row.getValue('sellerUserId') as number
            return sellerId ? (
                <div className="font-mono text-sm">{sellerId}</div>
            ) : (
                <span className="text-muted-foreground">-</span>
            )
        },
        meta: { className: 'w-24' },
        filterFn: 'includesString',
    },
    {
        accessorKey: 'buyerUserId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='买家ID' />
        ),
        cell: ({ row }) => {
            const buyerId = row.getValue('buyerUserId') as number
            return buyerId ? (
                <div className="font-mono text-sm">{buyerId}</div>
            ) : (
                <span className="text-muted-foreground">-</span>
            )
        },
        meta: { className: 'w-24' },
        filterFn: 'includesString',
    },
    {
        accessorKey: 'productWarehouseShipmentId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='仓库出货ID' />
        ),
        cell: ({ row }) => {
            const shipmentId = row.getValue('productWarehouseShipmentId') as number
            return shipmentId ? (
                <div className="font-mono text-sm">{shipmentId}</div>
            ) : (
                <span className="text-muted-foreground">-</span>
            )
        },
        meta: { className: 'w-32' },
    },
    {
        accessorKey: 'internalLogisticsTaskId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='内部物流ID' />
        ),
        cell: ({ row }) => {
            const taskId = row.getValue('internalLogisticsTaskId') as number
            return taskId ? (
                <div className="font-mono text-sm">{taskId}</div>
            ) : (
                <span className="text-muted-foreground">-</span>
            )
        },
        meta: { className: 'w-32' },
    },
    {
        accessorKey: 'productSelfPickupLogisticsId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='自提物流ID' />
        ),
        cell: ({ row }) => {
            const pickupId = row.getValue('productSelfPickupLogisticsId') as number
            return pickupId ? (
                <div className="font-mono text-sm">{pickupId}</div>
            ) : (
                <span className="text-muted-foreground">-</span>
            )
        },
        meta: { className: 'w-32' },
    },
    {
        accessorKey: 'isDelete',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='删除状态' />
        ),
        cell: ({ row }) => {
            const isDelete = row.getValue('isDelete') as boolean
            return (
                <Badge variant={isDelete ? 'destructive' : 'default'}>
                    {isDelete ? '已删除' : '正常'}
                </Badge>
            )
        },
        meta: { className: 'w-24' },
        filterFn: (row, _id, value) => {
            const isDelete = row.getValue('isDelete') as boolean
            return value.includes(isDelete ? 'true' : 'false')
        },
    },
    {
        accessorKey: 'createTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='创建时间' />
        ),
        cell: ({ row }) => {
            const createTime = row.getValue('createTime') as string
            return createTime ? (
                <div className="text-sm">
                    {new Date(createTime).toLocaleString('zh-CN')}
                </div>
            ) : (
                <span className="text-muted-foreground">-</span>
            )
        },
        meta: { className: 'w-48' },
    },
    {
        accessorKey: 'updateTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='更新时间' />
        ),
        cell: ({ row }) => {
            const updateTime = row.getValue('updateTime') as string
            return updateTime ? (
                <div className="text-sm">
                    {new Date(updateTime).toLocaleString('zh-CN')}
                </div>
            ) : (
                <span className="text-muted-foreground">-</span>
            )
        },
        meta: { className: 'w-48' },
    },
    {
        id: 'actions',
        header: '操作',
        cell: ({ row }) => <DataTableRowActions row={row} />,
        enableSorting: false,
        enableHiding: false,
        meta: { className: 'w-16' },
    },
] 