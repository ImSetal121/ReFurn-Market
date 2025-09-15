import React, { createContext, useContext, useState } from 'react'
import type { SysMenu } from '@/types/system'

interface MenusContextType {
    // 选中的菜单
    selectedMenus: SysMenu[]
    setSelectedMenus: (menus: SysMenu[]) => void

    // 当前编辑的菜单
    editingMenu: SysMenu | null
    setEditingMenu: (menu: SysMenu | null) => void

    // 对话框状态
    isCreateDialogOpen: boolean
    setIsCreateDialogOpen: (open: boolean) => void

    isEditDialogOpen: boolean
    setIsEditDialogOpen: (open: boolean) => void

    isDeleteDialogOpen: boolean
    setIsDeleteDialogOpen: (open: boolean) => void
}

const MenusContext = createContext<MenusContextType | undefined>(undefined)

export function useMenusContext() {
    const context = useContext(MenusContext)
    if (context === undefined) {
        throw new Error('useMenusContext must be used within a MenusProvider')
    }
    return context
}

interface MenusProviderProps {
    children: React.ReactNode
}

export default function MenusProvider({ children }: MenusProviderProps) {
    const [selectedMenus, setSelectedMenus] = useState<SysMenu[]>([])
    const [editingMenu, setEditingMenu] = useState<SysMenu | null>(null)
    const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)

    const value: MenusContextType = {
        selectedMenus,
        setSelectedMenus,
        editingMenu,
        setEditingMenu,
        isCreateDialogOpen,
        setIsCreateDialogOpen,
        isEditDialogOpen,
        setIsEditDialogOpen,
        isDeleteDialogOpen,
        setIsDeleteDialogOpen,
    }

    return <MenusContext.Provider value={value}>{children}</MenusContext.Provider>
} 