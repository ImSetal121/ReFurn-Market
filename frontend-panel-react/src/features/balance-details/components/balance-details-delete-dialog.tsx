import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { useBalanceDetails } from '../context/balance-details-context'
import { useDeleteBalanceDetail } from '../data/balance-details-service'
import { getTransactionTypeName } from '../data/schema'

export function BalanceDetailsDeleteDialog() {
    const { open, setOpen, currentRow } = useBalanceDetails()
    const deleteMutation = useDeleteBalanceDetail()

    const isOpen = open === 'delete'
    const isLoading = deleteMutation.isPending

    const handleConfirm = async () => {
        try {
            if (currentRow?.id) {
                await deleteMutation.mutateAsync(currentRow.id)
            }
            setOpen(null)
        } catch {
            // 错误处理已在service中完成
        }
    }

    const handleCancel = () => {
        if (!isLoading) {
            setOpen(null)
        }
    }

    const getDialogContent = () => {
        if (currentRow) {
            return {
                title: '删除余额明细',
                description: '您确定要删除这条余额明细记录吗？此操作不可撤销。',
                detail: {
                    id: currentRow.id,
                    user: currentRow.username || currentRow.nickname || `用户${currentRow.userId}`,
                    type: getTransactionTypeName(currentRow.transactionType || ''),
                    amount: currentRow.amount || 0,
                    description: currentRow.description,
                    balanceBefore: currentRow.balanceBefore,
                    balanceAfter: currentRow.balanceAfter,
                }
            }
        }
        return null
    }

    const content = getDialogContent()
    if (!content) return null

    return (
        <AlertDialog open={isOpen} onOpenChange={() => !isLoading && setOpen(null)}>
            <AlertDialogContent className="max-w-md">
                <AlertDialogHeader>
                    <AlertDialogTitle>{content.title}</AlertDialogTitle>
                    <AlertDialogDescription className="space-y-3">
                        <div>{content.description}</div>

                        <div className="bg-muted/50 p-3 rounded-md text-sm">
                            <div className="font-medium mb-2">将要删除的记录:</div>
                            <div className="space-y-1">
                                <div className="flex justify-between">
                                    <span className="text-muted-foreground">ID:</span>
                                    <span>{content.detail.id}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-muted-foreground">用户:</span>
                                    <span>{content.detail.user}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-muted-foreground">交易类型:</span>
                                    <span>{content.detail.type}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-muted-foreground">交易金额:</span>
                                    <span className="text-green-600 font-medium">¥{content.detail.amount?.toFixed(2)}</span>
                                </div>
                                {content.detail.balanceBefore !== undefined && (
                                    <>
                                        <div className="flex justify-between">
                                            <span className="text-muted-foreground">变动前余额:</span>
                                            <span>¥{content.detail.balanceBefore.toFixed(2)}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span className="text-muted-foreground">变动后余额:</span>
                                            <span>¥{content.detail.balanceAfter?.toFixed(2)}</span>
                                        </div>
                                    </>
                                )}
                                {content.detail.description && (
                                    <div className="flex justify-between">
                                        <span className="text-muted-foreground">描述:</span>
                                        <span className="text-right max-w-32 truncate" title={content.detail.description}>
                                            {content.detail.description}
                                        </span>
                                    </div>
                                )}
                            </div>
                        </div>
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel onClick={handleCancel} disabled={isLoading}>
                        取消
                    </AlertDialogCancel>
                    <AlertDialogAction
                        onClick={handleConfirm}
                        disabled={isLoading}
                        className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                    >
                        {isLoading ? '删除中...' : '确认删除'}
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    )
} 