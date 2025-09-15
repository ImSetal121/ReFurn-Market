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
import { useProductAuctionLogisticsContext } from '../context/product-auction-logistics-context'
import { useDeleteProductAuctionLogistics } from '../data/product-auction-logistics-service'

export function ProductAuctionLogisticsDeleteDialog() {
    const {
        selectedRecord,
        isDeleteDialogOpen,
        setIsDeleteDialogOpen,
        reset,
    } = useProductAuctionLogisticsContext()

    const deleteMutation = useDeleteProductAuctionLogistics()

    const handleConfirmDelete = async () => {
        if (selectedRecord?.id) {
            try {
                await deleteMutation.mutateAsync(selectedRecord.id)
                handleClose()
            } catch (_error) {
                // 错误已经在mutation中处理
            }
        }
    }

    const handleClose = () => {
        setIsDeleteDialogOpen(false)
        reset()
    }

    return (
        <AlertDialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>确认删除</AlertDialogTitle>
                    <AlertDialogDescription>
                        您确定要删除这条寄卖物流记录吗？此操作无法撤销。
                        {selectedRecord && (
                            <div className="mt-2 p-2 bg-muted rounded text-sm">
                                记录ID: {selectedRecord.id}
                                {selectedRecord.externalLogisticsOrderNumber && (
                                    <>
                                        <br />
                                        物流单号: {selectedRecord.externalLogisticsOrderNumber}
                                    </>
                                )}
                            </div>
                        )}
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel onClick={handleClose}>取消</AlertDialogCancel>
                    <AlertDialogAction
                        onClick={handleConfirmDelete}
                        disabled={deleteMutation.isPending}
                        className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                    >
                        {deleteMutation.isPending ? '删除中...' : '确认删除'}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    )
} 