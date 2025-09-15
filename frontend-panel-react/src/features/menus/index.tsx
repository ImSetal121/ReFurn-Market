import { useState } from 'react'
import { Header } from '@/components/layout/header'
import { Main } from '@/components/layout/main'
import { ProfileDropdown } from '@/components/profile-dropdown'
import { Search } from '@/components/search'
import { ThemeSwitch } from '@/components/theme-switch'
import { columns } from './components/menus-columns'
import { MenusDialogs } from './components/menus-dialogs'
import { MenusPrimaryButtons } from './components/menus-primary-buttons'
import { MenusTable } from './components/menus-table'
import MenusProvider from './context/menus-context'
import { useMenusPage } from './data/menus-service'
import type { MenuQuery } from '@/types/system'

export default function Menus() {
    // 分页和查询状态
    const [queryParams] = useState<MenuQuery>({
        current: 1,
        size: 10,
    })

    // 获取菜单数据
    const { data, isLoading, error } = useMenusPage(queryParams)

    return (
        <MenusProvider>
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
                        <h2 className='text-2xl font-bold tracking-tight'>菜单管理</h2>
                        <p className='text-muted-foreground'>
                            管理系统菜单及其权限配置
                        </p>
                    </div>
                    <MenusPrimaryButtons />
                </div>

                <div className='-mx-4 flex-1 overflow-auto px-4 py-1 lg:flex-row lg:space-y-0 lg:space-x-12'>
                    {isLoading ? (
                        <div className='flex h-32 items-center justify-center'>
                            加载中...
                        </div>
                    ) : error ? (
                        <div className='flex h-32 items-center justify-center text-red-500'>
                            加载菜单数据失败: {error.message}
                        </div>
                    ) : (
                        <MenusTable
                            data={data?.records || []}
                            columns={columns}
                        />
                    )}
                </div>
            </Main>

            <MenusDialogs />
        </MenusProvider>
    )
} 