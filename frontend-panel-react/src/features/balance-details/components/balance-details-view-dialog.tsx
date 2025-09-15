import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { useBalanceDetails } from '../context/balance-details-context'
import { getTransactionTypeName } from '../data/schema'

export function BalanceDetailsViewDialog() {
    const { open, setOpen, currentRow } = useBalanceDetails()

    const isOpen = open === 'view'

    const handleClose = () => {
        setOpen(null)
    }

    if (!currentRow) return null

    const getTransactionTypeColor = (type: string) => {
        switch (type) {
            case 'DEPOSIT':
                return 'bg-green-100 text-green-800 border-green-200'
            case 'WITHDRAW':
                return 'bg-red-100 text-red-800 border-red-200'
            case 'PURCHASE':
                return 'bg-blue-100 text-blue-800 border-blue-200'
            case 'REFUND':
                return 'bg-orange-100 text-orange-800 border-orange-200'
            case 'COMMISSION':
                return 'bg-purple-100 text-purple-800 border-purple-200'
            case 'TRANSFER_IN':
                return 'bg-emerald-100 text-emerald-800 border-emerald-200'
            case 'TRANSFER_OUT':
                return 'bg-pink-100 text-pink-800 border-pink-200'
            case 'ADJUSTMENT':
                return 'bg-gray-100 text-gray-800 border-gray-200'
            default:
                return 'bg-gray-100 text-gray-800 border-gray-200'
        }
    }

    const formatAmount = (amount: number | undefined) => {
        if (amount === undefined || amount === null) return '-'
        return `¥${amount.toFixed(2)}`
    }

    const formatDateTime = (dateStr: string | undefined) => {
        if (!dateStr) return '-'
        try {
            return new Date(dateStr).toLocaleString('zh-CN', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
            })
        } catch {
            return dateStr
        }
    }

    return (
        <Dialog open={isOpen} onOpenChange={() => handleClose()}>
            <DialogContent className='max-w-2xl max-h-[90vh] overflow-y-auto'>
                <DialogHeader>
                    <DialogTitle>查看余额明细</DialogTitle>
                    <DialogDescription>
                        余额明细记录详细信息
                    </DialogDescription>
                </DialogHeader>

                <div className='space-y-6'>
                    {/* 基本信息 */}
                    <div className='space-y-3'>
                        <h3 className='font-semibold text-lg'>基本信息</h3>
                        <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                            <div className='space-y-2'>
                                <div className='text-sm text-muted-foreground'>ID</div>
                                <div className='font-medium'>{currentRow.id || '-'}</div>
                            </div>
                            <div className='space-y-2'>
                                <div className='text-sm text-muted-foreground'>用户</div>
                                <div className='font-medium'>
                                    {currentRow.username || currentRow.nickname || `用户${currentRow.userId}`}
                                </div>
                            </div>
                            <div className='space-y-2'>
                                <div className='text-sm text-muted-foreground'>交易类型</div>
                                <Badge className={getTransactionTypeColor(currentRow.transactionType || '')}>
                                    {getTransactionTypeName(currentRow.transactionType || '')}
                                </Badge>
                            </div>
                            <div className='space-y-2'>
                                <div className='text-sm text-muted-foreground'>交易金额</div>
                                <div className='font-medium text-green-600 text-lg'>
                                    {formatAmount(currentRow.amount)}
                                </div>
                            </div>
                        </div>
                    </div>

                    <Separator />

                    {/* 余额信息 */}
                    <div className='space-y-3'>
                        <h3 className='font-semibold text-lg'>余额变动</h3>
                        <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                            <div className='space-y-2'>
                                <div className='text-sm text-muted-foreground'>变动前余额</div>
                                <div className='font-medium text-lg'>
                                    {formatAmount(currentRow.balanceBefore)}
                                </div>
                            </div>
                            <div className='space-y-2'>
                                <div className='text-sm text-muted-foreground'>变动后余额</div>
                                <div className='font-medium text-lg'>
                                    {formatAmount(currentRow.balanceAfter)}
                                </div>
                            </div>
                        </div>

                        {/* 余额变化可视化 */}
                        <div className='bg-muted/50 p-4 rounded-lg'>
                            <div className='flex items-center justify-between text-sm'>
                                <span>变动前</span>
                                <span className='mx-2'>→</span>
                                <span>变动后</span>
                            </div>
                            <div className='flex items-center justify-between font-medium mt-1'>
                                <span>{formatAmount(currentRow.balanceBefore)}</span>
                                <span className='mx-2 text-muted-foreground'>
                                    {currentRow.amount && currentRow.amount > 0 ? '+' : ''}
                                    {formatAmount(currentRow.amount)}
                                </span>
                                <span>{formatAmount(currentRow.balanceAfter)}</span>
                            </div>
                        </div>
                    </div>

                    <Separator />

                    {/* 链表信息 */}
                    {(currentRow.prevDetailId || currentRow.nextDetailId) && (
                        <>
                            <div className='space-y-3'>
                                <h3 className='font-semibold text-lg'>链表关系</h3>
                                <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                                    {currentRow.prevDetailId && (
                                        <div className='space-y-2'>
                                            <div className='text-sm text-muted-foreground'>上一条明细ID</div>
                                            <div className='font-medium'>{currentRow.prevDetailId}</div>
                                        </div>
                                    )}
                                    {currentRow.nextDetailId && (
                                        <div className='space-y-2'>
                                            <div className='text-sm text-muted-foreground'>下一条明细ID</div>
                                            <div className='font-medium'>{currentRow.nextDetailId}</div>
                                        </div>
                                    )}
                                </div>
                            </div>
                            <Separator />
                        </>
                    )}

                    {/* 描述 */}
                    {currentRow.description && (
                        <>
                            <div className='space-y-3'>
                                <h3 className='font-semibold text-lg'>描述</h3>
                                <div className='bg-muted/50 p-3 rounded-lg'>
                                    <p className='text-sm leading-relaxed'>
                                        {currentRow.description}
                                    </p>
                                </div>
                            </div>
                            <Separator />
                        </>
                    )}

                    {/* 时间信息 */}
                    <div className='space-y-3'>
                        <h3 className='font-semibold text-lg'>时间信息</h3>
                        <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                            <div className='space-y-2'>
                                <div className='text-sm text-muted-foreground'>交易时间</div>
                                <div className='font-medium'>
                                    {formatDateTime(currentRow.transactionTime)}
                                </div>
                            </div>
                            <div className='space-y-2'>
                                <div className='text-sm text-muted-foreground'>创建时间</div>
                                <div className='font-medium'>
                                    {formatDateTime(currentRow.createTime)}
                                </div>
                            </div>
                            {currentRow.updateTime && (
                                <div className='space-y-2'>
                                    <div className='text-sm text-muted-foreground'>更新时间</div>
                                    <div className='font-medium'>
                                        {formatDateTime(currentRow.updateTime)}
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    )
} 