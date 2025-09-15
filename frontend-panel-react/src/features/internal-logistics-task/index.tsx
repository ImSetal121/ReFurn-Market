import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from '@/components/ui/dropdown-menu'
import { MoreHorizontal, Plus, Copy, Edit, Trash2, Package, User, MapPin, DollarSign, Truck, Image, CheckCircle, Truck as TruckIcon } from 'lucide-react'
import { Separator } from '@/components/ui/separator'
import { SidebarTrigger } from '@/components/ui/sidebar'
import { useInternalLogisticsTaskPage } from './data/internal-logistics-task-service'
import { InternalLogisticsTaskProvider, useInternalLogisticsTaskContext } from './context/internal-logistics-task-context'
import { InternalLogisticsTaskActionDialog } from './components/internal-logistics-task-action-dialog'
import { InternalLogisticsTaskDeleteDialog } from './components/internal-logistics-task-delete-dialog'
import { TASK_TYPE_MAP } from './data/schema'
import type { InternalLogisticsTask } from './data/schema'
import {
    ChevronLeftIcon,
    ChevronRightIcon,
    DoubleArrowLeftIcon,
    DoubleArrowRightIcon,
} from '@radix-ui/react-icons'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { RfCourierController } from '@/api/RfCourierController'
import { toast } from 'sonner'
import { TaskAcceptDialog } from './components/task-accept-dialog'
import { PickupDialog } from './components/pickup-dialog'
import { DeliveryDialog } from './components/delivery-dialog'

// 获取任务类型徽章颜色
const getTaskTypeBadgeVariant = (taskType?: string) => {
    switch (taskType) {
        case 'PICKUP_SERVICE':
            return 'secondary'
        case 'WAREHOUSE_SHIPMENT':
            return 'default'
        case 'PRODUCT_RETURN':
            return 'destructive'
        case 'RETURN_TO_SELLER':
            return 'secondary'
        case 'OTHER':
            return 'outline'
        default:
            return 'outline'
    }
}

// 获取状态徽章颜色
const getStatusBadgeVariant = (status?: string) => {
    switch (status) {
        case 'PENDING_ACCEPT':
            return 'secondary'
        case 'PENDING_PICKUP':
            return 'default'
        case 'PENDING_RECEIPT':
            return 'secondary'
        case 'COMPLETED':
            return 'default'
        case 'CANCELLED':
            return 'destructive'
        default:
            return 'outline'
    }
}

// 解析地址JSON
const parseAddress = (addressJson?: string) => {
    if (!addressJson) return null
    try {
        const address = JSON.parse(addressJson)
        return {
            formattedAddress: address.formattedAddress,
            latitude: address.latitude,
            longitude: address.longitude
        }
    } catch {
        return null
    }
}

