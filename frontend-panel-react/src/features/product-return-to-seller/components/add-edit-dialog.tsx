import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { productReturnToSellerSchema, statuses, type ProductReturnToSeller } from '../data/schema';
import { useProductReturnToSellerContext } from '../context/product-return-to-seller-context';
import {
    useCreateProductReturnToSellerRecord,
    useUpdateProductReturnToSellerRecord,
} from '../data/product-return-to-seller-service';

export function AddEditDialog() {
    const {
        addEditDialogOpen,
        setAddEditDialogOpen,
        selectedRecord,
        setSelectedRecord,
        isEditing,
        setIsEditing,
    } = useProductReturnToSellerContext();

    const createMutation = useCreateProductReturnToSellerRecord();
    const updateMutation = useUpdateProductReturnToSellerRecord();

    const form = useForm<ProductReturnToSeller>({
        resolver: zodResolver(productReturnToSellerSchema),
        defaultValues: {
            productId: undefined,
            productSellRecordId: undefined,
            warehouseId: undefined,
            warehouseAddress: '',
            sellerReceiptAddress: '',
            internalLogisticsTaskId: undefined,
            shipmentTime: '',
            shipmentImageUrlJson: '',
            status: 'PENDING_SHIPMENT',
        },
    });

    useEffect(() => {
        if (addEditDialogOpen && selectedRecord && isEditing) {
            form.reset({
                ...selectedRecord,
                shipmentTime: selectedRecord.shipmentTime
                    ? new Date(selectedRecord.shipmentTime).toISOString().slice(0, 16)
                    : '',
            });
        } else if (addEditDialogOpen && !isEditing) {
            form.reset({
                productId: undefined,
                productSellRecordId: undefined,
                warehouseId: undefined,
                warehouseAddress: '',
                sellerReceiptAddress: '',
                internalLogisticsTaskId: undefined,
                shipmentTime: '',
                shipmentImageUrlJson: '',
                status: 'PENDING_SHIPMENT',
            });
        }
    }, [addEditDialogOpen, selectedRecord, isEditing, form]);

    const onSubmit = async (data: ProductReturnToSeller) => {
        try {
            if (isEditing && selectedRecord) {
                await updateMutation.mutateAsync({
                    ...selectedRecord,
                    ...data,
                });
            } else {
                await createMutation.mutateAsync(data);
            }
            handleClose();
        } catch (error) {
            // 错误处理已在 mutation 中进行
        }
    };

    const handleClose = () => {
        setAddEditDialogOpen(false);
        setSelectedRecord(null);
        setIsEditing(false);
        form.reset();
    };

    return (
        <Dialog open={addEditDialogOpen} onOpenChange={handleClose}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>
                        {isEditing ? '编辑退回记录' : '添加退回记录'}
                    </DialogTitle>
                    <DialogDescription>
                        {isEditing ? '修改商品退回卖家记录信息' : '创建新的商品退回卖家记录'}
                    </DialogDescription>
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
                                                value={field.value || ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="productSellRecordId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>销售记录ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入销售记录ID"
                                                {...field}
                                                value={field.value || ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
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
                                name="warehouseId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>仓库ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入仓库ID"
                                                {...field}
                                                value={field.value || ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="internalLogisticsTaskId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>物流任务ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                placeholder="请输入物流任务ID"
                                                {...field}
                                                value={field.value || ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="warehouseAddress"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>仓库地址</FormLabel>
                                    <FormControl>
                                        <Textarea
                                            placeholder="请输入仓库地址"
                                            {...field}
                                            value={field.value || ''}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="sellerReceiptAddress"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>卖家收货地址</FormLabel>
                                    <FormControl>
                                        <Textarea
                                            placeholder="请输入卖家收货地址"
                                            {...field}
                                            value={field.value || ''}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="grid grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="shipmentTime"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>发货时间</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="datetime-local"
                                                {...field}
                                                value={field.value || ''}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="status"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>状态</FormLabel>
                                        <Select
                                            onValueChange={field.onChange}
                                            value={field.value}
                                        >
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="请选择状态" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                {statuses.map((status) => (
                                                    <SelectItem key={status.value} value={status.value}>
                                                        {status.label}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="shipmentImageUrlJson"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>发货图片JSON</FormLabel>
                                    <FormControl>
                                        <Textarea
                                            placeholder="请输入发货图片URL的JSON格式数据"
                                            {...field}
                                            value={field.value || ''}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={handleClose}>
                                取消
                            </Button>
                            <Button
                                type="submit"
                                disabled={createMutation.isPending || updateMutation.isPending}
                            >
                                {createMutation.isPending || updateMutation.isPending
                                    ? '保存中...'
                                    : isEditing
                                        ? '更新'
                                        : '创建'}
                            </Button>
                        </DialogFooter>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>
    );
} 