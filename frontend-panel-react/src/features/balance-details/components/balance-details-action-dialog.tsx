import { useState, useEffect } from 'react'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { useBalanceDetails } from '../context/balance-details-context'
import { useAddBalanceDetail, useUpdateBalanceDetail } from '../data/balance-details-service'
import { transactionTypeOptions } from '../data/schema'
import type { RfBalanceDetail } from '@/api/RfBalanceDetailController'

export function BalanceDetailsActionDialog() {
    const { open, setOpen, currentRow, users } = useBalanceDetails()
    const addMutation = useAddBalanceDetail()
    const updateMutation = useUpdateBalanceDetail()

    const isEdit = open === 'edit' && !!currentRow
    const isOpen = open === 'add' || open === 'edit'

    // 表单状态
    const [formData, setFormData] = useState<Partial<RfBalanceDetail>>({
        userId: undefined,
        transactionType: '',
        amount: 0,
        balanceBefore: 0,
        balanceAfter: 0,
        description: '',
        transactionTime: '',
        prevDetailId: undefined,
        nextDetailId: undefined,
    })

    // 当编辑时填充表单
    useEffect(() => {
        if (isEdit && currentRow) {
            setFormData({
                userId: currentRow.userId,
                transactionType: currentRow.transactionType || '',
                amount: currentRow.amount || 0,
                balanceBefore: currentRow.balanceBefore || 0,
                balanceAfter: currentRow.balanceAfter || 0,
                description: currentRow.description || '',
                transactionTime: currentRow.transactionTime ? new Date(currentRow.transactionTime).toISOString().slice(0, 16) : '',
                prevDetailId: currentRow.prevDetailId,
                nextDetailId: currentRow.nextDetailId,
            })
        } else {
            setFormData({
                userId: undefined,
                transactionType: '',
                amount: 0,
                balanceBefore: 0,
                balanceAfter: 0,
                description: '',
                transactionTime: '',
                prevDetailId: undefined,
                nextDetailId: undefined,
            })
        }
    }, [isEdit, currentRow])

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()

        // 简单验证
        if (!formData.userId) {
            alert('请选择用户')
            return
        }
        if (!formData.transactionType) {
            alert('请选择交易类型')
            return
        }
        if (formData.amount === undefined || formData.amount === 0) {
            alert('请输入有效的交易金额')
            return
        }
        if (formData.balanceBefore === undefined) {
            alert('请输入变动前余额')
            return
        }
        if (formData.balanceAfter === undefined) {
            alert('请输入变动后余额')
            return
        }

        try {
            const submitData: RfBalanceDetail = {
                ...formData,
                userId: formData.userId!,
                transactionType: formData.transactionType!,
                amount: formData.amount!,
                balanceBefore: formData.balanceBefore!,
                balanceAfter: formData.balanceAfter!,
                transactionTime: formData.transactionTime ? new Date(formData.transactionTime).toISOString() : undefined,
            }

            if (isEdit && currentRow?.id) {
                await updateMutation.mutateAsync({
                    ...submitData,
                    id: currentRow.id,
                })
            } else {
                await addMutation.mutateAsync(submitData)
            }
            handleClose()
        } catch {
            // 错误处理已在service中完成
        }
    }

    const handleClose = () => {
        setOpen(null)
        setFormData({
            userId: undefined,
            transactionType: '',
            amount: 0,
            balanceBefore: 0,
            balanceAfter: 0,
            description: '',
            transactionTime: '',
            prevDetailId: undefined,
            nextDetailId: undefined,
        })
    }

    const isLoading = addMutation.isPending || updateMutation.isPending

    return (
        <Dialog open={isOpen} onOpenChange={() => !isLoading && handleClose()}>
            <DialogContent className='max-w-2xl max-h-[90vh] overflow-y-auto'>
                <DialogHeader>
                    <DialogTitle>
                        {isEdit ? '编辑余额明细' : '添加余额明细'}
                    </DialogTitle>
                    <DialogDescription>
                        {isEdit ? '修改余额明细信息' : '创建新的余额明细记录'}
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit} className='space-y-4'>
                    <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                        {/* 用户 */}
                        <div className='space-y-2'>
                            <Label htmlFor='userId'>用户 *</Label>
                            <Select
                                value={formData.userId?.toString()}
                                onValueChange={(value) => setFormData(prev => ({
                                    ...prev,
                                    userId: value ? Number(value) : undefined
                                }))}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder='请选择用户' />
                                </SelectTrigger>
                                <SelectContent>
                                    {users.map((user) => (
                                        <SelectItem key={user.id} value={user.id!.toString()}>
                                            {user.username} ({user.nickname})
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        {/* 交易类型 */}
                        <div className='space-y-2'>
                            <Label htmlFor='transactionType'>交易类型 *</Label>
                            <Select
                                value={formData.transactionType}
                                onValueChange={(value) => setFormData(prev => ({ ...prev, transactionType: value }))}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder='请选择交易类型' />
                                </SelectTrigger>
                                <SelectContent>
                                    {transactionTypeOptions.map((option) => (
                                        <SelectItem key={option.value} value={option.value}>
                                            {option.label}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        {/* 交易金额 */}
                        <div className='space-y-2'>
                            <Label htmlFor='amount'>交易金额 *</Label>
                            <Input
                                id='amount'
                                type='number'
                                step='0.01'
                                placeholder='请输入交易金额'
                                value={formData.amount || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    amount: e.target.value ? Number(e.target.value) : 0
                                }))}
                            />
                        </div>

                        {/* 变动前余额 */}
                        <div className='space-y-2'>
                            <Label htmlFor='balanceBefore'>变动前余额 *</Label>
                            <Input
                                id='balanceBefore'
                                type='number'
                                step='0.01'
                                placeholder='请输入变动前余额'
                                value={formData.balanceBefore || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    balanceBefore: e.target.value ? Number(e.target.value) : 0
                                }))}
                            />
                        </div>

                        {/* 变动后余额 */}
                        <div className='space-y-2'>
                            <Label htmlFor='balanceAfter'>变动后余额 *</Label>
                            <Input
                                id='balanceAfter'
                                type='number'
                                step='0.01'
                                placeholder='请输入变动后余额'
                                value={formData.balanceAfter || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    balanceAfter: e.target.value ? Number(e.target.value) : 0
                                }))}
                            />
                        </div>

                        {/* 交易时间 */}
                        <div className='space-y-2'>
                            <Label htmlFor='transactionTime'>交易时间</Label>
                            <Input
                                id='transactionTime'
                                type='datetime-local'
                                value={formData.transactionTime || ''}
                                onChange={(e) => setFormData(prev => ({ ...prev, transactionTime: e.target.value }))}
                            />
                        </div>

                        {/* 上一条明细ID */}
                        <div className='space-y-2'>
                            <Label htmlFor='prevDetailId'>上一条明细ID</Label>
                            <Input
                                id='prevDetailId'
                                type='number'
                                placeholder='请输入上一条明细ID'
                                value={formData.prevDetailId || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    prevDetailId: e.target.value ? Number(e.target.value) : undefined
                                }))}
                            />
                        </div>

                        {/* 下一条明细ID */}
                        <div className='space-y-2'>
                            <Label htmlFor='nextDetailId'>下一条明细ID</Label>
                            <Input
                                id='nextDetailId'
                                type='number'
                                placeholder='请输入下一条明细ID'
                                value={formData.nextDetailId || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    nextDetailId: e.target.value ? Number(e.target.value) : undefined
                                }))}
                            />
                        </div>
                    </div>

                    {/* 描述 */}
                    <div className='space-y-2'>
                        <Label htmlFor='description'>描述</Label>
                        <Textarea
                            id='description'
                            placeholder='请输入描述'
                            className='min-h-[80px]'
                            value={formData.description || ''}
                            onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                        />
                    </div>

                    <DialogFooter>
                        <Button type='button' variant='outline' onClick={handleClose}>
                            取消
                        </Button>
                        <Button type='submit' disabled={isLoading}>
                            {isLoading ? (isEdit ? '更新中...' : '创建中...') : (isEdit ? '更新' : '创建')}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
} 