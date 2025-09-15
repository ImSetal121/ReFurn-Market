import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { useInternalLogisticsTaskContext } from '../context/internal-logistics-task-context'
import { useDeleteInternalLogisticsTask } from '../data/internal-logistics-task-service'
import { TASK_TYPE_MAP } from '../data/schema'

export function InternalLogisticsTaskDeleteDialog() {
    const {
        isDeleteDialogOpen,
        setIsDeleteDialogOpen,
        selectedRecord,
        reset
    } = useInternalLogisticsTaskContext()

    const deleteMutation = useDeleteInternalLogisticsTask()

    const handleDelete = async () => {
        if (!selectedRecord?.id) return

        try {
            await deleteMutation.mutateAsync(selectedRecord.id)
            onClose()
        } catch (_error) {
            // 错误已在service层处理
        }
    }

    const onClose = () => {
        setIsDeleteDialogOpen(false)
        setTimeout(() => {
            reset()
        }, 200)
    }

    return (
        <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>确认删除</DialogTitle>
                    <DialogDescription>
                        您确定要删除这条内部物流任务记录吗？此操作无法撤销。
                    </DialogDescription>
                </DialogHeader>

                {selectedRecord && (
                    <div className="py-4">
                        <div className="space-y-2 text-sm">
                            <div><strong>任务ID:</strong> {selectedRecord.id}</div>
                            {selectedRecord.taskType && (
                                <div><strong>任务类型:</strong> {TASK_TYPE_MAP[selectedRecord.taskType as keyof typeof TASK_TYPE_MAP]}</div>
                            )}
                            {selectedRecord.productId && (
                                <div><strong>商品ID:</strong> {selectedRecord.productId}</div>
                            )}
                            {selectedRecord.logisticsUserId && (
                                <div><strong>物流员ID:</strong> {selectedRecord.logisticsUserId}</div>
                            )}
                            {selectedRecord.sourceAddress && (
                                <div><strong>起始地址:</strong> {selectedRecord.sourceAddress}</div>
                            )}
                            {selectedRecord.targetAddress && (
                                <div><strong>目标地址:</strong> {selectedRecord.targetAddress}</div>
                            )}
                            {selectedRecord.logisticsCost && (
                                <div><strong>物流费用:</strong> ¥{selectedRecord.logisticsCost}</div>
                            )}
                        </div>
                    </div>
                )}

                <DialogFooter>
                    <Button
                        variant="outline"
                        onClick={onClose}
                        disabled={deleteMutation.isPending}
                    >
                        取消
                    </Button>
                    <Button
                        variant="destructive"
                        onClick={handleDelete}
                        disabled={deleteMutation.isPending}
                    >
                        {deleteMutation.isPending ? '删除中...' : '确认删除'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
} 