import { type ColumnDef } from '@tanstack/react-table'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import { cn } from '@/lib/utils'
import { DataTableColumnHeader } from './data-table-column-header'
import { DataTableRowActions } from './data-table-row-actions'
import type { Product } from '../data/schema'
import { Button } from '@/components/ui/button'
import { MoreHorizontal } from 'lucide-react'
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { useProductsContext } from '../context/products-context'

// 创建长文本组件
const LongText = ({ children, className }: { children: React.ReactNode; className?: string }) => (
    <div className={cn('truncate', className)} title={children?.toString()}>
        {children}
    </div>
)

// 操作按钮组件
function ActionCell({ product }: { product: { id?: number; name?: string } }) {
    const { setSelectedProduct, setMode, setIsActionDialogOpen, setIsDeleteDialogOpen } = useProductsContext()

    const handleEdit = () => {
        setSelectedProduct(product as Product)
        setMode('edit')
        setIsActionDialogOpen(true)
    }

    const handleDelete = () => {
        setSelectedProduct(product as Product)
        setIsDeleteDialogOpen(true)
    }

    return (
        <DropdownMenu>
            <DropdownMenuTrigger asChild>
                <Button variant='ghost' className='h-8 w-8 p-0'>
                    <MoreHorizontal className='h-4 w-4' />
                </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align='end' className='w-[160px]'>
                <DropdownMenuItem onClick={handleEdit}>
                    编辑商品
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => navigator.clipboard.writeText(product.name || '')}>
                    复制商品名称
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleDelete} className='text-red-600'>
                    删除商品
                </DropdownMenuItem>
            </DropdownMenuContent>
        </DropdownMenu>
    )
}

export const columns: ColumnDef<Product>[] = [
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
        accessorKey: 'id',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='ID' />
        ),
        cell: ({ row }) => <div className='w-[60px]'>{row.getValue('id')}</div>,
        meta: { className: 'w-20' },
        enableSorting: false,
        enableHiding: false,
    },
    {
        accessorKey: 'name',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='商品名称' />
        ),
        cell: ({ row }) => (
            <LongText className='max-w-36 font-medium'>{row.getValue('name')}</LongText>
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
        accessorKey: 'userId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='用户ID' />
        ),
        cell: ({ row }) => {
            const userId = row.getValue('userId') as number
            return <div className='text-center'>{userId || '-'}</div>
        },
        meta: { className: 'w-24' },
    },
    {
        accessorKey: 'categoryId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='分类ID' />
        ),
        cell: ({ row }) => {
            const categoryId = row.getValue('categoryId') as number
            return <div className='text-center'>{categoryId || '-'}</div>
        },
        meta: { className: 'w-24' },
    },
    {
        accessorKey: 'type',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='商品类型' />
        ),
        cell: ({ row }) => {
            const type = row.getValue('type') as string
            return type ? (
                <Badge variant='secondary'>{type}</Badge>
            ) : (
                <span className='text-muted-foreground'>-</span>
            )
        },
        meta: { className: 'w-24' },
        filterFn: (row, id, value) => {
            return value.includes(row.getValue(id))
        },
    },
    {
        accessorKey: 'category',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='分类名称' />
        ),
        cell: ({ row }) => {
            const category = row.getValue('category') as string
            return category ? (
                <Badge variant='outline'>{category}</Badge>
            ) : (
                <span className='text-muted-foreground'>-</span>
            )
        },
        meta: { className: 'w-28' },
    },
    {
        accessorKey: 'price',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='价格' />
        ),
        cell: ({ row }) => {
            const price = row.getValue('price') as number
            return price ? (
                <span className='font-medium text-green-600'>¥{price.toFixed(2)}</span>
            ) : (
                <span className='text-muted-foreground'>-</span>
            )
        },
        meta: { className: 'w-24' },
    },
    {
        accessorKey: 'stock',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='库存' />
        ),
        cell: ({ row }) => {
            const stock = row.getValue('stock') as number
            return (
                <div className='text-center'>
                    <span className={stock && stock < 10 ? 'text-red-500 font-medium' : ''}>
                        {stock ?? 0}
                    </span>
                </div>
            )
        },
        meta: { className: 'w-20' },
    },
    {
        accessorKey: 'description',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='商品描述' />
        ),
        cell: ({ row }) => {
            const description = row.getValue('description') as string
            return <LongText className='max-w-32 text-sm'>{description || '-'}</LongText>
        },
        enableSorting: false,
    },
    {
        accessorKey: 'address',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='地址' />
        ),
        cell: ({ row }) => {
            const address = row.getValue('address') as string
            return <LongText className='max-w-32 text-sm'>{address || '-'}</LongText>
        },
        enableSorting: false,
    },
    {
        accessorKey: 'isAuction',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='拍卖' />
        ),
        cell: ({ row }) => {
            const isAuction = row.getValue('isAuction') as boolean
            return (
                <div className='flex justify-center'>
                    <Badge variant={isAuction ? 'default' : 'secondary'} className='min-w-12 justify-center'>
                        {isAuction ? '是' : '否'}
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
        accessorKey: 'isSelfPickup',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='自提' />
        ),
        cell: ({ row }) => {
            const isSelfPickup = row.getValue('isSelfPickup') as boolean
            return (
                <div className='flex justify-center'>
                    <Badge variant={isSelfPickup ? 'default' : 'secondary'} className='min-w-12 justify-center'>
                        {isSelfPickup ? '是' : '否'}
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
        accessorKey: 'status',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='状态' />
        ),
        cell: ({ row }) => {
            const status = row.getValue('status') as string

            if (!status) return <div className='text-center'>-</div>

            const getStatusVariant = (status: string) => {
                switch (status) {
                    case 'active':
                    case '正常':
                        return 'default'
                    case 'inactive':
                    case '停用':
                        return 'secondary'
                    case 'sold':
                    case '已售出':
                        return 'destructive'
                    default:
                        return 'secondary'
                }
            }

            return (
                <div className='flex justify-center'>
                    <Badge variant={getStatusVariant(status)} className='min-w-16 justify-center'>
                        {status}
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
        accessorKey: 'updateTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title='更新时间' />
        ),
        cell: ({ row }) => {
            const updateTime = row.getValue('updateTime') as string
            if (!updateTime) return <div>-</div>

            const date = new Date(updateTime)
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