import React, { createContext, useContext, useState } from 'react'
import type { Role } from '../data/schema'

interface RolesContextType {
    // 对话框状态
    actionDialogOpen: boolean
    setActionDialogOpen: (open: boolean) => void
    deleteDialogOpen: boolean
    setDeleteDialogOpen: (open: boolean) => void
    menuDialogOpen: boolean
    setMenuDialogOpen: (open: boolean) => void

    // 当前操作的角色
    currentRole: Role | null
    setCurrentRole: (role: Role | null) => void

    // 选中的角色（用于批量操作）
    selectedRoles: Role[]
    setSelectedRoles: (roles: Role[]) => void
}

const RolesContext = createContext<RolesContextType | undefined>(undefined)

export function useRolesContext() {
    const context = useContext(RolesContext)
    if (!context) {
        throw new Error('useRolesContext must be used within a RolesProvider')
    }
    return context
}

interface RolesProviderProps {
    children: React.ReactNode
}

export default function RolesProvider({ children }: RolesProviderProps) {
    const [actionDialogOpen, setActionDialogOpen] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [menuDialogOpen, setMenuDialogOpen] = useState(false)
    const [currentRole, setCurrentRole] = useState<Role | null>(null)
    const [selectedRoles, setSelectedRoles] = useState<Role[]>([])

    const value: RolesContextType = {
        actionDialogOpen,
        setActionDialogOpen,
        deleteDialogOpen,
        setDeleteDialogOpen,
        menuDialogOpen,
        setMenuDialogOpen,
        currentRole,
        setCurrentRole,
        selectedRoles,
        setSelectedRoles,
    }

    return (
        <RolesContext.Provider value={value}>
            {children}
        </RolesContext.Provider>
    )
} 