// 简化的DataTable组件
function DataTable() {
    const [pageParams, setPageParams] = useState({
        current: 1,
        size: 10,
    })

    const { data, isLoading, error, refetch } = useInternalLogisticsTaskPage(pageParams)
    const { setSelectedRecord, setIsActionDialogOpen, setIsDeleteDialogOpen, setMode } = useInternalLogisticsTaskContext()
    const [selectedTask, setSelectedTask] = useState<InternalLogisticsTask | null>(null)
    const [isAcceptDialogOpen, setIsAcceptDialogOpen] = useState(false)
    const [selectedPickupTask, setSelectedPickupTask] = useState<InternalLogisticsTask | null>(null)
    const [isPickupDialogOpen, setIsPickupDialogOpen] = useState(false)
    const [selectedDeliveryTask, setSelectedDeliveryTask] = useState<InternalLogisticsTask | null>(null)
    const [isDeliveryDialogOpen, setIsDeliveryDialogOpen] = useState(false)

    if (isLoading) return <div className="text-center py-4">加载中...</div>
    if (error) return <div className="text-center py-4 text-red-500">加载失败</div>
    if (!data?.records?.length) return <div className="text-center py-4">暂无数据</div>

    const handleEdit = (record: InternalLogisticsTask) => {
        setSelectedRecord(record)
        setMode('edit')
        setIsActionDialogOpen(true)
    }

    const handleDelete = (record: InternalLogisticsTask) => {
        setSelectedRecord(record)
        setIsDeleteDialogOpen(true)
    }

    const handleCopy = (text: string | number | undefined) => {
        if (text) {
            navigator.clipboard.writeText(text.toString())
        }
    }

    // 解析地址图片JSON
    const parseAddressImages = (imageUrlJson?: string) => {
        if (!imageUrlJson) return []
        try {
            return JSON.parse(imageUrlJson) as string[]
        } catch {
            return []
        }
    }

    const handleAcceptTask = async (record: InternalLogisticsTask) => {
        setSelectedTask(record)
        setIsAcceptDialogOpen(true)
    }

    const handleConfirmAccept = async () => {
        if (!selectedTask) return

        try {
            await RfCourierController.acceptTask({
                taskId: selectedTask.id || 0,
                taskType: selectedTask.taskType || ''
            })
            toast.success('接单成功')
            setIsAcceptDialogOpen(false)
            refetch()
        } catch (_error) {
            toast.error('接单失败')
        }
    }

    const handlePickup = async (record: InternalLogisticsTask) => {
        setSelectedPickupTask(record)
        setIsPickupDialogOpen(true)
    }

    const handleConfirmPickup = async (imageUrls: Record<string, string>, remark: string) => {
        if (!selectedPickupTask) return

        try {
            await RfCourierController.pickupItem({
                taskId: selectedPickupTask.id || 0,
                imageUrls,
                remark
            })
            toast.success('取货成功')
            setIsPickupDialogOpen(false)
            refetch()
        } catch (_error) {
            toast.error('取货失败')
        }
    }

    const handleDeliver = async (record: InternalLogisticsTask) => {
        setSelectedDeliveryTask(record)
        setIsDeliveryDialogOpen(true)
    }

    const handleConfirmDelivery = async (imageUrls: Record<string, string>, remark: string) => {
        if (!selectedDeliveryTask) return

        try {
            await RfCourierController.deliverItem({
                taskId: selectedDeliveryTask.id || 0,
                imageUrls,
                remark
            })
            toast.success('送达成功')
            setIsDeliveryDialogOpen(false)
            refetch()
        } catch (_error) {
            toast.error('送达失败')
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
                                <th className="h-12 px-4 text-left align-middle font-medium">任务类型</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">商品信息</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">销售记录</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">寄售记录</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">退货记录</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">退卖家记录</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">物流员</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">起始地址</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">目标地址</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">物流费用</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">状态</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">创建时间</th>
                                <th className="h-12 px-4 text-left align-middle font-medium">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            {data.records.map((record) => {
                                const sourceImages = parseAddressImages(record.sourceAddressImageUrlJson)
                                const targetImages = parseAddressImages(record.targetAddressImageUrlJson)
                                return (
                                    <tr key={record.id} className="border-b">
                                        <td className="p-4">{record.id}</td>
                                        <td className="p-4">
                                            {record.taskType ? (
                                                <Badge variant={getTaskTypeBadgeVariant(record.taskType)}>
                                                    {TASK_TYPE_MAP[record.taskType as keyof typeof TASK_TYPE_MAP]}
                                                </Badge>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            {record.productId ? (
                                                <div className="flex items-center gap-1">
                                                    <Package className="h-3 w-3" />
                                                    {record.productId}
                                                </div>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            {record.productSellRecordId ? (
                                                <div className="flex items-center gap-1">
                                                    <Truck className="h-3 w-3" />
                                                    {record.productSellRecordId}
                                                </div>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            {record.productConsignmentRecordId ? (
                                                <div className="flex items-center gap-1">
                                                    <Package className="h-3 w-3" />
                                                    {record.productConsignmentRecordId}
                                                </div>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            {record.productReturnRecordId ? (
                                                <div className="flex items-center gap-1">
                                                    <Truck className="h-3 w-3" />
                                                    {record.productReturnRecordId}
                                                </div>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            {record.productReturnToSellerRecordId ? (
                                                <div className="flex items-center gap-1">
                                                    <Truck className="h-3 w-3" />
                                                    {record.productReturnToSellerRecordId}
                                                </div>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            {record.logisticsUserId ? (
                                                <div className="flex items-center gap-1">
                                                    <User className="h-3 w-3" />
                                                    {record.logisticsUserId}
                                                </div>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            <div className="space-y-1">
                                                {record.sourceAddress ? (
                                                    <div className="flex items-center gap-1">
                                                        <MapPin className="h-3 w-3" />
                                                        <span className="max-w-[120px] truncate" title={parseAddress(record.sourceAddress)?.formattedAddress}>
                                                            {parseAddress(record.sourceAddress)?.formattedAddress}
                                                        </span>
                                                    </div>
                                                ) : (
                                                    <span className="text-muted-foreground">-</span>
                                                )}
                                                {sourceImages.length > 0 && (
                                                    <div className="flex items-center gap-1">
                                                        <Image className="h-3 w-3" />
                                                        <Badge variant="outline" className="text-xs">
                                                            {sourceImages.length} 张图片
                                                        </Badge>
                                                    </div>
                                                )}
                                            </div>
                                        </td>
                                        <td className="p-4">
                                            <div className="space-y-1">
                                                {record.targetAddress ? (
                                                    <div className="flex items-center gap-1">
                                                        <MapPin className="h-3 w-3" />
                                                        <span className="max-w-[120px] truncate" title={parseAddress(record.targetAddress)?.formattedAddress}>
                                                            {parseAddress(record.targetAddress)?.formattedAddress}
                                                        </span>
                                                    </div>
                                                ) : (
                                                    <span className="text-muted-foreground">-</span>
                                                )}
                                                {targetImages.length > 0 && (
                                                    <div className="flex items-center gap-1">
                                                        <Image className="h-3 w-3" />
                                                        <Badge variant="outline" className="text-xs">
                                                            {targetImages.length} 张图片
                                                        </Badge>
                                                    </div>
                                                )}
                                            </div>
                                        </td>
                                        <td className="p-4">
                                            {record.logisticsCost ? (
                                                <div className="flex items-center gap-1">
                                                    <DollarSign className="h-3 w-3" />
                                                    <span className="font-medium">¥{record.logisticsCost}</span>
                                                </div>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            {record.status ? (
                                                <Badge variant={getStatusBadgeVariant(record.status)}>
                                                    {record.status}
                                                </Badge>
                                            ) : (
                                                <span className="text-muted-foreground">-</span>
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
                                                    {record.status === 'PENDING_ACCEPT' && (
                                                        <DropdownMenuItem onClick={() => handleAcceptTask(record)}>
                                                            <CheckCircle className="mr-2 h-4 w-4" />
                                                            接取任务
                                                        </DropdownMenuItem>
                                                    )}
                                                    {record.status === 'PENDING_PICKUP' && (
                                                        <DropdownMenuItem onClick={() => handlePickup(record)}>
                                                            <Package className="mr-2 h-4 w-4" />
                                                            取货
                                                        </DropdownMenuItem>
                                                    )}
                                                    {record.status === 'PENDING_RECEIPT' && (
                                                        <DropdownMenuItem onClick={() => handleDeliver(record)}>
                                                            <TruckIcon className="mr-2 h-4 w-4" />
                                                            送达
                                                        </DropdownMenuItem>
                                                    )}
                                                    <DropdownMenuItem onClick={() => handleEdit(record)}>
                                                        <Edit className="mr-2 h-4 w-4" />
                                                        编辑
                                                    </DropdownMenuItem>
                                                    <DropdownMenuItem onClick={() => handleCopy(record.id)}>
                                                        <Copy className="mr-2 h-4 w-4" />
                                                        复制ID
                                                    </DropdownMenuItem>
                                                    <DropdownMenuItem onClick={() => handleCopy(record.productId)}>
                                                        <Copy className="mr-2 h-4 w-4" />
                                                        复制商品ID
                                                    </DropdownMenuItem>
                                                    <DropdownMenuItem onClick={() => handleCopy(record.logisticsUserId)}>
                                                        <Copy className="mr-2 h-4 w-4" />
                                                        复制物流员ID
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
                                )
                            })}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* 分页 */}
            <div className='flex items-center justify-between overflow-clip px-2' style={{ overflowClipMargin: 1 }}>
                <div className='text-muted-foreground hidden flex-1 text-sm sm:block'>
                    共 {data.total} 条记录
                </div>
                <div className='flex items-center sm:space-x-6 lg:space-x-8'>
                    <div className='flex items-center space-x-2'>
                        <p className='hidden text-sm font-medium sm:block'>每页显示</p>
                        <Select
                            value={String(pageParams.size)}
                            onValueChange={(value) => setPageParams(prev => ({ ...prev, size: Number(value) }))}
                        >
                            <SelectTrigger className='h-8 w-[70px]'>
                                <SelectValue placeholder={pageParams.size} />
                            </SelectTrigger>
                            <SelectContent side='top'>
                                {[10, 20, 30, 40, 50].map((pageSize) => (
                                    <SelectItem key={pageSize} value={String(pageSize)}>
                                        {pageSize}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>
                    <div className='flex w-[100px] items-center justify-center text-sm font-medium'>
                        第 {data.current} 页，共 {data.pages} 页
                    </div>
                    <div className='flex items-center space-x-2'>
                        <Button
                            variant='outline'
                            className='hidden h-8 w-8 p-0 lg:flex'
                            onClick={() => setPageParams(prev => ({ ...prev, current: 1 }))}
                            disabled={data.current === 1}
                        >
                            <span className='sr-only'>首页</span>
                            <DoubleArrowLeftIcon className='h-4 w-4' />
                        </Button>
                        <Button
                            variant='outline'
                            className='h-8 w-8 p-0'
                            onClick={() => setPageParams(prev => ({ ...prev, current: Math.max(1, prev.current - 1) }))}
                            disabled={data.current === 1}
                        >
                            <span className='sr-only'>上一页</span>
                            <ChevronLeftIcon className='h-4 w-4' />
                        </Button>
                        <Button
                            variant='outline'
                            className='h-8 w-8 p-0'
                            onClick={() => setPageParams(prev => ({ ...prev, current: prev.current + 1 }))}
                            disabled={data.current >= data.pages}
                        >
                            <span className='sr-only'>下一页</span>
                            <ChevronRightIcon className='h-4 w-4' />
                        </Button>
                        <Button
                            variant='outline'
                            className='hidden h-8 w-8 p-0 lg:flex'
                            onClick={() => setPageParams(prev => ({ ...prev, current: data.pages }))}
                            disabled={data.current >= data.pages}
                        >
                            <span className='sr-only'>末页</span>
                            <DoubleArrowRightIcon className='h-4 w-4' />
                        </Button>
                    </div>
                </div>
            </div>

            {selectedTask && (
                <TaskAcceptDialog
                    open={isAcceptDialogOpen}
                    onOpenChange={setIsAcceptDialogOpen}
                    task={selectedTask}
                    onAccept={handleConfirmAccept}
                />
            )}

            {selectedPickupTask && (
                <PickupDialog
                    open={isPickupDialogOpen}
                    onOpenChange={setIsPickupDialogOpen}
                    task={selectedPickupTask}
                    onPickup={handleConfirmPickup}
                />
            )}

            {selectedDeliveryTask && (
                <DeliveryDialog
                    open={isDeliveryDialogOpen}
                    onOpenChange={setIsDeliveryDialogOpen}
                    task={selectedDeliveryTask}
                    onDeliver={handleConfirmDelivery}
                />
            )}
        </div>
    )
}

// 主页面组件
function InternalLogisticsTaskContent() {
    const { setIsActionDialogOpen, setMode, reset } = useInternalLogisticsTaskContext()

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
                    <div className="text-lg font-medium">内部物流任务管理</div>
                </div>
            </header>

            <div className="flex-1 space-y-4">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <Truck className="h-5 w-5" />
                        <h1 className="text-xl font-semibold">内部物流任务管理</h1>
                    </div>
                    <Button onClick={handleAdd} className="flex items-center gap-2">
                        <Plus className="h-4 w-4" />
                        新增任务
                    </Button>
                </div>

                <DataTable />
            </div>

            {/* 对话框组件 */}
            <InternalLogisticsTaskActionDialog />
            <InternalLogisticsTaskDeleteDialog />
        </div>
    )
}

// 导出的主组件
export default function InternalLogisticsTaskPage() {
    return (
        <InternalLogisticsTaskProvider>
            <InternalLogisticsTaskContent />
        </InternalLogisticsTaskProvider>
    )
} 