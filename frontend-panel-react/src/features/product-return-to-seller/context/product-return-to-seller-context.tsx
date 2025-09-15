import React, { createContext, useContext, useState } from 'react';
import type { RfProductReturnToSeller } from '@/api/RfProductReturnToSellerController';

interface ProductReturnToSellerContextType {
    // 添加/编辑对话框
    addEditDialogOpen: boolean;
    setAddEditDialogOpen: (open: boolean) => void;

    // 删除对话框
    deleteDialogOpen: boolean;
    setDeleteDialogOpen: (open: boolean) => void;

    // 查看对话框
    viewDialogOpen: boolean;
    setViewDialogOpen: (open: boolean) => void;

    // 当前选中的记录
    selectedRecord: RfProductReturnToSeller | null;
    setSelectedRecord: (record: RfProductReturnToSeller | null) => void;

    // 编辑模式
    isEditing: boolean;
    setIsEditing: (editing: boolean) => void;

    // 批量删除选中的记录
    selectedRecords: RfProductReturnToSeller[];
    setSelectedRecords: (records: RfProductReturnToSeller[]) => void;
}

const ProductReturnToSellerContext = createContext<ProductReturnToSellerContextType | undefined>(undefined);

export function ProductReturnToSellerProvider({ children }: { children: React.ReactNode }) {
    const [addEditDialogOpen, setAddEditDialogOpen] = useState(false);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [viewDialogOpen, setViewDialogOpen] = useState(false);
    const [selectedRecord, setSelectedRecord] = useState<RfProductReturnToSeller | null>(null);
    const [isEditing, setIsEditing] = useState(false);
    const [selectedRecords, setSelectedRecords] = useState<RfProductReturnToSeller[]>([]);

    const value: ProductReturnToSellerContextType = {
        addEditDialogOpen,
        setAddEditDialogOpen,
        deleteDialogOpen,
        setDeleteDialogOpen,
        viewDialogOpen,
        setViewDialogOpen,
        selectedRecord,
        setSelectedRecord,
        isEditing,
        setIsEditing,
        selectedRecords,
        setSelectedRecords,
    };

    return (
        <ProductReturnToSellerContext.Provider value={value}>
            {children}
        </ProductReturnToSellerContext.Provider>
    );
}

export function useProductReturnToSellerContext() {
    const context = useContext(ProductReturnToSellerContext);
    if (context === undefined) {
        throw new Error('useProductReturnToSellerContext must be used within a ProductReturnToSellerProvider');
    }
    return context;
} 