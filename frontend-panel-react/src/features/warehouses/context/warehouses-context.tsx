import React, { createContext, useContext, useState, ReactNode } from 'react'
import type { RfWarehouse } from '@/api/RfWarehouseController'

interface WarehousesContextValue {
    // 对话框状态
    isCreateDialogOpen: boolean
    isUpdateDialogOpen: boolean
    isDeleteDialogOpen: boolean

    // 当前操作的仓库
    currentWarehouse: RfWarehouse | null

    // 选中的仓库IDs
    selectedWarehouseIds: number[]

    // 状态更新方法
    setCreateDialogOpen: (open: boolean) => void
    setUpdateDialogOpen: (open: boolean) => void
    setDeleteDialogOpen: (open: boolean) => void
    setCurrentWarehouse: (warehouse: RfWarehouse | null) => void
    setSelectedWarehouseIds: (ids: number[]) => void

    // 操作方法
    openCreateDialog: () => void
    openUpdateDialog: (warehouse: RfWarehouse) => void
    openDeleteDialog: (warehouse: RfWarehouse) => void
    closeAllDialogs: () => void
}

const WarehousesContext = createContext<WarehousesContextValue | undefined>(undefined)

export function useWarehousesContext() {
    const context = useContext(WarehousesContext)
    if (!context) {
        throw new Error('useWarehousesContext must be used within a WarehousesProvider')
    }
    return context
}

interface WarehousesProviderProps {
    children: ReactNode
}

export default function WarehousesProvider({ children }: WarehousesProviderProps) {
    const [isCreateDialogOpen, setCreateDialogOpen] = useState(false)
    const [isUpdateDialogOpen, setUpdateDialogOpen] = useState(false)
    const [isDeleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [currentWarehouse, setCurrentWarehouse] = useState<RfWarehouse | null>(null)
    const [selectedWarehouseIds, setSelectedWarehouseIds] = useState<number[]>([])

    const openCreateDialog = () => {
        setCurrentWarehouse(null)
        setCreateDialogOpen(true)
    }

    const openUpdateDialog = (warehouse: RfWarehouse) => {
        setCurrentWarehouse(warehouse)
        setUpdateDialogOpen(true)
    }

    const openDeleteDialog = (warehouse: RfWarehouse) => {
        setCurrentWarehouse(warehouse)
        setDeleteDialogOpen(true)
    }

    const closeAllDialogs = () => {
        setCreateDialogOpen(false)
        setUpdateDialogOpen(false)
        setDeleteDialogOpen(false)
        setCurrentWarehouse(null)
    }

    const value: WarehousesContextValue = {
        isCreateDialogOpen,
        isUpdateDialogOpen,
        isDeleteDialogOpen,
        currentWarehouse,
        selectedWarehouseIds,
        setCreateDialogOpen,
        setUpdateDialogOpen,
        setDeleteDialogOpen,
        setCurrentWarehouse,
        setSelectedWarehouseIds,
        openCreateDialog,
        openUpdateDialog,
        openDeleteDialog,
        closeAllDialogs,
    }

    return (
        <WarehousesContext.Provider value={value}>
            {children}
        </WarehousesContext.Provider>
    )
} 