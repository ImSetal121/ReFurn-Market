import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import { useProductSellRecords } from '../context/context'

export function ProductSellRecordsPrimaryButtons() {
    const { setOpen } = useProductSellRecords()

    return (
        <div className='flex items-center gap-2'>
            <Button onClick={() => setOpen('add')}>
                <Plus className='mr-2 h-4 w-4' />
                添加销售记录
            </Button>
        </div>
    )
} 