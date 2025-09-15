import React, { useState } from 'react'
import useDialogState from '@/hooks/use-dialog-state'
import { useUsers } from '../data/balance-details-service'
import { BalanceDetail } from '../data/schema'
import type { SysUser } from '@/types/system'

type BalanceDetailsDialogType = 'add' | 'edit' | 'delete' | 'view'

interface BalanceDetailsContextType {
    open: BalanceDetailsDialogType | null
    setOpen: (str: BalanceDetailsDialogType | null) => void
    currentRow: BalanceDetail | null
    setCurrentRow: React.Dispatch<React.SetStateAction<BalanceDetail | null>>
    users: SysUser[]
    isLoadingUsers: boolean
}

const BalanceDetailsContext = React.createContext<BalanceDetailsContextType | null>(null)

interface Props {
    children: React.ReactNode
}

export default function BalanceDetailsProvider({ children }: Props) {
    const [open, setOpen] = useDialogState<BalanceDetailsDialogType>(null)
    const [currentRow, setCurrentRow] = useState<BalanceDetail | null>(null)

    // 获取用户列表
    const { data: users = [], isLoading: isLoadingUsers } = useUsers()

    return (
        <BalanceDetailsContext value={{
            open,
            setOpen,
            currentRow,
            setCurrentRow,
            users,
            isLoadingUsers
        }}>
            {children}
        </BalanceDetailsContext>
    )
}

// eslint-disable-next-line react-refresh/only-export-components
export const useBalanceDetails = () => {
    const balanceDetailsContext = React.useContext(BalanceDetailsContext)

    if (!balanceDetailsContext) {
        throw new Error('useBalanceDetails has to be used within <BalanceDetailsContext>')
    }

    return balanceDetailsContext
} 