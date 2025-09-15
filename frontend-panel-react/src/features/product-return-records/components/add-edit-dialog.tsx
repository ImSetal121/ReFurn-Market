import { useEffect } from 'react';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { CalendarIcon } from 'lucide-react';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';

import { Button } from '@/components/ui/button';
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
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import {
    Popover,
    PopoverContent,
    PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';

import { useProductReturnRecordContext } from '../context/product-return-record-context';
import { useCreateProductReturnRecord, useUpdateProductReturnRecord } from '../data/product-return-record-service';
import { productReturnRecordSchema, type ProductReturnRecord, auditResults, freightBearers, compensationBearers, statuses } from '../data/schema';

export function AddEditDialog() {
    const {
        addEditDialogOpen,
        setAddEditDialogOpen,
        selectedRecord,
        setSelectedRecord,
        isEditing,
        setIsEditing,
    } = useProductReturnRecordContext();

    const createMutation = useCreateProductReturnRecord();
    const updateMutation = useUpdateProductReturnRecord();

    const form = useForm<ProductReturnRecord>({
        resolver: zodResolver(productReturnRecordSchema),
        defaultValues: {
            productId: undefined,
            productSellRecordId: undefined,
            returnReasonType: '',
            returnReasonDetail: '',
            sellerAcceptReturn: false,
            sellerOpinionDetail: '',
            auditResult: undefined,
            auditDetail: '',
            freightBearer: undefined,
            freightBearerUserId: undefined,
            needCompensateProduct: false,
            compensationBearer: undefined,
            compensationBearerUserId: undefined,
            isAuction: false,
            isUseLogisticsService: false,
            appointmentPickupTime: '',
            internalLogisticsTaskId: undefined,
            externalLogisticsServiceName: '',
            externalLogisticsOrderNumber: '',
            status: undefined,
        },
    });

    useEffect(() => {
        if (isEditing && selectedRecord) {
            form.reset({
                ...selectedRecord,
                appointmentPickupTime: selectedRecord.appointmentPickupTime || '',
            });
        } else {
            form.reset({
                productId: undefined,
                productSellRecordId: undefined,
                returnReasonType: '',
                returnReasonDetail: '',
                sellerAcceptReturn: false,
                sellerOpinionDetail: '',
                auditResult: undefined,
                auditDetail: '',
                freightBearer: undefined,
                freightBearerUserId: undefined,
                needCompensateProduct: false,
                compensationBearer: undefined,
                compensationBearerUserId: undefined,
                isAuction: false,
                isUseLogisticsService: false,
                appointmentPickupTime: '',
                internalLogisticsTaskId: undefined,
                externalLogisticsServiceName: '',
                externalLogisticsOrderNumber: '',
                status: undefined,
            });
        }
    }, [isEditing, selectedRecord, form]);

    const onSubmit = (data: ProductReturnRecord) => {
        if (isEditing) {
            updateMutation.mutate(
                { ...data, id: selectedRecord?.id },
                {
                    onSuccess: () => {
                        handleClose();
                    },
                }
            );
        } else {
            createMutation.mutate(data, {
                onSuccess: () => {
                    handleClose();
                },
            });
        }
    };

    const handleClose = () => {
        setAddEditDialogOpen(false);
        setSelectedRecord(null);
        setIsEditing(false);
        form.reset();
    };

    const isPending = createMutation.isPending || updateMutation.isPending;

    return (
        <Dialog open={addEditDialogOpen} onOpenChange={setAddEditDialogOpen}>
            <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>{isEditing ? '编辑商品退货记录' : '新增商品退货记录'}</DialogTitle>
                    <DialogDescription>
                        {isEditing ? '编辑选中的商品退货记录信息' : '创建新的商品退货记录'}
                    </DialogDescription>
                </DialogHeader>
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="productId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>商品ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
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
                                        <FormLabel>商品出售记录ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
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

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="returnReasonType"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>退货原因类型</FormLabel>
                                        <FormControl>
                                            <Input {...field} />
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
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="选择状态" />
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
                            name="returnReasonDetail"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>退货原因详细说明</FormLabel>
                                    <FormControl>
                                        <Textarea {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="pickupAddress"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>取件地址</FormLabel>
                                    <FormControl>
                                        <Textarea
                                            placeholder="请输入取件地址"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="sellerAcceptReturn"
                                render={({ field }) => (
                                    <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                                        <div className="space-y-0.5">
                                            <FormLabel className="text-base">卖家是否接受退货</FormLabel>
                                        </div>
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="sellerOpinionDetail"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>卖家意见详情</FormLabel>
                                    <FormControl>
                                        <Textarea
                                            placeholder="请输入卖家对退货申请的意见详情"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="auditResult"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>审核结果</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="选择审核结果" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                {auditResults.map((result) => (
                                                    <SelectItem key={result.value} value={result.value}>
                                                        {result.label}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="freightBearer"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>运费承担方</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="选择运费承担方" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                {freightBearers.map((bearer) => (
                                                    <SelectItem key={bearer.value} value={bearer.value}>
                                                        {bearer.label}
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
                            name="auditDetail"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>审核详细说明</FormLabel>
                                    <FormControl>
                                        <Textarea {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="freightBearerUserId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>运费承担用户ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
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
                                name="compensationBearer"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>赔偿承担方</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="选择赔偿承担方" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                {compensationBearers.map((bearer) => (
                                                    <SelectItem key={bearer.value} value={bearer.value}>
                                                        {bearer.label}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="compensationBearerUserId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>赔偿承担用户ID</FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
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
                                        <FormLabel>内部物流任务ID <span className="text-muted-foreground">(可选)</span></FormLabel>
                                        <FormControl>
                                            <Input
                                                type="number"
                                                {...field}
                                                value={field.value || ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : null)}
                                                placeholder="请输入内部物流任务ID"
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <FormField
                                control={form.control}
                                name="externalLogisticsServiceName"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>外部物流服务商名称 <span className="text-muted-foreground">(可选)</span></FormLabel>
                                        <FormControl>
                                            <Input {...field} placeholder="请输入外部物流服务商名称" />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="externalLogisticsOrderNumber"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>外部物流单号 <span className="text-muted-foreground">(可选)</span></FormLabel>
                                        <FormControl>
                                            <Input {...field} placeholder="请输入外部物流单号" />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="appointmentPickupTime"
                            render={({ field }) => (
                                <FormItem className="flex flex-col">
                                    <FormLabel>预约取件时间</FormLabel>
                                    <Popover>
                                        <PopoverTrigger asChild>
                                            <FormControl>
                                                <Button
                                                    variant={"outline"}
                                                    className={cn(
                                                        "w-[240px] pl-3 text-left font-normal",
                                                        !field.value && "text-muted-foreground"
                                                    )}
                                                >
                                                    {field.value ? (
                                                        format(new Date(field.value), "PPP")
                                                    ) : (
                                                        <span>选择日期和时间</span>
                                                    )}
                                                    <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                                                </Button>
                                            </FormControl>
                                        </PopoverTrigger>
                                        <PopoverContent className="w-auto p-0" align="start">
                                            <Calendar
                                                mode="single"
                                                selected={field.value ? new Date(field.value) : undefined}
                                                onSelect={(date) => field.onChange(date?.toISOString())}
                                                disabled={(date) =>
                                                    date < new Date("1900-01-01")
                                                }
                                                initialFocus
                                            />
                                        </PopoverContent>
                                    </Popover>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <FormField
                                control={form.control}
                                name="needCompensateProduct"
                                render={({ field }) => (
                                    <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                                        <div className="space-y-0.5">
                                            <FormLabel className="text-base">需要赔偿商品</FormLabel>
                                        </div>
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="isAuction"
                                render={({ field }) => (
                                    <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                                        <div className="space-y-0.5">
                                            <FormLabel className="text-base">是否寄卖</FormLabel>
                                        </div>
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="isUseLogisticsService"
                                render={({ field }) => (
                                    <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                                        <div className="space-y-0.5">
                                            <FormLabel className="text-base">使用物流服务</FormLabel>
                                        </div>
                                        <FormControl>
                                            <Switch
                                                checked={field.value}
                                                onCheckedChange={field.onChange}
                                            />
                                        </FormControl>
                                    </FormItem>
                                )}
                            />
                        </div>

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={handleClose}>
                                取消
                            </Button>
                            <Button type="submit" disabled={isPending}>
                                {isPending ? '保存中...' : '保存'}
                            </Button>
                        </DialogFooter>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>
    );
} 