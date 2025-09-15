import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu'
import { MoreHorizontal, Plus, Copy, Edit, Trash2, Package, Building, Truck } from 'lucide-react'
// import { Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbPage, BreadcrumbSeparator } from '@/components/ui/breadcrumb'
import { Separator } from '@/components/ui/separator'
import { SidebarTrigger } from '@/components/ui/sidebar'
import { useProductAuctionLogisticsPage } from './data/product-auction-logistics-service'
import { ProductAuctionLogisticsProvider, useProductAuctionLogisticsContext } from './context/product-auction-logistics-context'
import { ProductAuctionLogisticsActionDialog } from './components/product-auction-logistics-action-dialog'
import { ProductAuctionLogisticsDeleteDialog } from './components/product-auction-logistics-delete-dialog'
import type { ProductAuctionLogistics } from './data/schema'

// 简化的DataTable组件
function DataTable() {
    const [pageParams, setPageParams] = useState({
        current: 1,
        size: 10,
    })

    const { data, isLoading, error } = useProductAuctionLogisticsPage(pageParams)
    const { setSelectedRecord, setIsActionDialogOpen, setIsDeleteDialogOpen, setMode } = useProductAuctionLogisticsContext()

    if (isLoading) return <div className="text-center py-4">加载中...</div>
    if (error) return <div className="text-center py-4 text-red-500">加载失败</div>
    if (!data?.records?.length) return <div className="text-center py-4">暂无数据</div>

    const handleEdit = (record: ProductAuctionLogistics) => {
        setSelectedRecord(record)
        setMode('edit')
        setIsActionDialogOpen(true)
    }

    const handleDelete = (record: ProductAuctionLogistics) => {
        setSelectedRecord(record)
        setIsDeleteDialogOpen(true)
    }

    const handleCopy = (text: string | undefined) => {
        if (text) {
            navigator.clipboard.writeText(text.toString())
        }
    }

    return (
        <div className="space-y-4">
            <div className="rounded-md border">
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead>
                            <tr className="border-b bg-muted/50">
                                <th className="h-12 px-4 text-left align-middle font-medium">ID</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">商品ID</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">销售记录ID</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">取货地址</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">仓库</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">使用物流服务</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">预约取货日期</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">外部物流</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">状态</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">创建时间</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            {data.records.map((record) => (
                                <tr key={record.id} className="border-b">
                                    <td className="p-4">{record.id}</td>
                                    <td className="p-4">{record.productId}</td>
                                    <td className="p-4">{record.productSellRecordId}</td>
                                    <td className="p-4 max-w-[200px] truncate" title={record.pickupAddress}>
                                        {record.pickupAddress}
                                    </td>
                                    <td className="p-4">
                                        <div className="space-y-1">
                                            <div className="flex items-center gap-1 text-sm">
                                                <Building className="h-3 w-3" />
                                                {record.warehouseId}
                                            </div>
                                            {record.warehouseAddress && (
                                                <div className="text-xs text-muted-foreground max-w-[150px] truncate" title={record.warehouseAddress}>
                                                    {record.warehouseAddress}
                                                </div>
                                            )}
                                        </div>
                                    </td>
                                    <td className="p-4">
                                        <Badge variant={record.isUseLogisticsService ? 'default' : 'secondary'}>
                                            {record.isUseLogisticsService ? '是' : '否'}
                                        </Badge>
                                    </td>
                                    <td className="p-4">
                                        <div className="space-y-1">
                                            <div>{record.appointmentPickupDate}</div>
                                            {record.appointmentPickupTimePeriod && (
                                                <div className="text-xs text-muted-foreground">
                                                    {record.appointmentPickupTimePeriod === 'MORNING' ? '上午' :
                                                        record.appointmentPickupTimePeriod === 'AFTERNOON' ? '下午' :
                                                            record.appointmentPickupTimePeriod}
                                                </div>
                                            )}
                                        </div>
                                    </td>
                                    <td className="p-4">
                                        {record.externalLogisticsServiceName && (
                                            <div className="space-y-1">
                                                <div className="flex items-center gap-1 text-sm">
                                                    <Truck className="h-3 w-3" />
                                                    {record.externalLogisticsServiceName}
                                                </div>
                                                {record.externalLogisticsOrderNumber && (
                                                    <div className="text-xs text-muted-foreground">
                                                        {record.externalLogisticsOrderNumber}
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                    </td>
                                    <td className="p-4">
                                        {record.status && (
                                            <Badge
                                                variant={
                                                    record.status === 'PENDING_PICKUP' ? 'secondary' :
                                                        record.status === 'PENDING_WAREHOUSING' ? 'default' :
                                                            'outline'
                                                }
                                                className={
                                                    record.status === 'WAREHOUSED' ? 'bg-green-100 text-green-800 border-green-300' : ''
                                                }
                                            >
                                                {record.status === 'PENDING_PICKUP' ? '待上门' :
                                                    record.status === 'PENDING_WAREHOUSING' ? '待入库' :
                                                        record.status === 'WAREHOUSED' ? '已入库' : record.status}
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
                                                <DropdownMenuItem onClick={() => handleCopy(record.id?.toString())}>
                                                    <Copy className="mr-2 h-4 w-4" />
                                                    复制ID
                                                </DropdownMenuItem>
                                                <DropdownMenuItem onClick={() => handleCopy(record.externalLogisticsOrderNumber)}>
                                                    <Copy className="mr-2 h-4 w-4" />
                                                    复制物流单号
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
function ProductAuctionLogisticsContent() {
    const { setIsActionDialogOpen, setMode, reset } = useProductAuctionLogisticsContext()

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
                    <div className="text-lg font-medium">商品寄卖物流记录</div>
                </div>
            </header>

            <div className="flex-1 space-y-4">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <Package className="h-5 w-5" />
                        <h1 className="text-xl font-semibold">商品寄卖物流记录管理</h1>
                    </div>
                    <Button onClick={handleAdd} className="flex items-center gap-2">
                        <Plus className="h-4 w-4" />
                        新增记录
                    </Button>
                </div>

                <DataTable />
            </div>

            {/* 对话框组件 */}
            <ProductAuctionLogisticsActionDialog />
            <ProductAuctionLogisticsDeleteDialog />
        </div>
    )
}

// 导出的主组件
export default function ProductAuctionLogisticsPage() {
    return (
        <ProductAuctionLogisticsProvider>
            <ProductAuctionLogisticsContent />
        </ProductAuctionLogisticsProvider>
    )
} 