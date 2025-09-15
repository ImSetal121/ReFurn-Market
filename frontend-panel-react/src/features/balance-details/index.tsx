import { useState } from 'react'
import { Header } from '@/components/layout/header'
import { Main } from '@/components/layout/main'
import { ProfileDropdown } from '@/components/profile-dropdown'
import { Search } from '@/components/search'
import { ThemeSwitch } from '@/components/theme-switch'
import { Button } from '@/components/ui/button'
import { IconPlus } from '@tabler/icons-react'
import { columns } from './components/balance-details-columns'
import { BalanceDetailsTable } from './components/balance-details-table'
import { BalanceDetailsDialogs } from './components/balance-details-dialogs'
import BalanceDetailsProvider, { useBalanceDetails } from './context/balance-details-context'
import { useBalanceDetailsPage } from './data/balance-details-service'
import type { BalanceDetailQuery } from './data/schema'

function BalanceDetailsContent() {
    const { setOpen } = useBalanceDetails()

    // 分页和查询状态
    const [queryParams] = useState<BalanceDetailQuery>({
        current: 1,
        size: 10,
    })

    // 获取余额明细数据
    const { data, isLoading, error } = useBalanceDetailsPage(queryParams)

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
                        <h2 className='text-2xl font-bold tracking-tight'>余额明细管理</h2>
                        <p className='text-muted-foreground'>
                            管理用户余额变动记录和交易明细
                        </p>
                    </div>
                    <div className='flex gap-2'>
                        <Button className='space-x-1' onClick={() => setOpen('add')}>
                            <span>添加明细</span> <IconPlus size={18} />
                        </Button>
                    </div>
                </div>

                <div className='-mx-4 flex-1 overflow-auto px-4 py-1 lg:flex-row lg:space-y-0 lg:space-x-12'>
                    {isLoading ? (
                        <div className='flex h-32 items-center justify-center'>
                            <div className='animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900'></div>
                            <span className='ml-2'>加载中...</span>
                        </div>
                    ) : error ? (
                        <div className='flex h-32 items-center justify-center text-red-500'>
                            加载余额明细数据失败: {error.message}
                        </div>
                    ) : (
                        <BalanceDetailsTable
                            data={data?.records || []}
                            columns={columns}
                        />
                    )}
                </div>
            </Main>

            {/* 对话框 */}
            <BalanceDetailsDialogs />
        </>
    )
}

export default function BalanceDetails() {
    return (
        <BalanceDetailsProvider>
            <BalanceDetailsContent />
        </BalanceDetailsProvider>
    )
} 