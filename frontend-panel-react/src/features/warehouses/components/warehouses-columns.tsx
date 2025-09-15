import { ColumnDef } from '@tanstack/react-table'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { MoreHorizontal, Edit, Trash2 } from 'lucide-react'
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import type { RfWarehouse } from '@/api/RfWarehouseController'
import { useWarehousesContext } from '../context/warehouses-context'
import { AddressButton } from './AddressButton'

export const columns: ColumnDef<RfWarehouse>[] = [
    {
        accessorKey: 'id',
        header: 'ID',
        cell: ({ row }) => <div className='w-20'>{row.getValue('id')}</div>,
    },
    {
        accessorKey: 'name',
        header: '仓库名称',
        cell: ({ row }) => <div className='font-medium'>{row.getValue('name')}</div>,
    },
    {
        accessorKey: 'address',
        header: '仓库地址',
        cell: ({ row }) => (
            <AddressButton
                address={row.getValue('address')}
                warehouseName={row.getValue('name')}
            />
        ),
    },
    {
        accessorKey: 'monthlyWarehouseCost',
        header: '月仓储费用(元)',
        cell: ({ row }) => {
            const cost = row.getValue('monthlyWarehouseCost') as number
            return <div className='text-right font-mono'>¥{cost?.toFixed(2) || '0.00'}</div>
        },
    },
    {
        accessorKey: 'status',
        header: '状态',
        cell: ({ row }) => {
            const status = row.getValue('status') as string
            return (
                <Badge variant={status === 'ENABLED' ? 'default' : 'secondary'}>
                    {status === 'ENABLED' ? '启用' : '停用'}
                </Badge>
            )
        },
    },
    {
        accessorKey: 'createTime',
        header: '创建时间',
        cell: ({ row }) => {
            const createTime = row.getValue('createTime') as string
            return createTime ? new Date(createTime).toLocaleString() : '-'
        },
    },
    {
        id: 'actions',
        header: '操作',
        cell: ({ row }) => {
            const warehouse = row.original
            // eslint-disable-next-line react-hooks/rules-of-hooks
            const { openUpdateDialog, openDeleteDialog } = useWarehousesContext()

            return (
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button variant='ghost' className='h-8 w-8 p-0'>
                            <span className='sr-only'>打开菜单</span>
                            <MoreHorizontal className='h-4 w-4' />
                        </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align='end'>
                        <DropdownMenuItem
                            onClick={() => openUpdateDialog(warehouse)}
                            className='cursor-pointer'
                        >
                            <Edit className='mr-2 h-4 w-4' />
                            编辑
                        </DropdownMenuItem>
                        <DropdownMenuItem
                            onClick={() => openDeleteDialog(warehouse)}
                            className='cursor-pointer text-red-600'
                        >
                            <Trash2 className='mr-2 h-4 w-4' />
                            删除
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            )
        },
    },
] 