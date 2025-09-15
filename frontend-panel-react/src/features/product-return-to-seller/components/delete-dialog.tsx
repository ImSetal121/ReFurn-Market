import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { useProductReturnToSellerContext } from '../context/product-return-to-seller-context';
import { useDeleteProductReturnToSellerRecord } from '../data/product-return-to-seller-service';

export function DeleteDialog() {
    const {
        deleteDialogOpen,
        setDeleteDialogOpen,
        selectedRecord,
        setSelectedRecord,
    } = useProductReturnToSellerContext();

    const deleteMutation = useDeleteProductReturnToSellerRecord();

    const handleDelete = async () => {
        if (selectedRecord?.id) {
            try {
                await deleteMutation.mutateAsync(selectedRecord.id);
                setDeleteDialogOpen(false);
                setSelectedRecord(null);
            } catch (error) {
                // 错误处理已在 mutation 中进行
            }
        }
    };

    const handleClose = () => {
        setDeleteDialogOpen(false);
        setSelectedRecord(null);
    };

    return (
        <AlertDialog open={deleteDialogOpen} onOpenChange={handleClose}>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>确认删除</AlertDialogTitle>
                    <AlertDialogDescription>
                        您确定要删除这条商品退回卖家记录吗？此操作无法撤销。
                        {selectedRecord && (
                            <div className="mt-2 p-2 bg-muted rounded text-sm">
                                记录ID: {selectedRecord.id}
                            </div>
                        )}
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel onClick={handleClose}>取消</AlertDialogCancel>
                    <AlertDialogAction
                        onClick={handleDelete}
                        disabled={deleteMutation.isPending}
                        className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                    >
                        {deleteMutation.isPending ? '删除中...' : '确认删除'}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    );
} 