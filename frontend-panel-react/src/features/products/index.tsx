import { useState } from 'react'
import { Header } from '@/components/layout/header'
import { Main } from '@/components/layout/main'
import { ProfileDropdown } from '@/components/profile-dropdown'
import { Search } from '@/components/search'
import { ThemeSwitch } from '@/components/theme-switch'
import { ProductsTable } from './components/products-table'
import { ProductsDialogs } from './components/products-dialogs'
import ProductsProvider from './context/products-context'
import { useProductsPage } from './data/products-service'
import type { ProductQuery, Product } from './data/schema'
import { Button } from '@/components/ui/button'
import { Plus, MoreHorizontal } from 'lucide-react'
import { useProductsContext } from './context/products-context'
import { columns } from './components/products-columns'

import { Badge } from '@/components/ui/badge'
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

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

function ProductsPrimaryButtons() {
    const { setMode, setIsActionDialogOpen, reset } = useProductsContext()

    const handleAdd = () => {
        reset()
        setMode('add')
        setIsActionDialogOpen(true)
    }

    return (
        <div className='flex items-center space-x-2'>
            <Button onClick={handleAdd}>
                <Plus className='mr-2 h-4 w-4' />
                添加商品
            </Button>
        </div>
    )
}

function ProductsContent() {
    // 分页和查询状态
    const [queryParams, setQueryParams] = useState<ProductQuery>({
        current: 1,
        size: 10,
    })

    // 获取商品数据
    const { data, isLoading, error } = useProductsPage(queryParams)

    // 处理分页变化
    const handlePageChange = (page: number) => {
        setQueryParams(prev => ({ ...prev, current: page }))
    }

    // 处理每页条数变化
    const handlePageSizeChange = (pageSize: number) => {
        setQueryParams(prev => ({ ...prev, size: pageSize, current: 1 }))
    }

    return (
        <>
            <Header fixed>
                <Search />
                <div className='ml-auto flex items-center space-x-4'>
                    <ThemeSwitch />
                    <ProfileDropdown />
                </div>
            </Header>

            <Main>
                <div className='mb-2 flex flex-wrap items-center justify-between space-y-2'>
                    <div>
                        <h2 className='text-2xl font-bold tracking-tight'>商品管理</h2>
                        <p className='text-muted-foreground'>
                            管理商品信息，包括商品的增删改查操作
                        </p>
                    </div>
                    <ProductsPrimaryButtons />
                </div>

                <div className='-mx-4 flex-1 overflow-auto px-4 py-1 lg:flex-row lg:space-y-0 lg:space-x-12'>
                    {isLoading ? (
                        <div className='flex h-32 items-center justify-center'>
                            加载中...
                        </div>
                    ) : error ? (
                        <div className='flex h-32 items-center justify-center text-red-500'>
                            加载商品数据失败: {error.message}
                        </div>
                    ) : (
                        <ProductsTable
                            data={data?.records || []}
                            columns={columns}
                            pageCount={data?.pages || 1}
                            currentPage={data?.current || 1}
                            pageSize={data?.size || 10}
                            onPageChange={handlePageChange}
                            onPageSizeChange={handlePageSizeChange}
                            total={data?.total || 0}
                        />
                    )}
                </div>
            </Main>

            <ProductsDialogs />
        </>
    )
}

export default function ProductsPage() {
    return (
        <ProductsProvider>
            <ProductsContent />
        </ProductsProvider>
    )
} 