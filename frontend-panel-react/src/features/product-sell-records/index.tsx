import { useState } from 'react'
import { Header } from '@/components/layout/header'
import { Main } from '@/components/layout/main'
import { ProfileDropdown } from '@/components/profile-dropdown'
import { Search } from '@/components/search'
import { ThemeSwitch } from '@/components/theme-switch'
import { columns } from './components/columns'
import { ProductSellRecordsTable } from './components/table'
import { ProductSellRecordsDialogs } from './components/dialogs'
import { ProductSellRecordsPrimaryButtons } from './components/primary-buttons'
import ProductSellRecordsProvider from './context/context'
import { useProductSellRecordsPage } from './data/service'
import type { ProductSellRecordQuery } from './data/schema'

export default function ProductSellRecords() {
    // 分页和查询状态
    const [queryParams] = useState<ProductSellRecordQuery>({
        current: 1,
        size: 10,
    })

    // 获取销售记录数据
    const { data, isLoading, error } = useProductSellRecordsPage(queryParams)

    return (
        <ProductSellRecordsProvider>
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
                        <h2 className='text-2xl font-bold tracking-tight'>商品销售记录</h2>
                        <p className='text-muted-foreground'>
                            管理商品销售交易记录
                        </p>
                    </div>
                    <ProductSellRecordsPrimaryButtons />
                </div>

                <div className='-mx-4 flex-1 overflow-auto px-4 py-1 lg:flex-row lg:space-y-0 lg:space-x-12'>
                    {isLoading ? (
                        <div className='flex h-32 items-center justify-center'>
                            加载中...
                        </div>
                    ) : error ? (
                        <div className='flex h-32 items-center justify-center text-red-500'>
                            加载销售记录数据失败: {error.message}
                        </div>
                    ) : (
                        <ProductSellRecordsTable
                            data={data?.records || []}
                            columns={columns}
                        />
                    )}
                </div>
            </Main>

            <ProductSellRecordsDialogs />
        </ProductSellRecordsProvider>
    )
} 