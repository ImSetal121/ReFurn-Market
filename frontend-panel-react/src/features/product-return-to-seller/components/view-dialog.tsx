import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { useProductReturnToSellerContext } from '../context/product-return-to-seller-context';
import { statuses } from '../data/schema';

export function ViewDialog() {
    const {
        viewDialogOpen,
        setViewDialogOpen,
        selectedRecord,
        setSelectedRecord,
    } = useProductReturnToSellerContext();

    const handleClose = () => {
        setViewDialogOpen(false);
        setSelectedRecord(null);
    };

    if (!selectedRecord) return null;

    const statusInfo = statuses.find((s) => s.value === selectedRecord.status);

    return (
        <Dialog open={viewDialogOpen} onOpenChange={handleClose}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>商品退回卖家记录详情</DialogTitle>
                    <DialogDescription>
                        查看商品退回卖家记录的详细信息
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">记录ID</h4>
                            <p className="text-sm">{selectedRecord.id || '-'}</p>
                        </div>
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">商品ID</h4>
                            <p className="text-sm">{selectedRecord.productId || '-'}</p>
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">销售记录ID</h4>
                            <p className="text-sm">{selectedRecord.productSellRecordId || '-'}</p>
                        </div>
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">仓库ID</h4>
                            <p className="text-sm">{selectedRecord.warehouseId || '-'}</p>
                        </div>
                    </div>

                    <div>
                        <h4 className="text-sm font-medium text-muted-foreground">仓库地址</h4>
                        <p className="text-sm break-words">{selectedRecord.warehouseAddress || '-'}</p>
                    </div>

                    <div>
                        <h4 className="text-sm font-medium text-muted-foreground">卖家收货地址</h4>
                        <p className="text-sm break-words">{selectedRecord.sellerReceiptAddress || '-'}</p>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">物流任务ID</h4>
                            <p className="text-sm">{selectedRecord.internalLogisticsTaskId || '-'}</p>
                        </div>
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">状态</h4>
                            <Badge variant="outline">
                                {statusInfo?.label || selectedRecord.status || '-'}
                            </Badge>
                        </div>
                    </div>

                    <div>
                        <h4 className="text-sm font-medium text-muted-foreground">发货时间</h4>
                        <p className="text-sm">
                            {selectedRecord.shipmentTime
                                ? new Date(selectedRecord.shipmentTime).toLocaleString('zh-CN')
                                : '-'}
                        </p>
                    </div>

                    {selectedRecord.shipmentImageUrlJson && (
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">发货图片JSON</h4>
                            <pre className="text-xs bg-muted p-2 rounded overflow-x-auto">
                                {selectedRecord.shipmentImageUrlJson}
                            </pre>
                        </div>
                    )}

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">创建时间</h4>
                            <p className="text-sm">
                                {selectedRecord.createTime
                                    ? new Date(selectedRecord.createTime).toLocaleString('zh-CN')
                                    : '-'}
                            </p>
                        </div>
                        <div>
                            <h4 className="text-sm font-medium text-muted-foreground">更新时间</h4>
                            <p className="text-sm">
                                {selectedRecord.updateTime
                                    ? new Date(selectedRecord.updateTime).toLocaleString('zh-CN')
                                    : '-'}
                            </p>
                        </div>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    );
} 