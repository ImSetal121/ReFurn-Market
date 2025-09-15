import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu'
import { MoreHorizontal, Plus, Copy, Edit, Trash2, Archive, Building, Package, MapPin, ArrowRight, ArrowLeft } from 'lucide-react'
import { Separator } from '@/components/ui/separator'
import { SidebarTrigger } from '@/components/ui/sidebar'
import { useWarehouseStockPage } from './data/warehouse-stock-service'
import { WarehouseStockProvider, useWarehouseStockContext } from './context/warehouse-stock-context'
import { WarehouseStockActionDialog } from './components/warehouse-stock-action-dialog'
import { WarehouseStockDeleteDialog } from './components/warehouse-stock-delete-dialog'
import type { WarehouseStock } from './data/schema'

// 简化的DataTable组件
function DataTable() {
    const [pageParams, setPageParams] = useState({
        current: 1,
        size: 10,
    })

    const { data, isLoading, error } = useWarehouseStockPage(pageParams)
    const { setSelectedRecord, setIsActionDialogOpen, setIsDeleteDialogOpen, setMode } = useWarehouseStockContext()

    if (isLoading) return <div className="text-center py-4">加载中...</div>
    if (error) return <div className="text-center py-4 text-red-500">加载失败</div>
    if (!data?.records?.length) return <div className="text-center py-4">暂无数据</div>

    const handleEdit = (record: WarehouseStock) => {
        setSelectedRecord(record)
        setMode('edit')
        setIsActionDialogOpen(true)
    }

    const handleDelete = (record: WarehouseStock) => {
        setSelectedRecord(record)
        setIsDeleteDialogOpen(true)
    }

    const handleCopy = (text: string | number | undefined) => {
        if (text) {
            navigator.clipboard.writeText(text.toString())
        }
    }

    // 获取状态信息
    const getStatusInfo = (status: string) => {
        switch (status) {
            case 'IN_STOCK':
                return { text: '库存中', variant: 'default' as const, className: 'bg-green-100 text-green-800 border-green-300' }
            case 'OUT_OF_STOCK':
                return { text: '已出库', variant: 'secondary' as const }
            default:
                return { text: status, variant: 'outline' as const, className: '' }
        }
    }

    // 判断库存是否偏低
    const isLowStock = (quantity: number) => quantity <= 10

    return (
        <div className="space-y-4">
            <div className="rounded-md border">
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead>
                            <tr className="border-b bg-muted/50">
                                <th className="h-12 px-4 text-left align-middle font-medium">ID</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">仓库信息</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">商品ID</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">库存数量</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">库存位置</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">入库信息</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">出库信息</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">状态</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">创建时间</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            {data.records.map((record) => (
                                <tr key={record.id} className="border-b">
                                    <td className="p-4">{record.id}</td>
                                    <td className="p-4">
                                        <div className="flex items-center gap-1">
                                            <Building className="h-3 w-3" />
                                            {record.warehouseId}
                                        </div>
                                    </td>
                                    <td className="p-4">
                                        <div className="flex items-center gap-1">
                                            <Package className="h-3 w-3" />
                                            {record.productId}
                                        </div>
                                    </td>
                                    <td className="p-4">
                                        <div className={`font-medium ${record.stockQuantity && isLowStock(record.stockQuantity) ? 'text-red-600' : ''}`}>
                                            {record.stockQuantity}
                                            {record.stockQuantity && isLowStock(record.stockQuantity) && (
                                                <span className="ml-1 text-xs text-red-500">(库存偏低)</span>
                                            )}
                                        </div>
                                    </td>
                                    <td className="p-4">
                                        {record.stockPosition && (
                                            <div className="flex items-center gap-1">
                                                <MapPin className="h-3 w-3" />
                                                <span className="max-w-[120px] truncate" title={record.stockPosition}>
                                                    {record.stockPosition}
                                                </span>
                                            </div>
                                        )}
                                    </td>
                                    <td className="p-4">
                                        <div className="space-y-1">
                                            {record.warehouseInApplyId && (
                                                <div className="text-xs text-muted-foreground">
                                                    申请ID: {record.warehouseInApplyId}
                                                </div>
                                            )}
                                            {record.warehouseInId && (
                                                <div className="flex items-center gap-1 text-sm">
                                                    <ArrowRight className="h-3 w-3 text-green-600" />
                                                    入库ID: {record.warehouseInId}
                                                </div>
                                            )}
                                            {record.inTime && (
                                                <div className="text-xs text-muted-foreground">
                                                    {new Date(record.inTime).toLocaleString('zh-CN')}
                                                </div>
                                            )}
                                        </div>
                                    </td>
                                    <td className="p-4">
                                        {record.warehouseOutId ? (
                                            <div className="space-y-1">
                                                <div className="flex items-center gap-1 text-sm">
                                                    <ArrowLeft className="h-3 w-3 text-orange-600" />
                                                    出库ID: {record.warehouseOutId}
                                                </div>
                                                {record.outTime && (
                                                    <div className="text-xs text-muted-foreground">
                                                        {new Date(record.outTime).toLocaleString('zh-CN')}
                                                    </div>
                                                )}
                                            </div>
                                        ) : (
                                            <span className="text-xs text-muted-foreground">未出库</span>
                                        )}
                                    </td>
                                    <td className="p-4">
                                        {record.status && (
                                            <Badge
                                                variant={getStatusInfo(record.status).variant}
                                                className={getStatusInfo(record.status).className}
                                            >
                                                {getStatusInfo(record.status).text}
                                            </Badge>
                                        )}
                                    </td>
                                    <td className="p-4 text-sm text-muted-foreground">
                                        {record.createTime ? new Date(record.createTime).toLocaleString('zh-CN') : ''}
                                    </td>
                                    <td className="p-4">
                                        <DropdownMenu>
                                            <DropdownMenuTrigger asChild>
                                                <Button variant="ghost" className="h-8 w-8 p-0">
                                                    <MoreHorizontal className="h-4 w-4" />
                                                </Button>
                                            </DropdownMenuTrigger>
                                            <DropdownMenuContent align="end">
                                                <DropdownMenuItem onClick={() => handleEdit(record)}>
                                                    <Edit className="mr-2 h-4 w-4" />
                                                    编辑
                                                </DropdownMenuItem>
                                                <DropdownMenuItem onClick={() => handleCopy(record.id)}>
                                                    <Copy className="mr-2 h-4 w-4" />
                                                    复制ID
                                                </DropdownMenuItem>
                                                <DropdownMenuItem onClick={() => handleCopy(record.warehouseInId)}>
                                                    <Copy className="mr-2 h-4 w-4" />
                                                    复制入库ID
                                                </DropdownMenuItem>
                                                <DropdownMenuItem onClick={() => handleCopy(record.warehouseOutId)}>
                                                    <Copy className="mr-2 h-4 w-4" />
                                                    复制出库ID
                                                </DropdownMenuItem>
                                                <DropdownMenuItem
                                                    onClick={() => handleDelete(record)}
                                                    className="text-red-600"
                                                >
                                                    <Trash2 className="mr-2 h-4 w-4" />
                                                    删除
                                                </DropdownMenuItem>
                                            </DropdownMenuContent>
                                        </DropdownMenu>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* 分页 */}
            <div className="flex items-center justify-between">
                <div className="text-sm text-muted-foreground">
                    共 {data.total} 条记录，第 {data.current} / {data.pages} 页
                </div>
                <div className="flex items-center space-x-2">
                    <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setPageParams(prev => ({ ...prev, current: Math.max(1, prev.current - 1) }))}
                        disabled={data.current <= 1}
                    >
                        上一页
                    </Button>
                    <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setPageParams(prev => ({ ...prev, current: prev.current + 1 }))}
                        disabled={data.current >= data.pages}
                    >
                        下一页
                    </Button>
                </div>
            </div>
        </div>
    )
}

