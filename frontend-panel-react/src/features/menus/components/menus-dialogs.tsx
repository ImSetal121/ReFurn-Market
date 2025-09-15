import { useMenusContext } from '../context/menus-context'
import { MenusActionDialog } from './menus-action-dialog'
import { MenusDeleteDialog } from './menus-delete-dialog'

export function MenusDialogs() {
    const {
        isCreateDialogOpen,
        setIsCreateDialogOpen,
        isEditDialogOpen,
        setIsEditDialogOpen,
        isDeleteDialogOpen,
        setIsDeleteDialogOpen,
        editingMenu,
    } = useMenusContext()

    return (
        <>
            <MenusActionDialog
                menu={null}
                open={isCreateDialogOpen}
                onOpenChange={setIsCreateDialogOpen}
            />
            <MenusActionDialog
                menu={editingMenu}
                open={isEditDialogOpen}
                onOpenChange={setIsEditDialogOpen}
            />
            <MenusDeleteDialog
                open={isDeleteDialogOpen}
                onOpenChange={setIsDeleteDialogOpen}
            />
        </>
    )
} 