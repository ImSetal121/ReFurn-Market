import { useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Switch } from '@/components/ui/switch'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { useProductAuctionLogisticsContext } from '../context/product-auction-logistics-context'
import { useAddProductAuctionLogistics, useUpdateProductAuctionLogistics } from '../data/product-auction-logistics-service'
import { productAuctionLogisticsSchema, type ProductAuctionLogistics } from '../data/schema'

export function ProductAuctionLogisticsActionDialog() {
    const {
        selectedRecord,
        isActionDialogOpen,
        setIsActionDialogOpen,
        mode,
        reset,
    } = useProductAuctionLogisticsContext()

    const addMutation = useAddProductAuctionLogistics()
    const updateMutation = useUpdateProductAuctionLogistics()

    const form = useForm<ProductAuctionLogistics>({
        resolver: zodResolver(productAuctionLogisticsSchema),
        defaultValues: {
            productId: undefined,
            productSellRecordId: undefined,
            pickupAddress: '',
            warehouseId: undefined,
            warehouseAddress: '',
            isUseLogisticsService: false,
            appointmentPickupDate: '',
            appointmentPickupTimePeriod: undefined,
            internalLogisticsTaskId: undefined,
            externalLogisticsServiceName: '',
            externalLogisticsOrderNumber: '',
            status: undefined,
        },
    })

    useEffect(() => {
        if (isActionDialogOpen && selectedRecord && mode === 'edit') {
            form.reset(selectedRecord)
        } else if (isActionDialogOpen && mode === 'add') {
            form.reset({
                productId: undefined,
                productSellRecordId: undefined,
                pickupAddress: '',
                warehouseId: undefined,
                warehouseAddress: '',
                isUseLogisticsService: false,
                appointmentPickupDate: '',
                appointmentPickupTimePeriod: undefined,
                internalLogisticsTaskId: undefined,
                externalLogisticsServiceName: '',
                externalLogisticsOrderNumber: '',
                status: undefined,
            })
        }
    }, [isActionDialogOpen, selectedRecord, mode, form])

    const onSubmit = async (data: ProductAuctionLogistics) => {
        try {
            if (mode === 'add') {
                await addMutation.mutateAsync(data)
            } else {
                await updateMutation.mutateAsync(data)
            }
            handleClose()
        } catch (_error) {
            // 错误已经在mutation中处理
        }
    }

    const handleClose = () => {
        setIsActionDialogOpen(false)
        form.reset()
        reset()
    }

    return (
        <Dialog open={isActionDialogOpen} onOpenChange={setIsActionDialogOpen}>
            <DialogContent className="sm:max-w-[700px] max-h-[90vh]">
                <DialogHeader>
                    <DialogTitle>
                        {mode === 'add' ? '新增寄卖物流记录' : '编辑寄卖物流记录'}
                    </DialogTitle>
                    <DialogDescription>
                        {mode === 'add'
                            ? '填写寄卖物流记录信息以添加新记录。'
                            : '修改寄卖物流记录信息后点击保存。'
                        }
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 max-h-[80vh] overflow-y-auto">
                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="productId">商品ID</Label>
                            <Input
                                id="productId"
                                type="number"
                                placeholder="请输入商品ID"
                                {...form.register('productId', { valueAsNumber: true })}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="productSellRecordId">销售记录ID</Label>
                            <Input
                                id="productSellRecordId"
                                type="number"
                                placeholder="请输入销售记录ID"
                                {...form.register('productSellRecordId', { valueAsNumber: true })}
                            />
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="pickupAddress">取货地址</Label>
                        <Textarea
                            id="pickupAddress"
                            placeholder="请输入取货地址"
                            rows={2}
                            {...form.register('pickupAddress')}
                        />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="warehouseId">仓库ID</Label>
                            <Input
                                id="warehouseId"
                                type="number"
                                placeholder="请输入仓库ID"
                                {...form.register('warehouseId', { valueAsNumber: true })}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="warehouseAddress">仓库地址</Label>
                            <Input
                                id="warehouseAddress"
                                placeholder="请输入仓库地址"
                                {...form.register('warehouseAddress')}
                            />
                        </div>
                    </div>

                    <div className="flex items-center space-x-2">
                        <Switch
                            id="isUseLogisticsService"
                            checked={form.watch('isUseLogisticsService')}
                            onCheckedChange={(checked) => form.setValue('isUseLogisticsService', checked)}
                        />
                        <Label htmlFor="isUseLogisticsService">使用物流服务</Label>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="appointmentPickupDate">预约取货日期</Label>
                            <Input
                                id="appointmentPickupDate"
                                type="date"
                                {...form.register('appointmentPickupDate')}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="appointmentPickupTimePeriod">预约取货时间段</Label>
                            <Select
                                value={form.watch('appointmentPickupTimePeriod') || ''}
                                onValueChange={(value) => form.setValue('appointmentPickupTimePeriod', value as 'MORNING' | 'AFTERNOON')}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="请选择时间段" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="MORNING">上午</SelectItem>
                                    <SelectItem value="AFTERNOON">下午</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="internalLogisticsTaskId">内部物流任务ID</Label>
                        <Input
                            id="internalLogisticsTaskId"
                            type="number"
                            placeholder="请输入内部物流任务ID"
                            {...form.register('internalLogisticsTaskId', { valueAsNumber: true })}
                        />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="externalLogisticsServiceName">外部物流服务名称</Label>
                            <Input
                                id="externalLogisticsServiceName"
                                placeholder="例如：顺丰、圆通等"
                                {...form.register('externalLogisticsServiceName')}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="externalLogisticsOrderNumber">外部物流订单号</Label>
                            <Input
                                id="externalLogisticsOrderNumber"
                                placeholder="请输入物流订单号"
                                {...form.register('externalLogisticsOrderNumber')}
                            />
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="status">状态</Label>
                        <Select
                            value={form.watch('status') || ''}
                            onValueChange={(value) => form.setValue('status', value as 'PENDING_PICKUP' | 'PENDING_WAREHOUSING' | 'WAREHOUSED')}
                        >
                            <SelectTrigger>
                                <SelectValue placeholder="请选择状态" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="PENDING_PICKUP">待上门</SelectItem>
                                <SelectItem value="PENDING_WAREHOUSING">待入库</SelectItem>
                                <SelectItem value="WAREHOUSED">已入库</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>

                    <DialogFooter>
                        <Button type="button" variant="outline" onClick={handleClose}>
                            取消
                        </Button>
                        <Button
                            type="submit"
                            disabled={addMutation.isPending || updateMutation.isPending}
                        >
                            {mode === 'add' ? '添加' : '保存'}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
} 