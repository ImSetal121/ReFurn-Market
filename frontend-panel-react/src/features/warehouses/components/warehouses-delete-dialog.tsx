import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { useWarehousesContext } from '../context/warehouses-context'
import { useDeleteWarehouse } from '../data/warehouses-service'

export function WarehousesDeleteDialog() {
    const {
        isDeleteDialogOpen,
        currentWarehouse,
        closeAllDialogs,
    } = useWarehousesContext()

    const deleteMutation = useDeleteWarehouse()

    const handleDelete = async () => {
        if (currentWarehouse?.id) {
            try {
                await deleteMutation.mutateAsync(currentWarehouse.id)
                closeAllDialogs()
            } catch {
                // 错误已在mutation中处理
            }
        }
    }

    return (
        <Dialog open={isDeleteDialogOpen} onOpenChange={closeAllDialogs}>
            <DialogContent className='sm:max-w-[425px]'>
                <DialogHeader>
                    <DialogTitle>删除仓库</DialogTitle>
                    <DialogDescription>
                        确定要删除仓库 "{currentWarehouse?.name}" 吗？此操作不可撤销。
                    </DialogDescription>
                </DialogHeader>

                <DialogFooter>
                    <Button variant='outline' onClick={closeAllDialogs}>
                        取消
                    </Button>
                    <Button
                        variant='destructive'
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