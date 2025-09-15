import { ColumnDef } from '@tanstack/react-table';
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import { Badge } from '@/components/ui/badge';
import { MoreHorizontal, Eye, Edit, Trash2, Gavel } from 'lucide-react';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { DataTableColumnHeader } from './data-table-column-header';
import { useProductReturnRecordContext } from '../context/product-return-record-context';
import type { RfProductReturnRecord } from '@/api/RfProductReturnRecordController';
import { auditResults, freightBearers, compensationBearers, statuses } from '../data/schema';

// 获取状态显示标签
function getStatusLabel(status?: string) {
    return statuses.find(s => s.value === status)?.label || status || '-';
}

// 获取审核结果显示标签
function getAuditResultLabel(result?: string) {
    return auditResults.find(r => r.value === result)?.label || result || '-';
}

// 获取运费承担方显示标签
function getFreightBearerLabel(bearer?: string) {
    return freightBearers.find(b => b.value === bearer)?.label || bearer || '-';
}

// 获取赔偿承担方显示标签
function getCompensationBearerLabel(bearer?: string) {
    return compensationBearers.find(b => b.value === bearer)?.label || bearer || '-';
}

// 格式化时间
function formatDateTime(dateString?: string) {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleString('zh-CN');
}

// 格式化布尔值
function formatBoolean(value?: boolean) {
    if (value === undefined || value === null) return '-';
    return value ? '是' : '否';
}

