import React, { createContext, useContext, useState } from 'react'
import type { Product } from '../data/schema'

interface ProductsContextType {
    // 当前选中的商品
    selectedProduct: Product | null
    setSelectedProduct: (product: Product | null) => void

    // 对话框状态
    isActionDialogOpen: boolean
    setIsActionDialogOpen: (open: boolean) => void

    isDeleteDialogOpen: boolean
    setIsDeleteDialogOpen: (open: boolean) => void

    // 表单模式
    mode: 'add' | 'edit'
    setMode: (mode: 'add' | 'edit') => void

    // 重置状态
    reset: () => void
}

const ProductsContext = createContext<ProductsContextType | undefined>(undefined)

interface ProductsProviderProps {
    children: React.ReactNode
}

export default function ProductsProvider({ children }: ProductsProviderProps) {
    const [selectedProduct, setSelectedProduct] = useState<Product | null>(null)
    const [isActionDialogOpen, setIsActionDialogOpen] = useState(false)
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
    const [mode, setMode] = useState<'add' | 'edit'>('add')

    const reset = () => {
        setSelectedProduct(null)
        setIsActionDialogOpen(false)
        setIsDeleteDialogOpen(false)
        setMode('add')
    }

    const value: ProductsContextType = {
        selectedProduct,
        setSelectedProduct,
        isActionDialogOpen,
        setIsActionDialogOpen,
        isDeleteDialogOpen,
        setIsDeleteDialogOpen,
        mode,
        setMode,
        reset,
    }

    return (
        <ProductsContext.Provider value={value}>
            {children}
        </ProductsContext.Provider>
    )
}

export function useProductsContext() {
    const context = useContext(ProductsContext)
    if (context === undefined) {
        throw new Error('useProductsContext must be used within a ProductsProvider')
    }
    return context
} 