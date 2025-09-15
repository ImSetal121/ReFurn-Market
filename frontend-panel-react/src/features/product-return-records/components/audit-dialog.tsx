import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
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
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from '@/components/ui/form';

import { Textarea } from '@/components/ui/textarea';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { useProductReturnRecordContext } from '../context/product-return-record-context';
import { auditResults, freightBearers, compensationBearers } from '../data/schema';
import { Badge } from '@/components/ui/badge';
import { PlatformController, type AuditReturnRequest } from '@/api/PlatformController';
import { useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';

// 审核表单模式
const auditFormSchema = z.object({
    auditResult: z.enum(['REJECTED', 'APPROVED'], {
        required_error: '请选择审核结果',
    }),
    auditDetail: z.string().min(1, '请输入审核详细说明'),
    freightBearer: z.enum(['SELLER', 'BUYER', 'PLATFORM'], {
        required_error: '请选择运费承担方',
    }),
    needCompensateProduct: z.boolean(),
    compensationBearer: z.enum(['SELLER', 'BUYER', 'PLATFORM']).optional(),
}).refine((data) => {
    // 如果需要赔偿商品，则赔偿承担方必须选择
    if (data.needCompensateProduct && !data.compensationBearer) {
        return false;
    }
    return true;
}, {
    message: '当需要赔偿商品时，必须选择赔偿承担方',
    path: ['compensationBearer'],
});

type AuditFormValues = z.infer<typeof auditFormSchema>;

export function AuditDialog() {
    const {
        auditDialogOpen,
        setAuditDialogOpen,
        selectedRecord,
    } = useProductReturnRecordContext();

    const queryClient = useQueryClient();

    const form = useForm<AuditFormValues>({
        resolver: zodResolver(auditFormSchema),
        defaultValues: {
            auditResult: undefined,
            auditDetail: '',
            freightBearer: undefined,
            needCompensateProduct: false,
            compensationBearer: undefined,
        },
    });

    const watchNeedCompensate = form.watch('needCompensateProduct');

    useEffect(() => {
        if (auditDialogOpen && selectedRecord) {
            // 重置表单
            form.reset({
                auditResult: undefined,
                auditDetail: '',
                freightBearer: undefined,
                needCompensateProduct: false,
                compensationBearer: undefined,
            });
        }
    }, [auditDialogOpen, selectedRecord, form]);

    const onSubmit = async (values: AuditFormValues) => {
        if (!selectedRecord?.id) {
            toast.error('记录ID不存在');
            return;
        }

        try {
            // 调用平台审批API
            const auditRequest: AuditReturnRequest = {
                returnRecordId: selectedRecord.id!,
                auditResult: values.auditResult,
                auditDetail: values.auditDetail,
                freightBearer: values.freightBearer,
                needCompensateProduct: values.needCompensateProduct,
                compensationBearer: values.needCompensateProduct ? values.compensationBearer : undefined,
            };

            await PlatformController.auditReturnRequest(auditRequest);

            // 关闭对话框
            setAuditDialogOpen(false);

            // 刷新数据
            queryClient.invalidateQueries({ queryKey: ['productReturnRecords'] });

            // 显示成功消息
            toast.success(`审核${values.auditResult === 'APPROVED' ? '通过' : '拒绝'}成功`);
        } catch (_error) {
            toast.error('审核失败，请稍后重试');
        }
    };

    const handleClose = () => {
        setAuditDialogOpen(false);
        form.reset();
    };

    if (!selectedRecord) {
        return null;
    }

    return (
        <Dialog open={auditDialogOpen} onOpenChange={setAuditDialogOpen}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>审核退货申请</DialogTitle>
                    <DialogDescription>
                        请审核用户的退货申请，设置审核结果和相关条件
                    </DialogDescription>
                </DialogHeader>

                {/* 显示退货信息 */}
                <div className="space-y-4 p-4 bg-muted/50 rounded-lg">
                    <h4 className="font-medium">退货信息</h4>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                            <span className="text-muted-foreground">退货原因类型：</span>
                            <span className="font-medium">{selectedRecord.returnReasonType || '-'}</span>
                        </div>
                        <div>
                            <span className="text-muted-foreground">当前状态：</span>
                            <Badge variant="destructive" className="ml-2">
                                退货协商不一致
                            </Badge>
                        </div>
                        <div className="col-span-2">
                            <span className="text-muted-foreground">退货原因详细说明：</span>
                            <p className="mt-1 p-2 bg-background rounded border">
                                {selectedRecord.returnReasonDetail || '无详细说明'}
                            </p>
                        </div>
                        {selectedRecord.sellerOpinionDetail && (
                            <div className="col-span-2">
                                <span className="text-muted-foreground">卖家意见：</span>
                                <p className="mt-1 p-2 bg-background rounded border">
                                    {selectedRecord.sellerOpinionDetail}
                                </p>
                            </div>
                        )}
                    </div>
                </div>

                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                        {/* 审核结果 */}
                        <FormField
                            control={form.control}
                            name="auditResult"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>审核结果 *</FormLabel>
                                    <Select onValueChange={field.onChange} defaultValue={field.value}>
                                        <FormControl>
                                            <SelectTrigger>
                                                <SelectValue placeholder="请选择审核结果" />
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
                                    <FormDescription>
                                        选择是否同意用户的退货申请
                                    </FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        {/* 审核详细说明 */}
                        <FormField
                            control={form.control}
                            name="auditDetail"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>审核详细说明 *</FormLabel>
                                    <FormControl>
                                        <Textarea
                                            placeholder="请输入审核的详细说明和理由..."
                                            className="min-h-[100px]"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormDescription>
                                        请详细说明审核的理由和依据
                                    </FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        {/* 运费承担方 */}
                        <FormField
                            control={form.control}
                            name="freightBearer"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>运费承担方 *</FormLabel>
                                    <Select onValueChange={field.onChange} defaultValue={field.value}>
                                        <FormControl>
                                            <SelectTrigger>
                                                <SelectValue placeholder="请选择运费承担方" />
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
                                    <FormDescription>
                                        指定退货过程中的运费由谁承担
                                    </FormDescription>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        {/* 是否需要赔偿商品 */}
                        <FormField
                            control={form.control}
                            name="needCompensateProduct"
                            render={({ field }) => (
                                <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                                    <div className="space-y-0.5">
                                        <FormLabel className="text-base">
                                            是否需要赔偿商品
                                        </FormLabel>
                                        <FormDescription>
                                            如果商品在退货过程中损坏或丢失，是否需要赔偿
                                        </FormDescription>
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

                        {/* 赔偿承担方 - 只有当需要赔偿时才显示 */}
                        {watchNeedCompensate && (
                            <FormField
                                control={form.control}
                                name="compensationBearer"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>赔偿承担方 *</FormLabel>
                                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="请选择赔偿承担方" />
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
                                        <FormDescription>
                                            指定商品赔偿责任由谁承担
                                        </FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        )}

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={handleClose}>
                                取消
                            </Button>
                            <Button type="submit">
                                提交审核
                            </Button>
                        </DialogFooter>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>
    );
} 