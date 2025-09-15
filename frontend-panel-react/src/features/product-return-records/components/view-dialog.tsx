import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';

import { useProductReturnRecordContext } from '../context/product-return-record-context';
import { auditResults, freightBearers, compensationBearers, statuses } from '../data/schema';

// 获取状态显示标签
function getStatusLabel(status?: string) {
    return statuses.find(s => s.value === status)?.label || status || '-';
}

// 获取审核结果显示标签
function getAuditResultLabel(result?: string) {
    return auditResults.find(r => r.value === result)?.label || result || '-';
}

// 获取运费承担方显示标签
function getFreightBearerLabel(bearer?: string) {
    return freightBearers.find(b => b.value === bearer)?.label || bearer || '-';
}

// 获取赔偿承担方显示标签
function getCompensationBearerLabel(bearer?: string) {
    return compensationBearers.find(b => b.value === bearer)?.label || bearer || '-';
}

// 格式化时间
function formatDateTime(dateString?: string) {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleString('zh-CN');
}

// 格式化布尔值
function formatBoolean(value?: boolean) {
    if (value === undefined || value === null) return '-';
    return value ? '是' : '否';
}

export function ViewDialog() {
    const {
        viewDialogOpen,
        setViewDialogOpen,
        selectedRecord,
    } = useProductReturnRecordContext();

    const record = selectedRecord;

    if (!record) return null;

    return (
        <Dialog open={viewDialogOpen} onOpenChange={setViewDialogOpen}>
            <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>商品退货记录详情</DialogTitle>
                    <DialogDescription>
                        查看商品退货记录的详细信息
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-6">
                    {/* 基本信息 */}
                    <div>
                        <h3 className="text-lg font-medium mb-4">基本信息</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">记录ID</label>
                                <p className="text-sm">{record.id || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">商品ID</label>
                                <p className="text-sm">{record.productId || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">商品出售记录ID</label>
                                <p className="text-sm">{record.productSellRecordId || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">状态</label>
                                <div className="mt-1">
                                    <Badge variant="outline">{getStatusLabel(record.status)}</Badge>
                                </div>
                            </div>
                        </div>
                    </div>

                    <Separator />

                    {/* 退货信息 */}
                    <div>
                        <h3 className="text-lg font-medium mb-4">退货信息</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">退货原因类型</label>
                                <p className="text-sm">{record.returnReasonType || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">审核结果</label>
                                <div className="mt-1">
                                    <Badge
                                        variant={record.auditResult === 'APPROVED' ? 'default' : record.auditResult === 'REJECTED' ? 'destructive' : 'secondary'}
                                    >
                                        {getAuditResultLabel(record.auditResult)}
                                    </Badge>
                                </div>
                            </div>
                            <div className="md:col-span-2">
                                <label className="text-sm font-medium text-muted-foreground">退货原因详细说明</label>
                                <p className="text-sm mt-1">{record.returnReasonDetail || '-'}</p>
                            </div>
                            <div className="md:col-span-2">
                                <label className="text-sm font-medium text-muted-foreground">取件地址</label>
                                <p className="text-sm mt-1">{record.pickupAddress || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">卖家是否接受退货</label>
                                <div className="mt-1">
                                    <Badge variant={record.sellerAcceptReturn ? 'default' : record.sellerAcceptReturn === false ? 'destructive' : 'secondary'}>
                                        {formatBoolean(record.sellerAcceptReturn)}
                                    </Badge>
                                </div>
                            </div>
                            <div className="md:col-span-2">
                                <label className="text-sm font-medium text-muted-foreground">卖家意见详情</label>
                                <p className="text-sm mt-1">{record.sellerOpinionDetail || '-'}</p>
                            </div>
                            <div className="md:col-span-2">
                                <label className="text-sm font-medium text-muted-foreground">审核详细说明</label>
                                <p className="text-sm mt-1">{record.auditDetail || '-'}</p>
                            </div>
                        </div>
                    </div>

                    <Separator />

                    {/* 承担方信息 */}
                    <div>
                        <h3 className="text-lg font-medium mb-4">承担方信息</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">运费承担方</label>
                                <div className="mt-1">
                                    <Badge variant="outline">{getFreightBearerLabel(record.freightBearer)}</Badge>
                                </div>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">运费承担用户ID</label>
                                <p className="text-sm">{record.freightBearerUserId || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">赔偿承担方</label>
                                <div className="mt-1">
                                    <Badge variant="outline">{getCompensationBearerLabel(record.compensationBearer)}</Badge>
                                </div>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">赔偿承担用户ID</label>
                                <p className="text-sm">{record.compensationBearerUserId || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">需要赔偿商品</label>
                                <div className="mt-1">
                                    <Badge variant={record.needCompensateProduct ? 'destructive' : 'secondary'}>
                                        {formatBoolean(record.needCompensateProduct)}
                                    </Badge>
                                </div>
                            </div>
                        </div>
                    </div>

                    <Separator />

                    {/* 物流信息 */}
                    <div>
                        <h3 className="text-lg font-medium mb-4">物流信息</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">是否寄卖</label>
                                <div className="mt-1">
                                    <Badge variant={record.isAuction ? 'default' : 'secondary'}>
                                        {formatBoolean(record.isAuction)}
                                    </Badge>
                                </div>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">是否使用物流服务</label>
                                <div className="mt-1">
                                    <Badge variant={record.isUseLogisticsService ? 'default' : 'secondary'}>
                                        {formatBoolean(record.isUseLogisticsService)}
                                    </Badge>
                                </div>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">预约取件时间</label>
                                <p className="text-sm">{formatDateTime(record.appointmentPickupTime)}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">内部物流任务ID</label>
                                <p className="text-sm">{record.internalLogisticsTaskId || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">外部物流服务商名称</label>
                                <p className="text-sm">{record.externalLogisticsServiceName || '-'}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">外部物流单号</label>
                                <p className="text-sm">{record.externalLogisticsOrderNumber || '-'}</p>
                            </div>
                        </div>
                    </div>

                    <Separator />

                    {/* 系统信息 */}
                    <div>
                        <h3 className="text-lg font-medium mb-4">系统信息</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">创建时间</label>
                                <p className="text-sm">{formatDateTime(record.createTime)}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">更新时间</label>
                                <p className="text-sm">{formatDateTime(record.updateTime)}</p>
                            </div>
                            <div>
                                <label className="text-sm font-medium text-muted-foreground">是否删除</label>
                                <div className="mt-1">
                                    <Badge variant={record.isDelete ? 'destructive' : 'secondary'}>
                                        {formatBoolean(record.isDelete)}
                                    </Badge>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    );
} 