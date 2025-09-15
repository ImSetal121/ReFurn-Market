import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { useWarehouseStockContext } from '../context/warehouse-stock-context'
import { useAddWarehouseStock, useUpdateWarehouseStock } from '../data/warehouse-stock-service'
import { warehouseStockSchema, type WarehouseStock } from '../data/schema'
import { useEffect } from 'react'

export function WarehouseStockActionDialog() {
    const {
        isActionDialogOpen,
        setIsActionDialogOpen,
        selectedRecord,
        mode,
        reset
    } = useWarehouseStockContext()

    const addMutation = useAddWarehouseStock()
    const updateMutation = useUpdateWarehouseStock()

    const form = useForm<WarehouseStock>({
        resolver: zodResolver(warehouseStockSchema),
        defaultValues: {
            warehouseId: undefined,
            productId: undefined,
            stockQuantity: undefined,
            stockPosition: '',
            warehouseInApplyId: undefined,
            warehouseInId: undefined,
            warehouseOutId: undefined,
            status: 'IN_STOCK',
        },
    })

    // 当对话框打开时，根据模式设置表单数据
    useEffect(() => {
        if (isActionDialogOpen) {
            if (mode === 'edit' && selectedRecord) {
                form.reset(selectedRecord)
            } else {
                form.reset({
                    warehouseId: undefined,
                    productId: undefined,
                    stockQuantity: undefined,
                    stockPosition: '',
                    warehouseInApplyId: undefined,
                    warehouseInId: undefined,
                    warehouseOutId: undefined,
                    status: 'IN_STOCK',
                })
            }
        }
    }, [isActionDialogOpen, mode, selectedRecord, form])

    const onSubmit = async (data: WarehouseStock) => {
        try {
            if (mode === 'edit') {
                await updateMutation.mutateAsync({ ...data, id: selectedRecord?.id })
            } else {
                await addMutation.mutateAsync(data)
            }
            onClose()
        } catch (error) {
            console.error('提交失败:', error)
        }
    }

    const onClose = () => {
        setIsActionDialogOpen(false)
        form.reset()
        setTimeout(() => {
            reset()
        }, 200)
    }

    const isLoading = addMutation.isPending || updateMutation.isPending

    return (
        <Dialog open={isActionDialogOpen} onOpenChange={setIsActionDialogOpen}>
            <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>
                        {mode === 'edit' ? '编辑仓库库存' : '新增仓库库存'}
                    </DialogTitle>
                </DialogHeader>

                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                            {/* 仓库ID */}
                            <FormField
                                control={form.control}
                                name="warehouseId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>仓库ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入仓库ID"
                                                {...field}
                                                value={field.value ?? ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 商品ID */}
                            <FormField
                                control={form.control}
                                name="productId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>商品ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入商品ID"
                                                {...field}
                                                value={field.value ?? ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 库存数量 */}
                            <FormField
                                control={form.control}
                                name="stockQuantity"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>库存数量</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                min="0"
                                                placeholder="请输入库存数量"
                                                {...field}
                                                value={field.value ?? ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 状态 */}
                            <FormField
                                control={form.control}
                                name="status"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>状态</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="请选择状态" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value="IN_STOCK">库存中</SelectItem>
                                                <SelectItem value="OUT_OF_STOCK">已出库</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 库存位置 */}
                            <FormField
                                control={form.control}
                                name="stockPosition"
                                render={({ field }) => (
                                    <FormItem className="col-span-2">
                                        <FormLabel>库存位置</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="请输入库存位置（如：A区-1货架-3层）"
                                                {...field}
                                                value={field.value ?? ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 入库申请ID */}
                            <FormField
                                control={form.control}
                                name="warehouseInApplyId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>入库申请ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入入库申请ID"
                                                {...field}
                                                value={field.value ?? ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 入库ID */}
                            <FormField
                                control={form.control}
                                name="warehouseInId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>入库ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入入库ID"
                                                {...field}
                                                value={field.value ?? ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 入库时间 */}
                            <FormField
                                control={form.control}
                                name="inTime"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>入库时间</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="datetime-local"
                                                {...field}
                                                value={field.value ? field.value.slice(0, 16) : ''}
                                                onChange={(e) => field.onChange(e.target.value ? `${e.target.value}:00` : '')}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 出库ID */}
                            <FormField
                                control={form.control}
                                name="warehouseOutId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>出库ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入出库ID"
                                                {...field}
                                                value={field.value ?? ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 出库时间 */}
                            <FormField
                                control={form.control}
                                name="outTime"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>出库时间</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="datetime-local"
                                                {...field}
                                                value={field.value ? field.value.slice(0, 16) : ''}
                                                onChange={(e) => field.onChange(e.target.value ? `${e.target.value}:00` : '')}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className="flex justify-end space-x-2 pt-4">
                            <Button
                                type="button"
                                variant="outline"
                                onClick={onClose}
                                disabled={isLoading}
                            >
                                取消
                            </Button>
                            <Button type="submit" disabled={isLoading}>
                                {isLoading ? '提交中...' : (mode === 'edit' ? '更新' : '创建')}
                            </Button>
                        </div>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>
    )
} 