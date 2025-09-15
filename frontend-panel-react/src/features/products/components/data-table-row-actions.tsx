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
import { useProductsContext } from '../context/products-context'
import type { Product } from '../data/schema'

interface DataTableRowActionsProps<TData> {
    row: Row<TData>
}

export function DataTableRowActions<TData>({
    row,
}: DataTableRowActionsProps<TData>) {
    const product = row.original as Product
    const { setSelectedProduct, setMode, setIsActionDialogOpen, setIsDeleteDialogOpen } = useProductsContext()

    const handleEdit = () => {
        setSelectedProduct(product)
        setMode('edit')
        setIsActionDialogOpen(true)
    }

    const handleDelete = () => {
        setSelectedProduct(product)
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
                    编辑商品
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => navigator.clipboard.writeText(product.name || '')}>
                    复制商品名称
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => navigator.clipboard.writeText(product.id?.toString() || '')}>
                    复制商品ID
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleDelete} className='text-red-600'>
                    删除商品
                </DropdownMenuItem>
            </DropdownMenuContent>
        </DropdownMenu>
    )
} 