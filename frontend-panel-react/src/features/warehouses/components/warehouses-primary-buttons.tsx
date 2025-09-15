import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import { useWarehousesContext } from '../context/warehouses-context'

export function WarehousesPrimaryButtons() {
    const { openCreateDialog } = useWarehousesContext()

    return (
        <div className='space-x-2'>
            <Button onClick={openCreateDialog}>
                <Plus className='mr-2 h-4 w-4' />
                新增仓库
            </Button>
        </div>
    )
} 