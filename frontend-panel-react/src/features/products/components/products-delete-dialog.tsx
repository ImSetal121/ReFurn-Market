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
import { useProductsContext } from '../context/products-context'
import { useDeleteProduct } from '../data/products-service'

export function ProductsDeleteDialog() {
    const {
        isDeleteDialogOpen,
        setIsDeleteDialogOpen,
        selectedProduct,
        reset,
    } = useProductsContext()

    const deleteProductMutation = useDeleteProduct()

    const handleDelete = async () => {
        if (selectedProduct?.id) {
            try {
                await deleteProductMutation.mutateAsync(selectedProduct.id)
                setIsDeleteDialogOpen(false)
                reset()
            } catch (_error) {
                // 错误已经在mutation中处理
            }
        }
    }

    return (
        <AlertDialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>确认删除</AlertDialogTitle>
                    <AlertDialogDescription>
                        您确定要删除商品 "{selectedProduct?.name}" 吗？此操作无法撤销。
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel onClick={() => setIsDeleteDialogOpen(false)}>
                        取消
                    </AlertDialogCancel>
                    <AlertDialogAction
                        onClick={handleDelete}
                        disabled={deleteProductMutation.isPending}
                        className="bg-red-600 hover:bg-red-700"
                    >
                        {deleteProductMutation.isPending ? '删除中...' : '删除'}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    )
} 