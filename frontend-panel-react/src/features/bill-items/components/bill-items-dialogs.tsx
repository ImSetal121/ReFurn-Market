import { BillItemsActionDialog } from './bill-items-action-dialog'
import { BillItemsDeleteDialog } from './bill-items-delete-dialog'
import { BillItemsViewDialog } from './bill-items-view-dialog'

export function BillItemsDialogs() {
    return (
        <>
            <BillItemsActionDialog />
            <BillItemsDeleteDialog />
            <BillItemsViewDialog />
        </>
    )
} 