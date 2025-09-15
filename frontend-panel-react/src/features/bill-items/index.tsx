import { useState } from 'react'
import { Header } from '@/components/layout/header'
import { Main } from '@/components/layout/main'
import { ProfileDropdown } from '@/components/profile-dropdown'
import { Search } from '@/components/search'
import { ThemeSwitch } from '@/components/theme-switch'
import { Button } from '@/components/ui/button'
import { IconPlus } from '@tabler/icons-react'
import { columns } from './components/bill-items-columns'
import { BillItemsTable } from './components/bill-items-table'
import { BillItemsDialogs } from './components/bill-items-dialogs'
import BillItemsProvider, { useBillItems } from './context/bill-items-context'
import { useBillItemsPage } from './data/bill-items-service'
import type { BillItemQuery } from './data/schema'

function BillItemsContent() {
    const { setOpen } = useBillItems()

    // 分页和查询状态
    const [queryParams] = useState<BillItemQuery>({
        current: 1,
        size: 10,
    })

    // 获取账单项数据
    const { data, isLoading, error } = useBillItemsPage(queryParams)

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
                        <h2 className='text-2xl font-bold tracking-tight'>账单项管理</h2>
                        <p className='text-muted-foreground'>
                            管理商品销售相关的费用账单和支付记录
                        </p>
                    </div>
                    <div className='flex gap-2'>
                        <Button className='space-x-1' onClick={() => setOpen('add')}>
                            <span>添加账单项</span> <IconPlus size={18} />
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
                            加载账单项数据失败: {error.message}
                        </div>
                    ) : (
                        <BillItemsTable
                            data={data?.records || []}
                            columns={columns}
                        />
                    )}
                </div>
            </Main>

            <BillItemsDialogs />
        </>
    )
}

export default function BillItems() {
    return (
        <BillItemsProvider>
            <BillItemsContent />
        </BillItemsProvider>
    )
} 