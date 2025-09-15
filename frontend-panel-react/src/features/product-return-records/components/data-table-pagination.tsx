import {
    ChevronLeftIcon,
    ChevronRightIcon,
    DoubleArrowLeftIcon,
    DoubleArrowRightIcon,
} from '@radix-ui/react-icons';
import { Table } from '@tanstack/react-table';

import { Button } from '@/components/ui/button';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';

interface DataTablePaginationProps<TData> {
    table: Table<TData>;
    totalCount?: number;
    onPageChange?: (page: number) => void;
    onPageSizeChange?: (pageSize: number) => void;
}

export function DataTablePagination<TData>({
    table,
    totalCount,
    onPageChange,
    onPageSizeChange,
}: DataTablePaginationProps<TData>) {
    const pageIndex = table.getState().pagination.pageIndex;
    const pageSize = table.getState().pagination.pageSize;
    const pageCount = Math.ceil((totalCount || 0) / pageSize);

    return (
        <div className="flex items-center justify-between px-2">
            <div className="flex-1 text-sm text-muted-foreground">
                {table.getFilteredSelectedRowModel().rows.length} of{' '}
                {totalCount || table.getFilteredRowModel().rows.length} 行已选择。
            </div>
            <div className="flex items-center space-x-6 lg:space-x-8">
                <div className="flex items-center space-x-2">
                    <p className="text-sm font-medium">每页行数</p>
                    <Select
                        value={`${pageSize}`}
                        onValueChange={(value) => {
                            const newPageSize = Number(value);
                            table.setPageSize(newPageSize);
                            onPageSizeChange?.(newPageSize);
                        }}
                    >
                        <SelectTrigger className="h-8 w-[70px]">
                            <SelectValue placeholder={pageSize} />
                        </SelectTrigger>
                        <SelectContent side="top">
                            {[10, 20, 30, 40, 50].map((size) => (
                                <SelectItem key={size} value={`${size}`}>
                                    {size}
                                </SelectItem>
                            ))}
                        </SelectContent>
                    </Select>
                </div>
                <div className="flex w-[100px] items-center justify-center text-sm font-medium">
                    第 {pageIndex + 1} 页，共 {pageCount} 页
                </div>
                <div className="flex items-center space-x-2">
                    <Button
                        variant="outline"
                        className="hidden h-8 w-8 p-0 lg:flex"
                        onClick={() => {
                            table.setPageIndex(0);
                            onPageChange?.(1);
                        }}
                        disabled={!table.getCanPreviousPage()}
                    >
                        <span className="sr-only">跳转到第一页</span>
                        <DoubleArrowLeftIcon className="h-4 w-4" />
                    </Button>
                    <Button
                        variant="outline"
                        className="h-8 w-8 p-0"
                        onClick={() => {
                            table.previousPage();
                            onPageChange?.(pageIndex);
                        }}
                        disabled={!table.getCanPreviousPage()}
                    >
                        <span className="sr-only">跳转到上一页</span>
                        <ChevronLeftIcon className="h-4 w-4" />
                    </Button>
                    <Button
                        variant="outline"
                        className="h-8 w-8 p-0"
                        onClick={() => {
                            table.nextPage();
                            onPageChange?.(pageIndex + 2);
                        }}
                        disabled={!table.getCanNextPage()}
                    >
                        <span className="sr-only">跳转到下一页</span>
                        <ChevronRightIcon className="h-4 w-4" />
                    </Button>
                    <Button
                        variant="outline"
                        className="hidden h-8 w-8 p-0 lg:flex"
                        onClick={() => {
                            table.setPageIndex(pageCount - 1);
                            onPageChange?.(pageCount);
                        }}
                        disabled={!table.getCanNextPage()}
                    >
                        <span className="sr-only">跳转到最后一页</span>
                        <DoubleArrowRightIcon className="h-4 w-4" />
                    </Button>
                </div>
            </div>
        </div>
    );
} 