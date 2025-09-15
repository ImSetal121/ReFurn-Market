import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { useBillItems } from '../context/bill-items-context'
import { useDeleteBillItem, useBatchDeleteBillItems } from '../data/bill-items-service'
import { getCostTypeName, getBillStatusName } from '../data/schema'

export function BillItemsDeleteDialog() {
    const { open, setOpen, currentRow } = useBillItems()
    const deleteMutation = useDeleteBillItem()
    const batchDeleteMutation = useBatchDeleteBillItems()

    const isOpen = open === 'delete'
    const isBatchDelete = currentRow && 'ids' in currentRow
    const isLoading = deleteMutation.isPending || batchDeleteMutation.isPending

    const handleDelete = async () => {
        try {
            if (isBatchDelete) {
                const batchData = currentRow as { ids: number[] }
                await batchDeleteMutation.mutateAsync(batchData.ids)
            } else if (currentRow?.id) {
                await deleteMutation.mutateAsync(currentRow.id)
            }
            handleClose()
        } catch {
            // 错误处理已在service中完成
        }
    }

    const handleClose = () => {
        setOpen(null)
    }

    return (
        <Dialog open={isOpen} onOpenChange={() => !isLoading && handleClose()}>
            <DialogContent className='sm:max-w-[425px]'>
                <DialogHeader>
                    <DialogTitle>确认删除</DialogTitle>
                    <DialogDescription>
                        {isBatchDelete
                            ? `您确定要删除选中的 ${(currentRow as { ids: number[] })?.ids?.length || 0} 个账单项吗？`
                            : '您确定要删除这个账单项吗？'
                        }
                        此操作无法撤销。
                    </DialogDescription>
                </DialogHeader>

                {currentRow && !isBatchDelete && (
                    <div className='py-4'>
                        <div className='space-y-2 text-sm'>
                            <div><strong>ID:</strong> {currentRow.id}</div>
                            {currentRow.costType && (
                                <div><strong>费用类型:</strong> {getCostTypeName(currentRow.costType)}</div>
                            )}
                            {currentRow.costDescription && (
                                <div><strong>费用描述:</strong> {currentRow.costDescription}</div>
                            )}
                            {currentRow.cost && (
                                <div><strong>费用金额:</strong> ¥{currentRow.cost.toFixed(2)}</div>
                            )}
                            {currentRow.status && (
                                <div><strong>状态:</strong> {getBillStatusName(currentRow.status)}</div>
                            )}
                            {currentRow.paySubject && (
                                <div><strong>支付主体:</strong> {currentRow.paySubject}</div>
                            )}
                        </div>
                    </div>
                )}

                <DialogFooter>
                    <Button variant='outline' onClick={handleClose} disabled={isLoading}>
                        取消
                    </Button>
                    <Button
                        variant='destructive'
                        onClick={handleDelete}
                        disabled={isLoading}
                    >
                        {isLoading ? '删除中...' : '确认删除'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
} 