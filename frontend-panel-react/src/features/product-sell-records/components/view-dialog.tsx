import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Badge } from '@/components/ui/badge'
import { statusLabels, statusColors, type ProductSellRecord } from '../data/schema'

interface ProductSellRecordViewDialogProps {
    open: boolean
    onOpenChange: () => void
    currentRow: ProductSellRecord
}

export function ProductSellRecordViewDialog({
    open,
    onOpenChange,
    currentRow,
}: ProductSellRecordViewDialogProps) {
    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="max-w-2xl">
                <DialogHeader>
                    <DialogTitle>销售记录详情</DialogTitle>
                </DialogHeader>
                <div className="space-y-6">
                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">记录ID</label>
                            <div className="font-mono">{currentRow.id}</div>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">状态</label>
                            <div>
                                {currentRow.status ? (
                                    <Badge variant={statusColors[currentRow.status as keyof typeof statusColors] || 'default'}>
                                        {statusLabels[currentRow.status as keyof typeof statusLabels] || currentRow.status}
                                    </Badge>
                                ) : (
                                    <span className="text-muted-foreground">-</span>
                                )}
                            </div>
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">商品信息</label>
                            <div>
                                {currentRow.product ? (
                                    <div>
                                        <div className="font-medium">{currentRow.product.name}</div>
                                        <div className="text-sm text-muted-foreground">ID: {currentRow.product.id}</div>
                                    </div>
                                ) : (
                                    <span className="text-muted-foreground">未关联商品</span>
                                )}
                            </div>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">成交价格</label>
                            <div className="font-mono text-lg">
                                {currentRow.finalProductPrice ? `$${currentRow.finalProductPrice.toFixed(2)}` : '-'}
                            </div>
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">交易类型</label>
                            <div>
                                <Badge variant={currentRow.isAuction ? 'default' : 'secondary'}>
                                    {currentRow.isAuction ? '拍卖' : '直购'}
                                </Badge>
                            </div>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">配送方式</label>
                            <div>
                                <Badge variant="outline">
                                    {currentRow.isSelfPickup ? '自提' : '快递'}
                                </Badge>
                            </div>
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">卖家ID</label>
                            <div className="font-mono">{currentRow.sellerUserId || '-'}</div>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">买家ID</label>
                            <div className="font-mono">{currentRow.buyerUserId || '-'}</div>
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">仓库出货ID</label>
                            <div className="font-mono">{currentRow.productWarehouseShipmentId || '-'}</div>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">内部物流任务ID</label>
                            <div className="font-mono">{currentRow.internalLogisticsTaskId || '-'}</div>
                        </div>
                    </div>

                    {currentRow.isSelfPickup && (
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">自提物流ID</label>
                            <div className="font-mono">{currentRow.productSelfPickupLogisticsId || '-'}</div>
                        </div>
                    )}

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">创建时间</label>
                            <div>
                                {currentRow.createTime ?
                                    new Date(currentRow.createTime).toLocaleString('zh-CN') :
                                    '-'
                                }
                            </div>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-muted-foreground">更新时间</label>
                            <div>
                                {currentRow.updateTime ?
                                    new Date(currentRow.updateTime).toLocaleString('zh-CN') :
                                    '-'
                                }
                            </div>
                        </div>
                    </div>

                    {(currentRow.buyerReceiptImageUrlJson || currentRow.sellerReturnImageUrlJson) && (
                        <div className="space-y-2">
                            <label className="text-sm font-medium text-muted-foreground">附件信息</label>
                            {currentRow.buyerReceiptImageUrlJson && (
                                <div>
                                    <span className="text-sm">买家收货凭证：</span>
                                    <span className="text-sm text-muted-foreground">已上传</span>
                                </div>
                            )}
                            {currentRow.sellerReturnImageUrlJson && (
                                <div>
                                    <span className="text-sm">卖家退货凭证：</span>
                                    <span className="text-sm text-muted-foreground">已上传</span>
                                </div>
                            )}
                        </div>
                    )}
                </div>
            </DialogContent>
        </Dialog>
    )
} 