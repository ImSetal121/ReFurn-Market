import { useState } from 'react'
import { Header } from '@/components/layout/header'
import { Main } from '@/components/layout/main'
import { ProfileDropdown } from '@/components/profile-dropdown'
import { Search } from '@/components/search'
import { ThemeSwitch } from '@/components/theme-switch'
import { columns } from './components/warehouses-columns'
import { WarehousesDialogs } from './components/warehouses-dialogs'
import { WarehousesPrimaryButtons } from './components/warehouses-primary-buttons'
import { WarehousesTable } from './components/warehouses-table'
import WarehousesProvider from './context/warehouses-context'
import { useWarehousesPage } from './data/warehouses-service'
import type { WarehouseQuery } from '@/api/RfWarehouseController'

export default function Warehouses() {
    // 分页和查询状态
    const [queryParams] = useState<WarehouseQuery>({
        current: 1,
        size: 10,
    })

    // 获取仓库数据
    const { data, isLoading, error } = useWarehousesPage(queryParams)

    return (
        <WarehousesProvider>
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
                        <h2 className='text-2xl font-bold tracking-tight'>仓库管理</h2>
                        <p className='text-muted-foreground'>
                            管理仓库信息及其相关配置
                        </p>
                    </div>
                    <WarehousesPrimaryButtons />
                </div>

                <div className='-mx-4 flex-1 overflow-auto px-4 py-1 lg:flex-row lg:space-y-0 lg:space-x-12'>
                    {isLoading ? (
                        <div className='flex h-32 items-center justify-center'>
                            加载中...
                        </div>
                    ) : error ? (
                        <div className='flex h-32 items-center justify-center text-red-500'>
                            加载仓库数据失败: {error.message}
                        </div>
                    ) : (
                        <WarehousesTable
                            data={data?.records || []}
                            columns={columns}
                        />
                    )}
                </div>
            </Main>

            <WarehousesDialogs />
        </WarehousesProvider>
    )
} 