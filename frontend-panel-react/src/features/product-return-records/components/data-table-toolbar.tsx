import { Cross2Icon } from '@radix-ui/react-icons';
import { Table } from '@tanstack/react-table';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { DataTableViewOptions } from './data-table-view-options';
import { DataTableFacetedFilter } from './data-table-faceted-filter';

import { auditResults, freightBearers, compensationBearers, statuses, deleteStatuses, booleanOptions } from '../data/schema';

interface DataTableToolbarProps<TData> {
    table: Table<TData>;
    onSearchChange?: (value: string) => void;
}

export function DataTableToolbar<TData>({
    table,
    onSearchChange,
}: DataTableToolbarProps<TData>) {
    const isFiltered = table.getState().columnFilters.length > 0;

    const handleSearchChange = (value: string) => {
        onSearchChange?.(value);
    };

    return (
        <div className="flex items-center justify-between">
            <div className="flex flex-1 flex-col space-y-2 sm:flex-row sm:items-center sm:space-x-2 sm:space-y-0">
                <div className="flex space-x-2">
                    <Input
                        placeholder="搜索ID..."
                        value={(table.getColumn('id')?.getFilterValue() as string) ?? ''}
                        onChange={(event) => {
                            table.getColumn('id')?.setFilterValue(event.target.value);
                            handleSearchChange(event.target.value);
                        }}
                        className="h-8 w-[150px] lg:w-[250px]"
                    />
                    <Input
                        placeholder="搜索商品ID..."
                        value={(table.getColumn('productId')?.getFilterValue() as string) ?? ''}
                        onChange={(event) => {
                            table.getColumn('productId')?.setFilterValue(event.target.value);
                            handleSearchChange(event.target.value);
                        }}
                        className="h-8 w-[150px] lg:w-[200px]"
                    />
                    <Input
                        placeholder="搜索销售记录ID..."
                        value={(table.getColumn('productSellRecordId')?.getFilterValue() as string) ?? ''}
                        onChange={(event) => {
                            table.getColumn('productSellRecordId')?.setFilterValue(event.target.value);
                            handleSearchChange(event.target.value);
                        }}
                        className="h-8 w-[150px] lg:w-[200px]"
                    />
                </div>
                <div className="flex space-x-2">
                    {table.getColumn('status') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('status')}
                            title="状态"
                            options={statuses}
                        />
                    )}
                    {table.getColumn('auditResult') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('auditResult')}
                            title="审核结果"
                            options={auditResults}
                        />
                    )}
                    {table.getColumn('freightBearer') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('freightBearer')}
                            title="运费承担方"
                            options={freightBearers}
                        />
                    )}
                    {table.getColumn('compensationBearer') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('compensationBearer')}
                            title="赔偿承担方"
                            options={compensationBearers}
                        />
                    )}
                    {table.getColumn('isAuction') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('isAuction')}
                            title="是否寄卖"
                            options={booleanOptions.map(option => ({
                                label: option.label,
                                value: option.value.toString(),
                            }))}
                        />
                    )}
                    {table.getColumn('isUseLogisticsService') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('isUseLogisticsService')}
                            title="使用物流服务"
                            options={booleanOptions.map(option => ({
                                label: option.label,
                                value: option.value.toString(),
                            }))}
                        />
                    )}
                    {table.getColumn('sellerAcceptReturn') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('sellerAcceptReturn')}
                            title="卖家接受退货"
                            options={booleanOptions.map(option => ({
                                label: option.label,
                                value: option.value.toString(),
                            }))}
                        />
                    )}
                    {table.getColumn('isDelete') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('isDelete')}
                            title="删除状态"
                            options={deleteStatuses.map(option => ({
                                label: option.label,
                                value: option.value.toString(),
                            }))}
                        />
                    )}
                    {isFiltered && (
                        <Button
                            variant="ghost"
                            onClick={() => table.resetColumnFilters()}
                            className="h-8 px-2 lg:px-3"
                        >
                            重置
                            <Cross2Icon className="ml-2 h-4 w-4" />
                        </Button>
                    )}
                </div>
            </div>
            <DataTableViewOptions table={table} />
        </div>
    );
} 