import { createContext, useContext, useState, type ReactNode } from 'react'
import type { WarehouseStock } from '../data/schema'

type FormMode = 'add' | 'edit'

interface WarehouseStockContextType {
    // 选中的记录
    selectedRecord: WarehouseStock | null
    setSelectedRecord: (record: WarehouseStock | null) => void

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

const WarehouseStockContext = createContext<WarehouseStockContextType | null>(null)

interface WarehouseStockProviderProps {
    children: ReactNode
}

export function WarehouseStockProvider({ children }: WarehouseStockProviderProps) {
    const [selectedRecord, setSelectedRecord] = useState<WarehouseStock | null>(null)
    const [isActionDialogOpen, setIsActionDialogOpen] = useState(false)
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
    const [mode, setMode] = useState<FormMode>('add')

    const reset = () => {
        setSelectedRecord(null)
        setIsActionDialogOpen(false)
        setIsDeleteDialogOpen(false)
        setMode('add')
    }

    const value: WarehouseStockContextType = {
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
        <WarehouseStockContext.Provider value={value}>
            {children}
        </WarehouseStockContext.Provider>
    )
}

export function useWarehouseStockContext() {
    const context = useContext(WarehouseStockContext)
    if (!context) {
        throw new Error('useWarehouseStockContext must be used within a WarehouseStockProvider')
    }
    return context
} 