// 主页面组件
function WarehouseStockContent() {
    const { setIsActionDialogOpen, setMode, reset } = useWarehouseStockContext()

    const handleAdd = () => {
        reset()
        setMode('add')
        setIsActionDialogOpen(true)
    }

    return (
        <div className="flex flex-1 flex-col gap-4 p-4 pt-0">
            <header className="flex h-16 shrink-0 items-center gap-2">
                <div className="flex items-center gap-2">
                    <SidebarTrigger className="-ml-1" />
                    <Separator orientation="vertical" className="mr-2 h-4" />
                    <div className="text-lg font-medium">仓库库存管理</div>
                </div>
            </header>

            <div className="flex-1 space-y-4">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <Archive className="h-5 w-5" />
                        <h1 className="text-xl font-semibold">仓库库存管理</h1>
                    </div>
                    <Button onClick={handleAdd} className="flex items-center gap-2">
                        <Plus className="h-4 w-4" />
                        新增库存
                    </Button>
                </div>

                <DataTable />
            </div>

            {/* 对话框组件 */}
            <WarehouseStockActionDialog />
            <WarehouseStockDeleteDialog />
        </div>
    )
}

// 导出的主组件
export default function WarehouseStockPage() {
    return (
        <WarehouseStockProvider>
            <WarehouseStockContent />
        </WarehouseStockProvider>
    )
} 