export function useColumns(): ColumnDef<RfProductReturnRecord>[] {
    const {
        setSelectedRecord,
        setIsEditing,
        setAddEditDialogOpen,
        setDeleteDialogOpen,
        setViewDialogOpen,
        setAuditDialogOpen,
    } = useProductReturnRecordContext();

    return [
        {
            id: 'select',
            header: ({ table }) => (
                <Checkbox
                    checked={
                        table.getIsAllPageRowsSelected() ||
                        (table.getIsSomePageRowsSelected() && 'indeterminate')
                    }
                    onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
                    aria-label="全选"
                />
            ),
            cell: ({ row }) => (
                <Checkbox
                    checked={row.getIsSelected()}
                    onCheckedChange={(value) => row.toggleSelected(!!value)}
                    aria-label="选择行"
                />
            ),
            enableSorting: false,
            enableHiding: false,
        },
        {
            accessorKey: 'id',
            header: ({ column }) => <DataTableColumnHeader column={column} title="ID" />,
            cell: ({ row }) => <span className="font-mono text-xs">{row.getValue('id') || '-'}</span>,
        },
        {
            accessorKey: 'productId',
            header: ({ column }) => <DataTableColumnHeader column={column} title="商品ID" />,
            cell: ({ row }) => <span className="font-mono text-xs">{row.getValue('productId') || '-'}</span>,
        },
        {
            accessorKey: 'productSellRecordId',
            header: ({ column }) => <DataTableColumnHeader column={column} title="销售记录ID" />,
            cell: ({ row }) => <span className="font-mono text-xs">{row.getValue('productSellRecordId') || '-'}</span>,
        },
        {
            accessorKey: 'returnReasonType',
            header: ({ column }) => <DataTableColumnHeader column={column} title="退货原因类型" />,
            cell: ({ row }) => <span>{row.getValue('returnReasonType') || '-'}</span>,
        },
        {
            accessorKey: 'returnReasonDetail',
            header: ({ column }) => <DataTableColumnHeader column={column} title="退货原因详情" />,
            cell: ({ row }) => {
                const detail = row.getValue('returnReasonDetail') as string;
                return (
                    <span className="max-w-32 truncate" title={detail}>
                        {detail || '-'}
                    </span>
                );
            },
        },
        {
            accessorKey: 'pickupAddress',
            header: ({ column }) => <DataTableColumnHeader column={column} title="取件地址" />,
            cell: ({ row }) => {
                const address = row.getValue('pickupAddress') as string;
                return (
                    <span className="max-w-32 truncate" title={address}>
                        {address || '-'}
                    </span>
                );
            },
        },
        {
            accessorKey: 'sellerAcceptReturn',
            header: ({ column }) => <DataTableColumnHeader column={column} title="卖家是否接受退货" />,
            cell: ({ row }) => {
                const accept = row.getValue('sellerAcceptReturn') as boolean;
                return (
                    <Badge variant={accept ? 'default' : accept === false ? 'destructive' : 'secondary'}>
                        {formatBoolean(accept)}
                    </Badge>
                );
            },
        },
        {
            accessorKey: 'sellerOpinionDetail',
            header: ({ column }) => <DataTableColumnHeader column={column} title="卖家意见详情" />,
            cell: ({ row }) => {
                const detail = row.getValue('sellerOpinionDetail') as string;
                return (
                    <span className="max-w-32 truncate" title={detail}>
                        {detail || '-'}
                    </span>
                );
            },
        },
        {
            accessorKey: 'auditResult',
            header: ({ column }) => <DataTableColumnHeader column={column} title="审核结果" />,
            cell: ({ row }) => {
                const result = row.getValue('auditResult') as string;
                return (
                    <Badge variant={result === 'APPROVED' ? 'default' : result === 'REJECTED' ? 'destructive' : 'secondary'}>
                        {getAuditResultLabel(result)}
                    </Badge>
                );
            },
        },
        {
            accessorKey: 'auditDetail',
            header: ({ column }) => <DataTableColumnHeader column={column} title="审核详情" />,
            cell: ({ row }) => {
                const detail = row.getValue('auditDetail') as string;
                return (
                    <span className="max-w-32 truncate" title={detail}>
                        {detail || '-'}
                    </span>
                );
            },
        },
        {
            accessorKey: 'freightBearer',
            header: ({ column }) => <DataTableColumnHeader column={column} title="运费承担方" />,
            cell: ({ row }) => {
                const bearer = row.getValue('freightBearer') as string;
                return <Badge variant="outline">{getFreightBearerLabel(bearer)}</Badge>;
            },
        },
        {
            accessorKey: 'freightBearerUserId',
            header: ({ column }) => <DataTableColumnHeader column={column} title="运费承担用户ID" />,
            cell: ({ row }) => <span className="font-mono text-xs">{row.getValue('freightBearerUserId') || '-'}</span>,
        },
        {
            accessorKey: 'needCompensateProduct',
            header: ({ column }) => <DataTableColumnHeader column={column} title="需要赔偿商品" />,
            cell: ({ row }) => {
                const need = row.getValue('needCompensateProduct') as boolean;
                return (
                    <Badge variant={need ? 'destructive' : 'secondary'}>
                        {formatBoolean(need)}
                    </Badge>
                );
            },
        },
        {
            accessorKey: 'compensationBearer',
            header: ({ column }) => <DataTableColumnHeader column={column} title="赔偿承担方" />,
            cell: ({ row }) => {
                const bearer = row.getValue('compensationBearer') as string;
                return <Badge variant="outline">{getCompensationBearerLabel(bearer)}</Badge>;
            },
        },
        {
            accessorKey: 'compensationBearerUserId',
            header: ({ column }) => <DataTableColumnHeader column={column} title="赔偿承担用户ID" />,
            cell: ({ row }) => <span className="font-mono text-xs">{row.getValue('compensationBearerUserId') || '-'}</span>,
        },
        {
            accessorKey: 'isAuction',
            header: ({ column }) => <DataTableColumnHeader column={column} title="是否寄卖" />,
            cell: ({ row }) => {
                const isAuction = row.getValue('isAuction') as boolean;
                return (
                    <Badge variant={isAuction ? 'default' : 'secondary'}>
                        {formatBoolean(isAuction)}
                    </Badge>
                );
            },
        },
        {
            accessorKey: 'isUseLogisticsService',
            header: ({ column }) => <DataTableColumnHeader column={column} title="使用物流服务" />,
            cell: ({ row }) => {
                const isUse = row.getValue('isUseLogisticsService') as boolean;
                return (
                    <Badge variant={isUse ? 'default' : 'secondary'}>
                        {formatBoolean(isUse)}
                    </Badge>
                );
            },
        },
        {
            accessorKey: 'appointmentPickupTime',
            header: ({ column }) => <DataTableColumnHeader column={column} title="预约取件时间" />,
            cell: ({ row }) => (
                <span className="text-xs">{formatDateTime(row.getValue('appointmentPickupTime'))}</span>
            ),
        },
        {
            accessorKey: 'internalLogisticsTaskId',
            header: ({ column }) => <DataTableColumnHeader column={column} title="内部物流任务ID" />,
            cell: ({ row }) => <span className="font-mono text-xs">{row.getValue('internalLogisticsTaskId') || '-'}</span>,
        },
        {
            accessorKey: 'externalLogisticsServiceName',
            header: ({ column }) => <DataTableColumnHeader column={column} title="外部物流服务商" />,
            cell: ({ row }) => {
                const name = row.getValue('externalLogisticsServiceName') as string;
                return (
                    <span className="max-w-24 truncate" title={name}>
                        {name || '-'}
                    </span>
                );
            },
        },
        {
            accessorKey: 'externalLogisticsOrderNumber',
            header: ({ column }) => <DataTableColumnHeader column={column} title="外部物流单号" />,
            cell: ({ row }) => {
                const orderNumber = row.getValue('externalLogisticsOrderNumber') as string;
                return (
                    <span className="font-mono text-xs max-w-24 truncate" title={orderNumber}>
                        {orderNumber || '-'}
                    </span>
                );
            },
        },
        {
            accessorKey: 'status',
            header: ({ column }) => <DataTableColumnHeader column={column} title="状态" />,
            cell: ({ row }) => {
                const status = row.getValue('status') as string;
                const getStatusVariant = (status: string) => {
                    switch (status) {
                        case 'RETURN_INITIATED':
                            return 'default';
                        case 'RETURN_NEGOTIATION_FAILED':
                            return 'destructive';
                        case 'RETURNED_TO_WAREHOUSE':
                            return 'secondary';
                        case 'RETURNED_TO_SELLER':
                            return 'outline';
                        case 'RETURN_COMPLETED':
                            return 'secondary';
                        default:
                            return 'secondary';
                    }
                };
                return (
                    <Badge variant={getStatusVariant(status)}>
                        {getStatusLabel(status)}
                    </Badge>
                );
            },
        },
        {
            accessorKey: 'createTime',
            header: ({ column }) => <DataTableColumnHeader column={column} title="创建时间" />,
            cell: ({ row }) => (
                <span className="text-xs">{formatDateTime(row.getValue('createTime'))}</span>
            ),
        },
        {
            accessorKey: 'updateTime',
            header: ({ column }) => <DataTableColumnHeader column={column} title="更新时间" />,
            cell: ({ row }) => (
                <span className="text-xs">{formatDateTime(row.getValue('updateTime'))}</span>
            ),
        },
        {
            accessorKey: 'isDelete',
            header: ({ column }) => <DataTableColumnHeader column={column} title="是否删除" />,
            cell: ({ row }) => {
                const isDeleted = row.getValue('isDelete') as boolean;
                return (
                    <Badge variant={isDeleted ? 'destructive' : 'secondary'}>
                        {formatBoolean(isDeleted)}
                    </Badge>
                );
            },
        },
        {
            id: 'actions',
            header: '操作',
            cell: ({ row }) => {
                const record = row.original;

                return (
                    <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                                <span className="sr-only">打开菜单</span>
                                <MoreHorizontal className="h-4 w-4" />
                            </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                            <DropdownMenuItem
                                onClick={() => {
                                    setSelectedRecord(record);
                                    setViewDialogOpen(true);
                                }}
                            >
                                <Eye className="mr-2 h-4 w-4" />
                                查看
                            </DropdownMenuItem>
                            {record.status === 'RETURN_NEGOTIATION_FAILED' && (
                                <DropdownMenuItem
                                    onClick={() => {
                                        setSelectedRecord(record);
                                        setAuditDialogOpen(true);
                                    }}
                                >
                                    <Gavel className="mr-2 h-4 w-4" />
                                    审核退货
                                </DropdownMenuItem>
                            )}
                            <DropdownMenuItem
                                onClick={() => {
                                    setSelectedRecord(record);
                                    setIsEditing(true);
                                    setAddEditDialogOpen(true);
                                }}
                            >
                                <Edit className="mr-2 h-4 w-4" />
                                编辑
                            </DropdownMenuItem>
                            <DropdownMenuItem
                                onClick={() => {
                                    setSelectedRecord(record);
                                    setDeleteDialogOpen(true);
                                }}
                                className="text-red-600"
                            >
                                <Trash2 className="mr-2 h-4 w-4" />
                                删除
                            </DropdownMenuItem>
                        </DropdownMenuContent>
                    </DropdownMenu>
                );
            },
        },
    ];
} 