import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';
import { useProductReturnToSellerContext } from '../context/product-return-to-seller-context';

export function ProductReturnToSellerPrimaryButtons() {
    const { setAddEditDialogOpen, setIsEditing } = useProductReturnToSellerContext();

    return (
        <div className='flex items-center gap-2'>
            <Button onClick={() => {
                setIsEditing(false);
                setAddEditDialogOpen(true);
            }}>
                <Plus className='mr-2 h-4 w-4' />
                添加退回记录
            </Button>
        </div>
    );
} 