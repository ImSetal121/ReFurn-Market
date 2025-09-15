import { Cross2Icon } from '@radix-ui/react-icons'
import { Table } from '@tanstack/react-table'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { DataTableFacetedFilter } from './data-table-faceted-filter'
import { DataTableViewOptions } from './data-table-view-options'
import { statusOptions, auctionTypeOptions, pickupTypeOptions, deleteStatusOptions } from '../data/schema'

interface DataTableToolbarProps<TData> {
    table: Table<TData>
}

export function DataTableToolbar<TData>({
    table,
}: DataTableToolbarProps<TData>) {
    const isFiltered = table.getState().columnFilters.length > 0

    return (
        <div className='flex items-center justify-between'>
            <div className='flex flex-1 flex-col-reverse items-start gap-y-2 sm:flex-row sm:items-center sm:space-x-2'>
                <div className='flex flex-wrap gap-2'>
                    <Input
                        placeholder='搜索商品ID...'
                        value={
                            (table.getColumn('productId')?.getFilterValue() as string) ?? ''
                        }
                        onChange={(event) =>
                            table.getColumn('productId')?.setFilterValue(event.target.value)
                        }
                        className='h-8 w-[120px] lg:w-[150px]'
                    />
                    <Input
                        placeholder='搜索卖家ID...'
                        value={
                            (table.getColumn('sellerUserId')?.getFilterValue() as string) ?? ''
                        }
                        onChange={(event) =>
                            table.getColumn('sellerUserId')?.setFilterValue(event.target.value)
                        }
                        className='h-8 w-[120px] lg:w-[150px]'
                    />
                    <Input
                        placeholder='搜索买家ID...'
                        value={
                            (table.getColumn('buyerUserId')?.getFilterValue() as string) ?? ''
                        }
                        onChange={(event) =>
                            table.getColumn('buyerUserId')?.setFilterValue(event.target.value)
                        }
                        className='h-8 w-[120px] lg:w-[150px]'
                    />
                    <Input
                        placeholder='搜索价格...'
                        value={
                            (table.getColumn('finalProductPrice')?.getFilterValue() as string) ?? ''
                        }
                        onChange={(event) =>
                            table.getColumn('finalProductPrice')?.setFilterValue(event.target.value)
                        }
                        className='h-8 w-[120px] lg:w-[150px]'
                    />
                </div>
                <div className='flex gap-x-2'>
                    {table.getColumn('status') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('status')}
                            title='状态'
                            options={statusOptions}
                        />
                    )}
                    {table.getColumn('isAuction') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('isAuction')}
                            title='交易类型'
                            options={auctionTypeOptions}
                        />
                    )}
                    {table.getColumn('isSelfPickup') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('isSelfPickup')}
                            title='配送方式'
                            options={pickupTypeOptions}
                        />
                    )}
                    {table.getColumn('isDelete') && (
                        <DataTableFacetedFilter
                            column={table.getColumn('isDelete')}
                            title='删除状态'
                            options={deleteStatusOptions}
                        />
                    )}
                </div>
                {isFiltered && (
                    <Button
                        variant='ghost'
                        onClick={() => table.resetColumnFilters()}
                        className='h-8 px-2 lg:px-3'
                    >
                        重置
                        <Cross2Icon className='ml-2 h-4 w-4' />
                    </Button>
                )}
            </div>
            <DataTableViewOptions table={table} />
        </div>
    )
} 