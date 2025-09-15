import { useState } from 'react'
import { Header } from '@/components/layout/header'
import { Main } from '@/components/layout/main'
import { ProfileDropdown } from '@/components/profile-dropdown'
import { Search } from '@/components/search'
import { ThemeSwitch } from '@/components/theme-switch'
import { columns } from './components/roles-columns'
import { RolesDialogs } from './components/roles-dialogs'
import { RolesPrimaryButtons } from './components/roles-primary-buttons'
import { RolesTable } from './components/roles-table'
import RolesProvider from './context/roles-context'
import { useRolesPage } from './data/roles-service'
import type { RoleQuery } from './data/schema'

export default function Roles() {
    // 分页和查询状态
    const [queryParams] = useState<RoleQuery>({
        current: 1,
        size: 10,
    })

    // 获取角色数据
    const { data, isLoading, error } = useRolesPage(queryParams)

    return (
        <RolesProvider>
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
                        <h2 className='text-2xl font-bold tracking-tight'>角色管理</h2>
                        <p className='text-muted-foreground'>
                            管理系统角色及其权限配置
                        </p>
                    </div>
                    <RolesPrimaryButtons />
                </div>

                <div className='-mx-4 flex-1 overflow-auto px-4 py-1 lg:flex-row lg:space-y-0 lg:space-x-12'>
                    {isLoading ? (
                        <div className='flex h-32 items-center justify-center'>
                            加载中...
                        </div>
                    ) : error ? (
                        <div className='flex h-32 items-center justify-center text-red-500'>
                            加载角色数据失败: {error.message}
                        </div>
                    ) : (
                        <RolesTable
                            data={data?.records || []}
                            columns={columns}
                        />
                    )}
                </div>
            </Main>

            <RolesDialogs />
        </RolesProvider>
    )
} 