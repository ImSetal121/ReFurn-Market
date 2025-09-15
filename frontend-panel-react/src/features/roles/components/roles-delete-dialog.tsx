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
import { useRolesContext } from '../context/roles-context'
import { useDeleteRole } from '../data/roles-service'

interface RolesDeleteDialogProps {
    open: boolean
    onOpenChange: (open: boolean) => void
}

export function RolesDeleteDialog({ open, onOpenChange }: RolesDeleteDialogProps) {
    const { currentRole } = useRolesContext()
    const deleteRole = useDeleteRole()

    const handleDelete = async () => {
        if (currentRole?.id) {
            try {
                await deleteRole.mutateAsync(currentRole.id)
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
                    <AlertDialogTitle>确认删除角色</AlertDialogTitle>
                    <AlertDialogDescription>
                        您确定要删除角色 "{currentRole?.name}" 吗？此操作无法撤销。
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel disabled={deleteRole.isPending}>
                        取消
                    </AlertDialogCancel>
                    <AlertDialogAction
                        onClick={handleDelete}
                        disabled={deleteRole.isPending}
                        className='bg-red-600 hover:bg-red-700'
                    >
                        {deleteRole.isPending ? '删除中...' : '确认删除'}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    )
} 