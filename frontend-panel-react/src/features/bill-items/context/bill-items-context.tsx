import React, { useState } from 'react'
import useDialogState from '@/hooks/use-dialog-state'
import { useUsers, useProducts } from '../data/bill-items-service'
import { BillItem } from '../data/schema'
import type { SysUser } from '@/types/system'

type BillItemsDialogType = 'add' | 'edit' | 'delete' | 'view'

interface Product {
    id?: number
    name?: string
    // 添加其他需要的产品字段
}

interface BillItemsContextType {
    open: BillItemsDialogType | null
    setOpen: (str: BillItemsDialogType | null) => void
    currentRow: BillItem | null
    setCurrentRow: React.Dispatch<React.SetStateAction<BillItem | null>>
    users: SysUser[]
    isLoadingUsers: boolean
    products: Product[]
    isLoadingProducts: boolean
}

const BillItemsContext = React.createContext<BillItemsContextType | null>(null)

interface Props {
    children: React.ReactNode
}

export default function BillItemsProvider({ children }: Props) {
    const [open, setOpen] = useDialogState<BillItemsDialogType>(null)
    const [currentRow, setCurrentRow] = useState<BillItem | null>(null)

    // 获取用户列表
    const { data: users = [], isLoading: isLoadingUsers } = useUsers()

    // 获取商品列表
    const { data: products = [], isLoading: isLoadingProducts } = useProducts()

    return (
        <BillItemsContext value={{
            open,
            setOpen,
            currentRow,
            setCurrentRow,
            users,
            isLoadingUsers,
            products,
            isLoadingProducts
        }}>
            {children}
        </BillItemsContext>
    )
}

// eslint-disable-next-line react-refresh/only-export-components
export const useBillItems = () => {
    const billItemsContext = React.useContext(BillItemsContext)

    if (!billItemsContext) {
        throw new Error('useBillItems has to be used within <BillItemsContext>')
    }

    return billItemsContext
} 