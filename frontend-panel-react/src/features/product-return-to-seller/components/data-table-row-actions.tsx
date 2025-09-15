import { DotsHorizontalIcon } from '@radix-ui/react-icons';
import { Row } from '@tanstack/react-table';

import { Button } from '@/components/ui/button';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuRadioGroup,
    DropdownMenuRadioItem,
    DropdownMenuSeparator,
    DropdownMenuShortcut,
    DropdownMenuSub,
    DropdownMenuSubContent,
    DropdownMenuSubTrigger,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

import { statuses } from '../data/schema';
import { useProductReturnToSellerContext } from '../context/product-return-to-seller-context';
import type { RfProductReturnToSeller } from '@/api/RfProductReturnToSellerController';

interface DataTableRowActionsProps<TData> {
    row: Row<TData>;
}

export function DataTableRowActions<TData>({
    row,
}: DataTableRowActionsProps<TData>) {
    const record = row.original as RfProductReturnToSeller;
    const {
        setSelectedRecord,
        setViewDialogOpen,
        setAddEditDialogOpen,
        setDeleteDialogOpen,
        setIsEditing
    } = useProductReturnToSellerContext();

    const handleView = () => {
        setSelectedRecord(record);
        setViewDialogOpen(true);
    };

    const handleEdit = () => {
        setSelectedRecord(record);
        setIsEditing(true);
        setAddEditDialogOpen(true);
    };

    const handleDelete = () => {
        setSelectedRecord(record);
        setDeleteDialogOpen(true);
    };

    return (
        <DropdownMenu>
            <DropdownMenuTrigger asChild>
                <Button
                    variant="ghost"
                    className="flex h-8 w-8 p-0 data-[state=open]:bg-muted"
                >
                    <DotsHorizontalIcon className="h-4 w-4" />
                    <span className="sr-only">打开菜单</span>
                </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-[160px]">
                <DropdownMenuItem onClick={handleView}>查看</DropdownMenuItem>
                <DropdownMenuItem onClick={handleEdit}>编辑</DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuSub>
                    <DropdownMenuSubTrigger>状态</DropdownMenuSubTrigger>
                    <DropdownMenuSubContent>
                        <DropdownMenuRadioGroup value={record.status}>
                            {statuses.map((status) => (
                                <DropdownMenuRadioItem key={status.value} value={status.value}>
                                    {status.label}
                                </DropdownMenuRadioItem>
                            ))}
                        </DropdownMenuRadioGroup>
                    </DropdownMenuSubContent>
                </DropdownMenuSub>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleDelete}>
                    删除
                    <DropdownMenuShortcut>⌘⌫</DropdownMenuShortcut>
                </DropdownMenuItem>
            </DropdownMenuContent>
        </DropdownMenu>
    );
} 