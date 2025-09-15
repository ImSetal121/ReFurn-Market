import { useState } from 'react'
import { Header } from '@/components/layout/header'
import { Main } from '@/components/layout/main'
import { ProfileDropdown } from '@/components/profile-dropdown'
import { Search } from '@/components/search'
import { ThemeSwitch } from '@/components/theme-switch'
import { columns } from './components/users-columns'
import { UsersDialogs } from './components/users-dialogs'
import { UsersPrimaryButtons } from './components/users-primary-buttons'
import { UsersTable } from './components/users-table'
import UsersProvider from './context/users-context'
import { useUsersPage } from './data/users-service'
import type { UserQuery } from './data/schema'

export default function Users() {
  // 分页和查询状态
  const [queryParams] = useState<UserQuery>({
    current: 1,
    size: 10,
  })

  // 获取用户数据
  const { data, isLoading, error } = useUsersPage(queryParams)

  return (
    <UsersProvider>
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
            <h2 className='text-2xl font-bold tracking-tight'>用户管理</h2>
            <p className='text-muted-foreground'>
              管理系统用户及其角色权限
            </p>
          </div>
          <UsersPrimaryButtons />
        </div>

        <div className='-mx-4 flex-1 overflow-auto px-4 py-1 lg:flex-row lg:space-y-0 lg:space-x-12'>
          {isLoading ? (
            <div className='flex h-32 items-center justify-center'>
              加载中...
            </div>
          ) : error ? (
            <div className='flex h-32 items-center justify-center text-red-500'>
              加载用户数据失败: {error.message}
            </div>
          ) : (
            <UsersTable
              data={data?.records || []}
              columns={columns}
            />
          )}
        </div>
      </Main>

      <UsersDialogs />
    </UsersProvider>
  )
}
