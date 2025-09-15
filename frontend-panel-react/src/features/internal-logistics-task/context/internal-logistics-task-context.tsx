import { createContext, useContext, useState, type ReactNode } from 'react'
import type { InternalLogisticsTask } from '../data/schema'
import React from 'react'

type FormMode = 'add' | 'edit'

interface InternalLogisticsTaskContextType {
    // 选中的记录
    selectedRecord: InternalLogisticsTask | null
    setSelectedRecord: (record: InternalLogisticsTask | null) => void

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

const InternalLogisticsTaskContext = createContext<InternalLogisticsTaskContextType | null>(null)

interface InternalLogisticsTaskProviderProps {
    children: ReactNode
}

export function InternalLogisticsTaskProvider({ children }: InternalLogisticsTaskProviderProps) {
    const [selectedRecord, setSelectedRecord] = useState<InternalLogisticsTask | null>(null)
    const [isActionDialogOpen, setIsActionDialogOpen] = useState(false)
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
    const [mode, setMode] = useState<FormMode>('add')

    const reset = () => {
        setSelectedRecord(null)
        setIsActionDialogOpen(false)
        setIsDeleteDialogOpen(false)
        setMode('add')
    }

    const value: InternalLogisticsTaskContextType = {
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
        <InternalLogisticsTaskContext.Provider value={value}>
            {children}
        </InternalLogisticsTaskContext.Provider>
    )
}

export function useInternalLogisticsTaskContext() {
    const context = useContext(InternalLogisticsTaskContext)
    if (!context) {
        throw new Error('useInternalLogisticsTaskContext must be used within a InternalLogisticsTaskProvider')
    }
    return context
} 