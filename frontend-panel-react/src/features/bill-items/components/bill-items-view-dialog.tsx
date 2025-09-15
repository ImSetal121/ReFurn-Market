import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Badge } from '@/components/ui/badge'
import { useBillItems } from '../context/bill-items-context'
import { getCostTypeName, getBillStatusName } from '../data/schema'

export function BillItemsViewDialog() {
    const { open, setOpen, currentRow } = useBillItems()

    const isOpen = open === 'view'

    const handleClose = () => {
        setOpen(null)
    }

    if (!currentRow) {
        return null
    }

    // 根据费用类型设置颜色
    const getTypeColor = (type: string) => {
        switch (type) {
            case 'SHIPPING': return 'bg-blue-100 text-blue-800'
            case 'PLATFORM_FEE': return 'bg-purple-100 text-purple-800'
            case 'COMMISSION': return 'bg-green-100 text-green-800'
            case 'INSURANCE': return 'bg-yellow-100 text-yellow-800'
            case 'STORAGE': return 'bg-orange-100 text-orange-800'
            case 'HANDLING': return 'bg-cyan-100 text-cyan-800'
            case 'TAX': return 'bg-red-100 text-red-800'
            case 'OTHER': return 'bg-gray-100 text-gray-800'
            default: return 'bg-gray-100 text-gray-800'
        }
    }

    // 根据状态设置颜色
    const getStatusColor = (status: string) => {
        switch (status) {
            case 'PENDING': return 'bg-yellow-100 text-yellow-800'
            case 'PAID': return 'bg-green-100 text-green-800'
            case 'CANCELLED': return 'bg-gray-100 text-gray-800'
            case 'REFUNDED': return 'bg-blue-100 text-blue-800'
            case 'FAILED': return 'bg-red-100 text-red-800'
            default: return 'bg-gray-100 text-gray-800'
        }
    }

    return (
        <Dialog open={isOpen} onOpenChange={handleClose}>
            <DialogContent className='max-w-2xl max-h-[90vh] overflow-y-auto'>
                <DialogHeader>
                    <DialogTitle>账单项详情</DialogTitle>
                    <DialogDescription>
                        查看账单项的详细信息
                    </DialogDescription>
                </DialogHeader>

                <div className='space-y-6'>
                    {/* 基本信息 */}
                    <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                        <div className='space-y-2'>
                            <h4 className='font-medium text-sm text-muted-foreground'>账单项ID</h4>
                            <p className='font-mono text-sm'>{currentRow.id || '-'}</p>
                        </div>

                        <div className='space-y-2'>
                            <h4 className='font-medium text-sm text-muted-foreground'>商品ID</h4>
                            <p className='text-sm'>{currentRow.productId || '-'}</p>
                        </div>

                        <div className='space-y-2'>
                            <h4 className='font-medium text-sm text-muted-foreground'>销售记录ID</h4>
                            <p className='text-sm'>{currentRow.productSellRecordId || '-'}</p>
                        </div>

                        <div className='space-y-2'>
                            <h4 className='font-medium text-sm text-muted-foreground'>费用类型</h4>
                            {currentRow.costType && (
                                <Badge className={`text-xs ${getTypeColor(currentRow.costType)}`}>
                                    {getCostTypeName(currentRow.costType)}
                                </Badge>
                            )}
                        </div>

                        <div className='space-y-2'>
                            <h4 className='font-medium text-sm text-muted-foreground'>费用金额</h4>
                            <p className='text-sm font-mono text-green-600'>
                                ¥{currentRow.cost?.toFixed(2) || '0.00'}
                            </p>
                        </div>

                        <div className='space-y-2'>
                            <h4 className='font-medium text-sm text-muted-foreground'>状态</h4>
                            {currentRow.status && (
                                <Badge className={`text-xs ${getStatusColor(currentRow.status)}`}>
                                    {getBillStatusName(currentRow.status)}
                                </Badge>
                            )}
                        </div>
                    </div>

                    {/* 支付信息 */}
                    <div className='space-y-4'>
                        <h3 className='text-lg font-medium'>支付信息</h3>
                        <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                            <div className='space-y-2'>
                                <h4 className='font-medium text-sm text-muted-foreground'>支付主体</h4>
                                <p className='text-sm'>{currentRow.paySubject || '-'}</p>
                            </div>

                            <div className='space-y-2'>
                                <h4 className='font-medium text-sm text-muted-foreground'>支付方式</h4>
                                <Badge variant={currentRow.isPlatformPay ? 'default' : 'secondary'} className='text-xs'>
                                    {currentRow.isPlatformPay ? '平台支付' : '用户支付'}
                                </Badge>
                            </div>

                            <div className='space-y-2'>
                                <h4 className='font-medium text-sm text-muted-foreground'>支付用户ID</h4>
                                <p className='text-sm'>{currentRow.payUserId || '-'}</p>
                            </div>

                            <div className='space-y-2'>
                                <h4 className='font-medium text-sm text-muted-foreground'>支付记录ID</h4>
                                <p className='text-sm'>{currentRow.paymentRecordId || '-'}</p>
                            </div>

                            <div className='space-y-2'>
                                <h4 className='font-medium text-sm text-muted-foreground'>支付时间</h4>
                                <p className='text-sm'>
                                    {currentRow.payTime
                                        ? new Date(currentRow.payTime).toLocaleString('zh-CN')
                                        : '-'
                                    }
                                </p>
                            </div>
                        </div>
                    </div>

                    {/* 费用描述 */}
                    {currentRow.costDescription && (
                        <div className='space-y-2'>
                            <h4 className='font-medium text-sm text-muted-foreground'>费用描述</h4>
                            <div className='p-3 bg-muted rounded-md'>
                                <p className='text-sm whitespace-pre-wrap'>{currentRow.costDescription}</p>
                            </div>
                        </div>
                    )}

                    {/* 时间信息 */}
                    <div className='space-y-4'>
                        <h3 className='text-lg font-medium'>时间信息</h3>
                        <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                            <div className='space-y-2'>
                                <h4 className='font-medium text-sm text-muted-foreground'>创建时间</h4>
                                <p className='text-sm'>
                                    {currentRow.createTime
                                        ? new Date(currentRow.createTime).toLocaleString('zh-CN')
                                        : '-'
                                    }
                                </p>
                            </div>

                            <div className='space-y-2'>
                                <h4 className='font-medium text-sm text-muted-foreground'>更新时间</h4>
                                <p className='text-sm'>
                                    {currentRow.updateTime
                                        ? new Date(currentRow.updateTime).toLocaleString('zh-CN')
                                        : '-'
                                    }
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    )
} 