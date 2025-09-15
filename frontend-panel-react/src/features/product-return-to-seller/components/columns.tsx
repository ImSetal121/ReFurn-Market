import { ColumnDef } from '@tanstack/react-table';
import { Checkbox } from '@/components/ui/checkbox';
import { Badge } from '@/components/ui/badge';
import { DataTableColumnHeader } from './data-table-column-header';
import { DataTableRowActions } from './data-table-row-actions';
import type { RfProductReturnToSeller } from '@/api/RfProductReturnToSellerController';
import { statuses } from '../data/schema';

export const columns: ColumnDef<RfProductReturnToSeller>[] = [
    {
        id: 'select',
        header: ({ table }) => (
            <Checkbox
                checked={table.getIsAllPageRowsSelected()}
                onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
                aria-label="Select all"
                className="translate-y-[2px]"
            />
        ),
        cell: ({ row }) => (
            <Checkbox
                checked={row.getIsSelected()}
                onCheckedChange={(value) => row.toggleSelected(!!value)}
                aria-label="Select row"
                className="translate-y-[2px]"
            />
        ),
        enableSorting: false,
        enableHiding: false,
    },
    {
        accessorKey: 'id',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="ID" />
        ),
        cell: ({ row }) => <div className="w-[80px]">{row.getValue('id')}</div>,
        enableSorting: false,
        enableHiding: false,
    },
    {
        accessorKey: 'productId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="商品ID" />
        ),
        cell: ({ row }) => {
            const productId = row.getValue('productId') as number;
            return <div className="w-[100px]">{productId || '-'}</div>;
        },
    },
    {
        accessorKey: 'productSellRecordId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="销售记录ID" />
        ),
        cell: ({ row }) => {
            const recordId = row.getValue('productSellRecordId') as number;
            return <div className="w-[120px]">{recordId || '-'}</div>;
        },
    },
    {
        accessorKey: 'warehouseId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="仓库ID" />
        ),
        cell: ({ row }) => {
            const warehouseId = row.getValue('warehouseId') as number;
            return <div className="w-[100px]">{warehouseId || '-'}</div>;
        },
    },
    {
        accessorKey: 'warehouseAddress',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="仓库地址" />
        ),
        cell: ({ row }) => {
            const address = row.getValue('warehouseAddress') as string;
            return (
                <div className="max-w-[200px] truncate" title={address}>
                    {address || '-'}
                </div>
            );
        },
    },
    {
        accessorKey: 'sellerReceiptAddress',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="卖家收货地址" />
        ),
        cell: ({ row }) => {
            const address = row.getValue('sellerReceiptAddress') as string;
            return (
                <div className="max-w-[200px] truncate" title={address}>
                    {address || '-'}
                </div>
            );
        },
    },
    {
        accessorKey: 'internalLogisticsTaskId',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="物流任务ID" />
        ),
        cell: ({ row }) => {
            const taskId = row.getValue('internalLogisticsTaskId') as number;
            return <div className="w-[120px]">{taskId || '-'}</div>;
        },
    },
    {
        accessorKey: 'shipmentTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="发货时间" />
        ),
        cell: ({ row }) => {
            const time = row.getValue('shipmentTime') as string;
            return (
                <div className="w-[140px]">
                    {time ? new Date(time).toLocaleString('zh-CN') : '-'}
                </div>
            );
        },
    },
    {
        accessorKey: 'status',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="状态" />
        ),
        cell: ({ row }) => {
            const status = row.getValue('status') as string;
            const statusInfo = statuses.find((s) => s.value === status);

            if (!status) return <div className="w-[100px]">-</div>;

            return (
                <div className="w-[100px]">
                    <Badge variant="outline">
                        {statusInfo?.label || status}
                    </Badge>
                </div>
            );
        },
        filterFn: (row, id, value) => {
            return value.includes(row.getValue(id));
        },
    },
    {
        accessorKey: 'createTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="创建时间" />
        ),
        cell: ({ row }) => {
            const time = row.getValue('createTime') as string;
            return (
                <div className="w-[140px]">
                    {time ? new Date(time).toLocaleString('zh-CN') : '-'}
                </div>
            );
        },
    },
    {
        accessorKey: 'updateTime',
        header: ({ column }) => (
            <DataTableColumnHeader column={column} title="更新时间" />
        ),
        cell: ({ row }) => {
            const time = row.getValue('updateTime') as string;
            return (
                <div className="w-[140px]">
                    {time ? new Date(time).toLocaleString('zh-CN') : '-'}
                </div>
            );
        },
    },
    {
        id: 'actions',
        cell: ({ row }) => <DataTableRowActions row={row} />,
    },
]; 