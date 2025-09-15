import { useState, useMemo } from 'react';
import { Header } from '@/components/layout/header';
import { Main } from '@/components/layout/main';
import { ProfileDropdown } from '@/components/profile-dropdown';
import { Search } from '@/components/search';
import { ThemeSwitch } from '@/components/theme-switch';
import { DataTable } from './components/table';
import { useColumns } from './components/columns';
import { AddEditDialog } from './components/add-edit-dialog';
import { DeleteDialog } from './components/delete-dialog';
import { ViewDialog } from './components/view-dialog';
import { AuditDialog } from './components/audit-dialog';
import { ProductReturnRecordsPrimaryButtons } from './components/primary-buttons';
import { ProductReturnRecordProvider } from './context/product-return-record-context';
import { useProductReturnRecords } from './data/product-return-record-service';
import type { RfProductReturnRecordPageParams } from '@/api/RfProductReturnRecordController';

function ProductReturnRecordPageContent() {
    const [params, setParams] = useState<RfProductReturnRecordPageParams>({
        current: 1,
        size: 10,
    });

    const { data, isLoading, error } = useProductReturnRecords(params);
    const columns = useColumns();

    const handlePageChange = (page: number) => {
        setParams(prev => ({ ...prev, current: page }));
    };

    const handlePageSizeChange = (pageSize: number) => {
        setParams(prev => ({ ...prev, size: pageSize, current: 1 }));
    };

    const handleSearchChange = (_value: string) => {
        // 搜索功能由表格内部的列过滤器处理
        // 这里可以添加额外的搜索逻辑
    };

    const handleFiltersChange = (filters: Record<string, unknown>) => {
        // 更新查询参数
        setParams(prev => ({ ...prev, ...filters, current: 1 }));
    };

    const tableData = useMemo(() => data?.records || [], [data?.records]);

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
                        <h2 className='text-2xl font-bold tracking-tight'>商品退货记录</h2>
                        <p className='text-muted-foreground'>
                            管理商品退货记录，包括退货原因、审核结果、物流信息等
                        </p>
                    </div>
                    <ProductReturnRecordsPrimaryButtons />
                </div>

                <div className='-mx-4 flex-1 overflow-auto px-4 py-1 lg:flex-row lg:space-y-0 lg:space-x-12'>
                    {isLoading ? (
                        <div className='flex h-32 items-center justify-center'>
                            加载中...
                        </div>
                    ) : error ? (
                        <div className='flex h-32 items-center justify-center text-red-500'>
                            加载退货记录数据失败: {error.message}
                        </div>
                    ) : (
                        <DataTable
                            columns={columns}
                            data={tableData}
                            totalCount={data?.total}
                            onPageChange={handlePageChange}
                            onPageSizeChange={handlePageSizeChange}
                            onSearchChange={handleSearchChange}
                            onFiltersChange={handleFiltersChange}
                        />
                    )}
                </div>
            </Main>

            <AddEditDialog />
            <DeleteDialog />
            <ViewDialog />
            <AuditDialog />
        </>
    );
}

export default function ProductReturnRecordPage() {
    return (
        <ProductReturnRecordProvider>
            <ProductReturnRecordPageContent />
        </ProductReturnRecordProvider>
    );
} 