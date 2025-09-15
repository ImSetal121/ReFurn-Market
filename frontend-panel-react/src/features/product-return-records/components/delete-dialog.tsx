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

import { useProductReturnRecordContext } from '../context/product-return-record-context';
import { useDeleteProductReturnRecord } from '../data/product-return-record-service';

export function DeleteDialog() {
    const {
        deleteDialogOpen,
        setDeleteDialogOpen,
        selectedRecord,
        setSelectedRecord,
    } = useProductReturnRecordContext();

    const deleteMutation = useDeleteProductReturnRecord();

    const handleDelete = () => {
        if (selectedRecord?.id) {
            deleteMutation.mutate(selectedRecord.id, {
                onSuccess: () => {
                    setDeleteDialogOpen(false);
                    setSelectedRecord(null);
                },
            });
        }
    };

    return (
        <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>确认删除</AlertDialogTitle>
                    <AlertDialogDescription>
                        您确定要删除这条商品退货记录吗？此操作无法撤销。
                        <br />
                        <br />
                        记录ID: {selectedRecord?.id}
                        {selectedRecord?.returnReasonType && (
                            <>
                                <br />
                                退货原因类型: {selectedRecord.returnReasonType}
                            </>
                        )}
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel>取消</AlertDialogCancel>
                    <AlertDialogAction
                        onClick={handleDelete}
                        disabled={deleteMutation.isPending}
                        className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                    >
                        {deleteMutation.isPending ? '删除中...' : '删除'}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    );
} 