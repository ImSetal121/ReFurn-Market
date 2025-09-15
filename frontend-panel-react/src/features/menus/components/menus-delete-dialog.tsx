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
import { useMenusContext } from '../context/menus-context'
import { useDeleteMenu } from '../data/menus-service'

interface MenusDeleteDialogProps {
    open: boolean
    onOpenChange: (open: boolean) => void
}

export function MenusDeleteDialog({ open, onOpenChange }: MenusDeleteDialogProps) {
    const { editingMenu } = useMenusContext()
    const deleteMenu = useDeleteMenu()

    const handleDelete = async () => {
        if (editingMenu?.id) {
            try {
                await deleteMenu.mutateAsync(editingMenu.id)
                onOpenChange(false)
            } catch (_error) {
                // 错误处理已在service中完成
            }
        }
    }

    return (
        <AlertDialog open={open} onOpenChange={onOpenChange}>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>确认删除菜单</AlertDialogTitle>
                    <AlertDialogDescription>
                        您确定要删除菜单 "{editingMenu?.menuName}" 吗？此操作无法撤销。
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel disabled={deleteMenu.isPending}>
                        取消
                    </AlertDialogCancel>
                    <AlertDialogAction
                        onClick={handleDelete}
                        disabled={deleteMenu.isPending}
                        className='bg-red-600 hover:bg-red-700'
                    >
                        {deleteMenu.isPending ? '删除中...' : '确认删除'}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    )
} 