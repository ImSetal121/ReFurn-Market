import React, { useState } from 'react'
import useDialogState from '@/hooks/use-dialog-state'
import { useRoles } from '../data/users-service'
import { User } from '../data/schema'
import type { SysRole } from '@/types/system'

type UsersDialogType = 'invite' | 'add' | 'edit' | 'delete'

interface UsersContextType {
  open: UsersDialogType | null
  setOpen: (str: UsersDialogType | null) => void
  currentRow: User | null
  setCurrentRow: React.Dispatch<React.SetStateAction<User | null>>
  roles: SysRole[]
  isLoadingRoles: boolean
}

const UsersContext = React.createContext<UsersContextType | null>(null)

interface Props {
  children: React.ReactNode
}

export default function UsersProvider({ children }: Props) {
  const [open, setOpen] = useDialogState<UsersDialogType>(null)
  const [currentRow, setCurrentRow] = useState<User | null>(null)

  // 获取角色列表
  const { data: roles = [], isLoading: isLoadingRoles } = useRoles()

  return (
    <UsersContext value={{
      open,
      setOpen,
      currentRow,
      setCurrentRow,
      roles,
      isLoadingRoles
    }}>
      {children}
    </UsersContext>
  )
}

// eslint-disable-next-line react-refresh/only-export-components
export const useUsers = () => {
  const usersContext = React.useContext(UsersContext)

  if (!usersContext) {
    throw new Error('useUsers has to be used within <UsersContext>')
  }

  return usersContext
}
