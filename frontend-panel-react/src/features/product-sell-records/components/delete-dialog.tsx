import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { useDeleteProductSellRecord } from '../data/service'
import type { ProductSellRecord } from '../data/schema'

interface ProductSellRecordDeleteDialogProps {
    open: boolean
    onOpenChange: () => void
    currentRow: ProductSellRecord
}

export function ProductSellRecordDeleteDialog({
    open,
    onOpenChange,
    currentRow,
}: ProductSellRecordDeleteDialogProps) {
    const deleteRecord = useDeleteProductSellRecord()

    const handleDelete = async () => {
        if (currentRow.id) {
            await deleteRecord.mutateAsync(currentRow.id)
            onOpenChange()
        }
    }

    return (
        <AlertDialog open={open} onOpenChange={onOpenChange}>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>确认删除</AlertDialogTitle>
                    <AlertDialogDescription>
                        您确定要删除ID为 <strong>{currentRow.id}</strong> 的销售记录吗？
                        此操作无法撤销。
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel>取消</AlertDialogCancel>
                    <AlertDialogAction
                        onClick={handleDelete}
                        disabled={deleteRecord.isPending}
                    >
                        {deleteRecord.isPending ? '删除中...' : '确认删除'}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    )
} 