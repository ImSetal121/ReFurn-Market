import { Cross2Icon } from '@radix-ui/react-icons'
import { Table } from '@tanstack/react-table'
import { IconTrash } from '@tabler/icons-react'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

import { DataTableViewOptions } from './data-table-view-options'
import { DataTableFacetedFilter } from './data-table-faceted-filter'
import { costTypeOptions, billStatusOptions, paymentOptions } from '../data/schema'
import { useBillItems } from '../context/bill-items-context'
import { useBatchDeleteBillItems } from '../data/bill-items-service'

interface DataTableToolbarProps<TData> {
    table: Table<TData>
}

export function DataTableToolbar<TData>({
    table,
}: DataTableToolbarProps<TData>) {
    const isFiltered = table.getState().columnFilters.length > 0
    const { setOpen, setCurrentRow } = useBillItems()
    const batchDeleteMutation = useBatchDeleteBillItems()

    const selectedRows = table.getFilteredSelectedRowModel().rows
    const hasSelectedRows = selectedRows.length > 0

    const handleBatchDelete = () => {
        const selectedIds = selectedRows.map((row) => (row.original as any).id).filter(Boolean)
        if (selectedIds.length > 0) {
            setCurrentRow({ ids: selectedIds } as any)
            setOpen('delete')
        }
    }

    return (
        <div className='flex flex-wrap items-center justify-between'>
            <div className='flex flex-1 flex-wrap items-center gap-2'>
                <Input
                    placeholder='搜索费用描述...'
                    value={(table.getColumn('costDescription')?.getFilterValue() as string) ?? ''}
                    onChange={(event) =>
                        table.getColumn('costDescription')?.setFilterValue(event.target.value)
                    }
                    className='h-8 w-[150px] lg:w-[250px]'
                />
                <Input
                    placeholder='搜索支付主体...'
                    value={(table.getColumn('paySubject')?.getFilterValue() as string) ?? ''}
                    onChange={(event) =>
                        table.getColumn('paySubject')?.setFilterValue(event.target.value)
                    }
                    className='h-8 w-[150px] lg:w-[200px]'
                />
                <Input
                    placeholder='搜索支付用户...'
                    value={(table.getColumn('payUserName')?.getFilterValue() as string) ?? ''}
                    onChange={(event) =>
                        table.getColumn('payUserName')?.setFilterValue(event.target.value)
                    }
                    className='h-8 w-[150px] lg:w-[200px]'
                />
                {table.getColumn('costType') && (
                    <DataTableFacetedFilter
                        column={table.getColumn('costType')}
                        title='费用类型'
                        options={costTypeOptions}
                    />
                )}
                {table.getColumn('status') && (
                    <DataTableFacetedFilter
                        column={table.getColumn('status')}
                        title='状态'
                        options={billStatusOptions}
                    />
                )}
                {table.getColumn('isPlatformPay') && (
                    <DataTableFacetedFilter
                        column={table.getColumn('isPlatformPay')}
                        title='支付方式'
                        options={paymentOptions}
                    />
                )}
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

            <div className='flex items-center gap-2'>
                {hasSelectedRows && (
                    <Button
                        variant='outline'
                        size='sm'
                        onClick={handleBatchDelete}
                        disabled={batchDeleteMutation.isPending}
                    >
                        <IconTrash className='mr-2 h-4 w-4' />
                        删除选中 ({selectedRows.length})
                    </Button>
                )}
                <DataTableViewOptions table={table} />
            </div>
        </div>
    )
} 