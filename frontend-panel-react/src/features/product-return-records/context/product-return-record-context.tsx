import React, { createContext, useContext, useState } from 'react';
import type { RfProductReturnRecord } from '@/api/RfProductReturnRecordController';

interface ProductReturnRecordContextType {
    // 添加/编辑对话框
    addEditDialogOpen: boolean;
    setAddEditDialogOpen: (open: boolean) => void;

    // 删除对话框
    deleteDialogOpen: boolean;
    setDeleteDialogOpen: (open: boolean) => void;

    // 查看对话框
    viewDialogOpen: boolean;
    setViewDialogOpen: (open: boolean) => void;

    // 审核对话框
    auditDialogOpen: boolean;
    setAuditDialogOpen: (open: boolean) => void;

    // 当前选中的记录
    selectedRecord: RfProductReturnRecord | null;
    setSelectedRecord: (record: RfProductReturnRecord | null) => void;

    // 编辑模式
    isEditing: boolean;
    setIsEditing: (editing: boolean) => void;

    // 批量删除选中的记录
    selectedRecords: RfProductReturnRecord[];
    setSelectedRecords: (records: RfProductReturnRecord[]) => void;
}

const ProductReturnRecordContext = createContext<ProductReturnRecordContextType | undefined>(undefined);

export function ProductReturnRecordProvider({ children }: { children: React.ReactNode }) {
    const [addEditDialogOpen, setAddEditDialogOpen] = useState(false);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [viewDialogOpen, setViewDialogOpen] = useState(false);
    const [auditDialogOpen, setAuditDialogOpen] = useState(false);
    const [selectedRecord, setSelectedRecord] = useState<RfProductReturnRecord | null>(null);
    const [isEditing, setIsEditing] = useState(false);
    const [selectedRecords, setSelectedRecords] = useState<RfProductReturnRecord[]>([]);

    const value: ProductReturnRecordContextType = {
        addEditDialogOpen,
        setAddEditDialogOpen,
        deleteDialogOpen,
        setDeleteDialogOpen,
        viewDialogOpen,
        setViewDialogOpen,
        auditDialogOpen,
        setAuditDialogOpen,
        selectedRecord,
        setSelectedRecord,
        isEditing,
        setIsEditing,
        selectedRecords,
        setSelectedRecords,
    };

    return (
        <ProductReturnRecordContext.Provider value={value}>
            {children}
        </ProductReturnRecordContext.Provider>
    );
}

export function useProductReturnRecordContext() {
    const context = useContext(ProductReturnRecordContext);
    if (context === undefined) {
        throw new Error('useProductReturnRecordContext must be used within a ProductReturnRecordProvider');
    }
    return context;
} 