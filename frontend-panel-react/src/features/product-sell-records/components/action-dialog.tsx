import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from '@/components/ui/form'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import { useAddProductSellRecord, useUpdateProductSellRecord } from '../data/service'
import { productSellRecordSchema, statusOptions, type ProductSellRecord } from '../data/schema'

interface ProductSellRecordActionDialogProps {
    open: boolean
    onOpenChange: () => void
    currentRow?: ProductSellRecord
}

export function ProductSellRecordActionDialog({
    open,
    onOpenChange,
    currentRow,
}: ProductSellRecordActionDialogProps) {
    const isEdit = !!currentRow
    const addRecord = useAddProductSellRecord()
    const updateRecord = useUpdateProductSellRecord()

    const form = useForm<ProductSellRecord>({
        resolver: zodResolver(productSellRecordSchema),
        defaultValues: currentRow || {
            productId: undefined,
            sellerUserId: undefined,
            buyerUserId: undefined,
            finalProductPrice: undefined,
            isAuction: false,
            isSelfPickup: false,
            status: 'PENDING_SHIPMENT',
        },
    })

    const onSubmit = async (data: ProductSellRecord) => {
        try {
            if (isEdit) {
                await updateRecord.mutateAsync({ ...data, id: currentRow.id })
            } else {
                await addRecord.mutateAsync(data)
            }
            form.reset()
            onOpenChange()
        } catch (_error) {
            // 错误处理已由mutation的onError处理
        }
    }

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>{isEdit ? '编辑销售记录' : '添加销售记录'}</DialogTitle>
                </DialogHeader>
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
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
                                                onChange={(e) => field.onChange(Number(e.target.value) || undefined)}
                                                value={field.value || ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="finalProductPrice"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>成交价格 ($)</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                step="0.01"
                                                placeholder="请输入成交价格"
                                                {...field}
                                                onChange={(e) => field.onChange(Number(e.target.value) || undefined)}
                                                value={field.value || ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="sellerUserId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>卖家ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入卖家ID"
                                                {...field}
                                                onChange={(e) => field.onChange(Number(e.target.value) || undefined)}
                                                value={field.value || ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="buyerUserId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>买家ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入买家ID"
                                                {...field}
                                                onChange={(e) => field.onChange(Number(e.target.value) || undefined)}
                                                value={field.value || ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="status"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>状态</FormLabel>
                                    <Select
                                        onValueChange={field.onChange}
                                        defaultValue={field.value}
                                    >
                                        <FormControl>
                                            <SelectTrigger>
                                                <SelectValue placeholder="请选择状态" />
                                            </SelectTrigger>
                                        </FormControl>
                                        <SelectContent>
                                            {statusOptions.map((option) => (
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

                        <div className="grid grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="isAuction"
                                render={({ field }) => (
                                    <FormItem className="flex flex-row items-start space-x-3 space-y-0">
                                        <FormControl>
                                            <Checkbox
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                        <div className="space-y-1 leading-none">
                                            <FormLabel>拍卖交易</FormLabel>
                                        </div>
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="isSelfPickup"
                                render={({ field }) => (
                                    <FormItem className="flex flex-row items-start space-x-3 space-y-0">
                                        <FormControl>
                                            <Checkbox
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                        <div className="space-y-1 leading-none">
                                            <FormLabel>自提方式</FormLabel>
                                        </div>
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className="flex justify-end space-x-2 pt-4">
                            <Button type="button" variant="outline" onClick={onOpenChange}>
                                取消
                            </Button>
                            <Button
                                type="submit"
                                disabled={addRecord.isPending || updateRecord.isPending}
                            >
                                {addRecord.isPending || updateRecord.isPending
                                    ? '保存中...'
                                    : isEdit ? '更新' : '添加'
                                }
                            </Button>
                        </div>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>
    )
} 