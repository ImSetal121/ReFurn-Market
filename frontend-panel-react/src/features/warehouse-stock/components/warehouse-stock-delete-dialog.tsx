import { Button } from '@/components/ui/button'
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle
} from '@/components/ui/alert-dialog'
import { useWarehouseStockContext } from '../context/warehouse-stock-context'
import { useDeleteWarehouseStock } from '../data/warehouse-stock-service'

export function WarehouseStockDeleteDialog() {
    const {
        isDeleteDialogOpen,
        setIsDeleteDialogOpen,
        selectedRecord,
        reset
    } = useWarehouseStockContext()

    const deleteMutation = useDeleteWarehouseStock()

    const handleDelete = async () => {
        if (!selectedRecord?.id) return

        try {
            await deleteMutation.mutateAsync(selectedRecord.id)
            onClose()
        } catch (error) {
            console.error('删除失败:', error)
        }
    }

    const onClose = () => {
        setIsDeleteDialogOpen(false)
        setTimeout(() => {
            reset()
        }, 200)
    }

    return (
        <AlertDialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>确认删除</AlertDialogTitle>
                    <AlertDialogDescription className="space-y-2">
                        <div>您确定要删除这条仓库库存记录吗？此操作无法撤销。</div>
                        {selectedRecord && (
                            <div className="bg-muted p-3 rounded-md text-sm">
                                <div><strong>ID:</strong> {selectedRecord.id}</div>
                                <div><strong>仓库ID:</strong> {selectedRecord.warehouseId}</div>
                                <div><strong>商品ID:</strong> {selectedRecord.productId}</div>
                                <div><strong>库存数量:</strong> {selectedRecord.stockQuantity}</div>
                                <div><strong>状态:</strong> {selectedRecord.status === 'IN_STOCK' ? '库存中' : '已出库'}</div>
                            </div>
                        )}
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel onClick={onClose} disabled={deleteMutation.isPending}>
                        取消
                    </AlertDialogCancel>
                    <AlertDialogAction asChild>
                        <Button
                            variant="destructive"
                            onClick={handleDelete}
                            disabled={deleteMutation.isPending}
                        >
                            {deleteMutation.isPending ? '删除中...' : '确认删除'}
                        </Button>
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    )
} 