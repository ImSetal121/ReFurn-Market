import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { useInternalLogisticsTaskContext } from '../context/internal-logistics-task-context'
import { useAddInternalLogisticsTask, useUpdateInternalLogisticsTask } from '../data/internal-logistics-task-service'
import { internalLogisticsTaskSchema, TASK_TYPE_OPTIONS, type InternalLogisticsTask } from '../data/schema'
import { useEffect } from 'react'

export function InternalLogisticsTaskActionDialog() {
    const {
        isActionDialogOpen,
        setIsActionDialogOpen,
        selectedRecord,
        mode,
        reset
    } = useInternalLogisticsTaskContext()

    const addMutation = useAddInternalLogisticsTask()
    const updateMutation = useUpdateInternalLogisticsTask()

    const form = useForm<InternalLogisticsTask>({
        resolver: zodResolver(internalLogisticsTaskSchema),
        defaultValues: {
            productId: undefined,
            productSellRecordId: undefined,
            taskType: undefined,
            logisticsUserId: undefined,
            sourceAddress: '',
            sourceAddressImageUrlJson: '',
            targetAddress: '',
            targetAddressImageUrlJson: '',
            logisticsCost: undefined,
            status: '',
        },
    })

    // 当对话框打开时，根据模式设置表单数据
    useEffect(() => {
        if (isActionDialogOpen) {
            if (mode === 'edit' && selectedRecord) {
                form.reset(selectedRecord)
            } else {
                form.reset({
                    productId: undefined,
                    productSellRecordId: undefined,
                    taskType: undefined,
                    logisticsUserId: undefined,
                    sourceAddress: '',
                    sourceAddressImageUrlJson: '',
                    targetAddress: '',
                    targetAddressImageUrlJson: '',
                    logisticsCost: undefined,
                    status: '',
                })
            }
        }
    }, [isActionDialogOpen, mode, selectedRecord, form])

    const onSubmit = async (data: InternalLogisticsTask) => {
        try {
            if (mode === 'edit') {
                await updateMutation.mutateAsync({ ...data, id: selectedRecord?.id })
            } else {
                await addMutation.mutateAsync(data)
            }
            onClose()
        } catch (_error) {
            // 错误已在service层处理
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
            <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>
                        {mode === 'edit' ? '编辑内部物流任务' : '新增内部物流任务'}
                    </DialogTitle>
                </DialogHeader>

                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                            {/* 任务类型 */}
                            <FormField
                                control={form.control}
                                name="taskType"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>任务类型</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="请选择任务类型" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                {TASK_TYPE_OPTIONS.map((option) => (
                                                    <SelectItem key={option.value} value={option.value}>
                                                        {option.label}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
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

                            {/* 销售记录ID */}
                            <FormField
                                control={form.control}
                                name="productSellRecordId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>销售记录ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入销售记录ID（可选）"
                                                {...field}
                                                value={field.value ?? ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 物流员ID */}
                            <FormField
                                control={form.control}
                                name="logisticsUserId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>物流员ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入物流员ID"
                                                {...field}
                                                value={field.value ?? ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 物流费用 */}
                            <FormField
                                control={form.control}
                                name="logisticsCost"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>物流费用（元）</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                min="0"
                                                step="0.01"
                                                placeholder="请输入物流费用"
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
                                        <FormControl>
                                            <Input
                                                placeholder="请输入任务状态"
                                                {...field}
                                                value={field.value ?? ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 起始地址 */}
                            <FormField
                                control={form.control}
                                name="sourceAddress"
                                render={({ field }) => (
                                    <FormItem className="col-span-2">
                                        <FormLabel>起始地址</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="请输入起始地址"
                                                {...field}
                                                value={field.value ?? ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 起始地址图片URL JSON */}
                            <FormField
                                control={form.control}
                                name="sourceAddressImageUrlJson"
                                render={({ field }) => (
                                    <FormItem className="col-span-2">
                                        <FormLabel>起始地址图片URL JSON</FormLabel>
                                        <FormControl>
                                            <Textarea
                                                placeholder='请输入起始地址图片URL的JSON数组，格式如：["url1", "url2"]'
                                                className="min-h-[80px]"
                                                {...field}
                                                value={field.value ?? ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 目标地址 */}
                            <FormField
                                control={form.control}
                                name="targetAddress"
                                render={({ field }) => (
                                    <FormItem className="col-span-2">
                                        <FormLabel>目标地址</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder="请输入目标地址"
                                                {...field}
                                                value={field.value ?? ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            {/* 目标地址图片URL JSON */}
                            <FormField
                                control={form.control}
                                name="targetAddressImageUrlJson"
                                render={({ field }) => (
                                    <FormItem className="col-span-2">
                                        <FormLabel>目标地址图片URL JSON</FormLabel>
                                        <FormControl>
                                            <Textarea
                                                placeholder='请输入目标地址图片URL的JSON数组，格式如：["url1", "url2"]'
                                                className="min-h-[80px]"
                                                {...field}
                                                value={field.value ?? ''}
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