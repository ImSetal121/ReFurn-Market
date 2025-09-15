import { Cross2Icon } from '@radix-ui/react-icons'
import { Table } from '@tanstack/react-table'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { DataTableFacetedFilter } from './data-table-faceted-filter'
import { DataTableViewOptions } from './data-table-view-options'

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
            placeholder='搜索用户名...'
            value={
              (table.getColumn('username')?.getFilterValue() as string) ?? ''
            }
            onChange={(event) =>
              table.getColumn('username')?.setFilterValue(event.target.value)
            }
            className='h-8 w-[120px] lg:w-[150px]'
          />
          <Input
            placeholder='搜索昵称...'
            value={
              (table.getColumn('nickname')?.getFilterValue() as string) ?? ''
            }
            onChange={(event) =>
              table.getColumn('nickname')?.setFilterValue(event.target.value)
            }
            className='h-8 w-[120px] lg:w-[150px]'
          />
          <Input
            placeholder='搜索邮箱...'
            value={
              (table.getColumn('email')?.getFilterValue() as string) ?? ''
            }
            onChange={(event) =>
              table.getColumn('email')?.setFilterValue(event.target.value)
            }
            className='h-8 w-[120px] lg:w-[150px]'
          />
          <Input
            placeholder='搜索手机号...'
            value={
              (table.getColumn('phoneNumber')?.getFilterValue() as string) ?? ''
            }
            onChange={(event) =>
              table.getColumn('phoneNumber')?.setFilterValue(event.target.value)
            }
            className='h-8 w-[120px] lg:w-[150px]'
          />
        </div>
        <div className='flex gap-x-2'>
          {table.getColumn('status') && (
            <DataTableFacetedFilter
              column={table.getColumn('status')}
              title='状态'
              options={[
                { label: '正常', value: 'active' },
                { label: '已删除', value: 'inactive' },
                { label: '暂停', value: 'suspended' },
              ]}
            />
          )}
          {table.getColumn('sex') && (
            <DataTableFacetedFilter
              column={table.getColumn('sex')}
              title='性别'
              options={[
                { label: '男', value: 'M' },
                { label: '女', value: 'F' },
                { label: '未设置', value: 'unset' },
              ]}
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
