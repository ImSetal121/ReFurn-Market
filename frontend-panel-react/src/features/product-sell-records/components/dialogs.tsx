import { useProductSellRecords } from '../context/context'
import { ProductSellRecordActionDialog } from './action-dialog'
import { ProductSellRecordDeleteDialog } from './delete-dialog'
import { ProductSellRecordViewDialog } from './view-dialog'

export function ProductSellRecordsDialogs() {
    const { open, setOpen, currentRow, setCurrentRow } = useProductSellRecords()

    return (
        <>
            <ProductSellRecordActionDialog
                key='record-add'
                open={open === 'add'}
                onOpenChange={() => setOpen('add')}
            />

            {currentRow && (
                <>
                    <ProductSellRecordActionDialog
                        key={`record-edit-${currentRow.id}`}
                        open={open === 'edit'}
                        onOpenChange={() => {
                            setOpen('edit')
                            setTimeout(() => {
                                setCurrentRow(null)
                            }, 500)
                        }}
                        currentRow={currentRow}
                    />

                    <ProductSellRecordDeleteDialog
                        key={`record-delete-${currentRow.id}`}
                        open={open === 'delete'}
                        onOpenChange={() => {
                            setOpen('delete')
                            setTimeout(() => {
                                setCurrentRow(null)
                            }, 500)
                        }}
                        currentRow={currentRow}
                    />

                    <ProductSellRecordViewDialog
                        key={`record-view-${currentRow.id}`}
                        open={open === 'view'}
                        onOpenChange={() => {
                            setOpen('view')
                            setTimeout(() => {
                                setCurrentRow(null)
                            }, 500)
                        }}
                        currentRow={currentRow}
                    />
                </>
            )}
        </>
    )
} 