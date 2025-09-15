import { useRolesContext } from '../context/roles-context'
import { RolesActionDialog } from './roles-action-dialog'
import { RolesDeleteDialog } from './roles-delete-dialog'
import { RoleMenuDialog } from './role-menu-dialog'

export function RolesDialogs() {
    const {
        actionDialogOpen,
        setActionDialogOpen,
        deleteDialogOpen,
        setDeleteDialogOpen,
        menuDialogOpen,
        setMenuDialogOpen,
        currentRole,
    } = useRolesContext()

    return (
        <>
            <RolesActionDialog
                currentRole={currentRole}
                open={actionDialogOpen}
                onOpenChange={setActionDialogOpen}
            />
            <RolesDeleteDialog
                open={deleteDialogOpen}
                onOpenChange={setDeleteDialogOpen}
            />
            <RoleMenuDialog
                open={menuDialogOpen}
                onOpenChange={setMenuDialogOpen}
            />
        </>
    )
} 