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
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'
import { useBillItems } from '../context/bill-items-context'
import { useAddBillItem, useUpdateBillItem } from '../data/bill-items-service'
import { costTypeOptions, billStatusOptions } from '../data/schema'
import type { RfBillItem } from '@/api/RfBillItemController'

export function BillItemsActionDialog() {
    const { open, setOpen, currentRow, users } = useBillItems()
    const addMutation = useAddBillItem()
    const updateMutation = useUpdateBillItem()

    const isEdit = open === 'edit' && !!currentRow
    const isOpen = open === 'add' || open === 'edit'

    // 表单状态
    const [formData, setFormData] = useState<Partial<RfBillItem>>({
        productId: undefined,
        productSellRecordId: undefined,
        costType: '',
        costDescription: '',
        cost: 0,
        paySubject: '',
        isPlatformPay: false,
        payUserId: undefined,
        status: 'PENDING',
        payTime: '',
        paymentRecordId: undefined,
    })

    // 当编辑时填充表单
    useEffect(() => {
        if (isEdit && currentRow) {
            setFormData({
                productId: currentRow.productId,
                productSellRecordId: currentRow.productSellRecordId,
                costType: currentRow.costType || '',
                costDescription: currentRow.costDescription || '',
                cost: currentRow.cost || 0,
                paySubject: currentRow.paySubject || '',
                isPlatformPay: currentRow.isPlatformPay || false,
                payUserId: currentRow.payUserId,
                status: currentRow.status || 'PENDING',
                payTime: currentRow.payTime ? new Date(currentRow.payTime).toISOString().slice(0, 16) : '',
                paymentRecordId: currentRow.paymentRecordId,
            })
        } else {
            setFormData({
                productId: undefined,
                productSellRecordId: undefined,
                costType: '',
                costDescription: '',
                cost: 0,
                paySubject: '',
                isPlatformPay: false,
                payUserId: undefined,
                status: 'PENDING',
                payTime: '',
                paymentRecordId: undefined,
            })
        }
    }, [isEdit, currentRow])

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()

        // 简单验证
        if (!formData.costType) {
            alert('请选择费用类型')
            return
        }
        if (!formData.status) {
            alert('请选择状态')
            return
        }
        if (formData.cost === undefined || formData.cost < 0) {
            alert('请输入有效的费用金额')
            return
        }

        try {
            const submitData: RfBillItem = {
                ...formData,
                costType: formData.costType!,
                status: formData.status!,
                cost: formData.cost!,
                payTime: formData.payTime ? new Date(formData.payTime).toISOString() : undefined,
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
            productId: undefined,
            productSellRecordId: undefined,
            costType: '',
            costDescription: '',
            cost: 0,
            paySubject: '',
            isPlatformPay: false,
            payUserId: undefined,
            status: 'PENDING',
            payTime: '',
            paymentRecordId: undefined,
        })
    }

    const isLoading = addMutation.isPending || updateMutation.isPending

    return (
        <Dialog open={isOpen} onOpenChange={() => !isLoading && handleClose()}>
            <DialogContent className='max-w-2xl max-h-[90vh] overflow-y-auto'>
                <DialogHeader>
                    <DialogTitle>
                        {isEdit ? '编辑账单项' : '添加账单项'}
                    </DialogTitle>
                    <DialogDescription>
                        {isEdit ? '修改账单项信息' : '创建新的账单项记录'}
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit} className='space-y-4'>
                    <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                        {/* 商品ID */}
                        <div className='space-y-2'>
                            <Label htmlFor='productId'>商品ID</Label>
                            <Input
                                id='productId'
                                type='number'
                                placeholder='请输入商品ID'
                                value={formData.productId || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    productId: e.target.value ? Number(e.target.value) : undefined
                                }))}
                            />
                        </div>

                        {/* 销售记录ID */}
                        <div className='space-y-2'>
                            <Label htmlFor='productSellRecordId'>销售记录ID</Label>
                            <Input
                                id='productSellRecordId'
                                type='number'
                                placeholder='请输入销售记录ID'
                                value={formData.productSellRecordId || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    productSellRecordId: e.target.value ? Number(e.target.value) : undefined
                                }))}
                            />
                        </div>

                        {/* 费用类型 */}
                        <div className='space-y-2'>
                            <Label htmlFor='costType'>费用类型 *</Label>
                            <Select
                                value={formData.costType}
                                onValueChange={(value) => setFormData(prev => ({ ...prev, costType: value }))}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder='请选择费用类型' />
                                </SelectTrigger>
                                <SelectContent>
                                    {costTypeOptions.map((option) => (
                                        <SelectItem key={option.value} value={option.value}>
                                            {option.label}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        {/* 费用金额 */}
                        <div className='space-y-2'>
                            <Label htmlFor='cost'>费用金额 *</Label>
                            <Input
                                id='cost'
                                type='number'
                                step='0.01'
                                placeholder='请输入费用金额'
                                value={formData.cost || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    cost: e.target.value ? Number(e.target.value) : 0
                                }))}
                            />
                        </div>

                        {/* 支付主体 */}
                        <div className='space-y-2'>
                            <Label htmlFor='paySubject'>支付主体</Label>
                            <Input
                                id='paySubject'
                                placeholder='请输入支付主体'
                                value={formData.paySubject || ''}
                                onChange={(e) => setFormData(prev => ({ ...prev, paySubject: e.target.value }))}
                            />
                        </div>

                        {/* 支付用户 */}
                        <div className='space-y-2'>
                            <Label htmlFor='payUserId'>支付用户</Label>
                            <Select
                                value={formData.payUserId?.toString()}
                                onValueChange={(value) => setFormData(prev => ({
                                    ...prev,
                                    payUserId: value ? Number(value) : undefined
                                }))}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder='请选择支付用户' />
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

                        {/* 状态 */}
                        <div className='space-y-2'>
                            <Label htmlFor='status'>状态 *</Label>
                            <Select
                                value={formData.status}
                                onValueChange={(value) => setFormData(prev => ({ ...prev, status: value }))}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder='请选择状态' />
                                </SelectTrigger>
                                <SelectContent>
                                    {billStatusOptions.map((option) => (
                                        <SelectItem key={option.value} value={option.value}>
                                            {option.label}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        {/* 支付时间 */}
                        <div className='space-y-2'>
                            <Label htmlFor='payTime'>支付时间</Label>
                            <Input
                                id='payTime'
                                type='datetime-local'
                                value={formData.payTime || ''}
                                onChange={(e) => setFormData(prev => ({ ...prev, payTime: e.target.value }))}
                            />
                        </div>

                        {/* 支付记录ID */}
                        <div className='space-y-2'>
                            <Label htmlFor='paymentRecordId'>支付记录ID</Label>
                            <Input
                                id='paymentRecordId'
                                type='number'
                                placeholder='请输入支付记录ID'
                                value={formData.paymentRecordId || ''}
                                onChange={(e) => setFormData(prev => ({
                                    ...prev,
                                    paymentRecordId: e.target.value ? Number(e.target.value) : undefined
                                }))}
                            />
                        </div>

                        {/* 是否平台支付 */}
                        <div className='flex items-center space-x-2'>
                            <Switch
                                id='isPlatformPay'
                                checked={formData.isPlatformPay || false}
                                onCheckedChange={(checked) => setFormData(prev => ({ ...prev, isPlatformPay: checked }))}
                            />
                            <Label htmlFor='isPlatformPay'>平台支付</Label>
                        </div>
                    </div>

                    {/* 费用描述 */}
                    <div className='space-y-2'>
                        <Label htmlFor='costDescription'>费用描述</Label>
                        <Textarea
                            id='costDescription'
                            placeholder='请输入费用描述'
                            className='min-h-[80px]'
                            value={formData.costDescription || ''}
                            onChange={(e) => setFormData(prev => ({ ...prev, costDescription: e.target.value }))}
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