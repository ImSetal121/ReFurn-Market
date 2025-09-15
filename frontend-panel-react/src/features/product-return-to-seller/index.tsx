import { useState } from 'react';
import { Header } from '@/components/layout/header';
import { Main } from '@/components/layout/main';
import { Search } from '@/components/search';
import { ThemeSwitch } from '@/components/theme-switch';
import { ProfileDropdown } from '@/components/profile-dropdown';
import { ProductReturnToSellerProvider } from './context/product-return-to-seller-context';
import { ProductReturnToSellerPrimaryButtons } from './components/primary-buttons';
import { ProductReturnToSellerTable } from './components/table';
import { AddEditDialog } from './components/add-edit-dialog';
import { DeleteDialog } from './components/delete-dialog';
import { ViewDialog } from './components/view-dialog';
import { useProductReturnToSellerRecords } from './data/product-return-to-seller-service';
import type { RfProductReturnToSellerPageParams } from '@/api/RfProductReturnToSellerController';

export default function ProductReturnToSellerPage() {
    const [pageParams, setPageParams] = useState<RfProductReturnToSellerPageParams>({
        current: 1,
        size: 10,
    });

    const { data, isLoading, error } = useProductReturnToSellerRecords(pageParams);

    const handlePageChange = (page: number) => {
        setPageParams(prev => ({
            ...prev,
            current: page,
        }));
    };

    const handlePageSizeChange = (pageSize: number) => {
        setPageParams(prev => ({
            ...prev,
            size: pageSize,
            current: 1,
        }));
    };

    return (
        <ProductReturnToSellerProvider>
            <Header>
                <Search />
                <ThemeSwitch />
                <ProfileDropdown />
            </Header>
            <Main>
                <div className="mb-2 flex items-center justify-between space-y-2">
                    <div>
                        <h2 className="text-2xl font-bold tracking-tight">商品退回卖家记录</h2>
                        <p className="text-muted-foreground">
                            管理商品退回卖家的记录信息
                        </p>
                    </div>
                    <ProductReturnToSellerPrimaryButtons />
                </div>
                <div className="space-y-4">
                    <ProductReturnToSellerTable
                        data={data?.records || []}
                        loading={isLoading}
                        error={error}
                        totalItems={data?.total || 0}
                        currentPage={pageParams.current || 1}
                        pageSize={pageParams.size || 10}
                        onPageChange={handlePageChange}
                        onPageSizeChange={handlePageSizeChange}
                    />
                </div>
            </Main>

            {/* 对话框组件 */}
            <AddEditDialog />
            <DeleteDialog />
            <ViewDialog />
        </ProductReturnToSellerProvider>
    );
} 