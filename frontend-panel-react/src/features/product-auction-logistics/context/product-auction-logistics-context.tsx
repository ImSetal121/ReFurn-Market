import { createContext, useContext, useState, type ReactNode } from 'react'
import type { ProductAuctionLogistics } from '../data/schema'

type FormMode = 'add' | 'edit'

interface ProductAuctionLogisticsContextType {
    // 选中的记录
    selectedRecord: ProductAuctionLogistics | null
    setSelectedRecord: (record: ProductAuctionLogistics | null) => void

    // 操作对话框状态
    isActionDialogOpen: boolean
    setIsActionDialogOpen: (open: boolean) => void

    // 删除对话框状态
    isDeleteDialogOpen: boolean
    setIsDeleteDialogOpen: (open: boolean) => void

    // 表单模式
    mode: FormMode
    setMode: (mode: FormMode) => void

    // 重置状态
    reset: () => void
}

const ProductAuctionLogisticsContext = createContext<ProductAuctionLogisticsContextType | null>(null)

interface ProductAuctionLogisticsProviderProps {
    children: ReactNode
}

export function ProductAuctionLogisticsProvider({ children }: ProductAuctionLogisticsProviderProps) {
    const [selectedRecord, setSelectedRecord] = useState<ProductAuctionLogistics | null>(null)
    const [isActionDialogOpen, setIsActionDialogOpen] = useState(false)
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
    const [mode, setMode] = useState<FormMode>('add')

    const reset = () => {
        setSelectedRecord(null)
        setIsActionDialogOpen(false)
        setIsDeleteDialogOpen(false)
        setMode('add')
    }

    const value: ProductAuctionLogisticsContextType = {
        selectedRecord,
        setSelectedRecord,
        isActionDialogOpen,
        setIsActionDialogOpen,
        isDeleteDialogOpen,
        setIsDeleteDialogOpen,
        mode,
        setMode,
        reset,
    }

    return (
        <ProductAuctionLogisticsContext.Provider value={value}>
            {children}
        </ProductAuctionLogisticsContext.Provider>
    )
}

export function useProductAuctionLogisticsContext() {
    const context = useContext(ProductAuctionLogisticsContext)
    if (!context) {
        throw new Error('useProductAuctionLogisticsContext must be used within a ProductAuctionLogisticsProvider')
    }
    return context
} 