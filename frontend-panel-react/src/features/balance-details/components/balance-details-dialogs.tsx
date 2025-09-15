import { BalanceDetailsActionDialog } from './balance-details-action-dialog'
import { BalanceDetailsDeleteDialog } from './balance-details-delete-dialog'
import { BalanceDetailsViewDialog } from './balance-details-view-dialog'

export function BalanceDetailsDialogs() {
    return (
        <>
            <BalanceDetailsActionDialog />
            <BalanceDetailsDeleteDialog />
            <BalanceDetailsViewDialog />
        </>
    )
} 