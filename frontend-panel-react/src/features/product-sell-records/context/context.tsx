import React, { useState } from 'react'
import useDialogState from '@/hooks/use-dialog-state'
import type { ProductSellRecord } from '../data/schema'

type ProductSellRecordsDialogType = 'add' | 'edit' | 'delete' | 'view'

interface ProductSellRecordsContextType {
    open: ProductSellRecordsDialogType | null
    setOpen: (str: ProductSellRecordsDialogType | null) => void
    currentRow: ProductSellRecord | null
    setCurrentRow: React.Dispatch<React.SetStateAction<ProductSellRecord | null>>
}

const ProductSellRecordsContext = React.createContext<ProductSellRecordsContextType | null>(null)

interface Props {
    children: React.ReactNode
}

export default function ProductSellRecordsProvider({ children }: Props) {
    const [open, setOpen] = useDialogState<ProductSellRecordsDialogType>(null)
    const [currentRow, setCurrentRow] = useState<ProductSellRecord | null>(null)

    return (
        <ProductSellRecordsContext.Provider value={{
            open,
            setOpen,
            currentRow,
            setCurrentRow,
        }}>
            {children}
        </ProductSellRecordsContext.Provider>
    )
}

export const useProductSellRecords = () => {
    const context = React.useContext(ProductSellRecordsContext)

    if (!context) {
        throw new Error('useProductSellRecords has to be used within <ProductSellRecordsContext>')
    }

    return context
} 