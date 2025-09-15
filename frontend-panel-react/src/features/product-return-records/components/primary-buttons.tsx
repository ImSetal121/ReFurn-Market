import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';
import { useProductReturnRecordContext } from '../context/product-return-record-context';

export function ProductReturnRecordsPrimaryButtons() {
    const { setAddEditDialogOpen, setIsEditing } = useProductReturnRecordContext();

    return (
        <div className='flex items-center gap-2'>
            <Button onClick={() => {
                setIsEditing(false);
                setAddEditDialogOpen(true);
            }}>
                <Plus className='mr-2 h-4 w-4' />
                添加退货记录
            </Button>
        </div>
    );
} 