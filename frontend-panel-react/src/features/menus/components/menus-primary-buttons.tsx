import { Plus } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useMenusContext } from '../context/menus-context'

export function MenusPrimaryButtons() {
    const { setIsCreateDialogOpen } = useMenusContext()

    return (
        <div className='flex items-center space-x-2'>
            <Button onClick={() => setIsCreateDialogOpen(true)}>
                <Plus className='mr-2 h-4 w-4' />
                新增菜单
            </Button>
        </div>
    )
} 