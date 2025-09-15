import { Plus } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useRolesContext } from '../context/roles-context'

export function RolesPrimaryButtons() {
    const { setCurrentRole, setActionDialogOpen } = useRolesContext()

    const handleAddRole = () => {
        setCurrentRole(null) // null 表示新建
        setActionDialogOpen(true)
    }

    return (
        <div className='flex items-center space-x-2'>
            <Button onClick={handleAddRole} size='sm'>
                <Plus className='mr-2 h-4 w-4' />
                添加角色
            </Button>
        </div>
    )
} 