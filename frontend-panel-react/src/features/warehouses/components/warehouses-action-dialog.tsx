import React from 'react'
import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { AddressSelector } from './AddressSelector'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { useWarehousesContext } from '../context/warehouses-context'
import { useAddWarehouse, useUpdateWarehouse } from '../data/warehouses-service'
import { warehouseStatusOptions } from '../data/schema'
import type { RfWarehouse, AddressInfo } from '@/api/RfWarehouseController'

export function WarehousesActionDialog() {
    const {
        isCreateDialogOpen,
        isUpdateDialogOpen,
        currentWarehouse,
        closeAllDialogs,
    } = useWarehousesContext()

    const addMutation = useAddWarehouse()
    const updateMutation = useUpdateWarehouse()

    const isOpen = isCreateDialogOpen || isUpdateDialogOpen
    const isEdit = isUpdateDialogOpen

    // 表单状态
    const [name, setName] = React.useState('')
    const [addressInfo, setAddressInfo] = React.useState<AddressInfo | null>(null)
    const [monthlyWarehouseCost, setMonthlyWarehouseCost] = React.useState<number>(0)
    const [status, setStatus] = React.useState('ENABLED')
    const [errors, setErrors] = React.useState<Record<string, string>>({})

    // 当对话框打开时，重置表单
    React.useEffect(() => {
        if (isOpen) {
            if (isEdit && currentWarehouse) {
                setName(currentWarehouse.name)
                // 解析地址JSON
                try {
                    const addressData = JSON.parse(currentWarehouse.address) as AddressInfo
                    setAddressInfo(addressData)
                } catch {
                    // 如果解析失败，将address当作简单字符串处理
                    setAddressInfo({
                        formattedAddress: currentWarehouse.address,
                        latitude: 22.3193,
                        longitude: 114.1694
                    })
                }
                setMonthlyWarehouseCost(currentWarehouse.monthlyWarehouseCost)
                setStatus(currentWarehouse.status)
            } else {
                setName('')
                setAddressInfo(null)
                setMonthlyWarehouseCost(0)
                setStatus('ENABLED')
            }
            setErrors({})
        }
    }, [isOpen, isEdit, currentWarehouse])

    const validateForm = () => {
        const newErrors: Record<string, string> = {}

        if (!name.trim()) {
            newErrors.name = '仓库名称不能为空'
        }
        if (!addressInfo) {
            newErrors.address = '请选择仓库地址'
        }
        if (monthlyWarehouseCost < 0) {
            newErrors.monthlyWarehouseCost = '月仓储费用不能为负数'
        }

        setErrors(newErrors)
        return Object.keys(newErrors).length === 0
    }

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()

        if (!validateForm()) {
            return
        }

        try {
            const warehouseData: RfWarehouse = {
                name: name.trim(),
                address: JSON.stringify(addressInfo), // 将地址信息序列化为JSON
                monthlyWarehouseCost,
                status,
            }

            if (isEdit && currentWarehouse?.id) {
                warehouseData.id = currentWarehouse.id
                await updateMutation.mutateAsync(warehouseData)
            } else {
                await addMutation.mutateAsync(warehouseData)
            }

            handleClose()
        } catch {
            // 错误已在mutation中处理
        }
    }

    const handleClose = () => {
        closeAllDialogs()
        setName('')
        setAddressInfo(null)
        setMonthlyWarehouseCost(0)
        setStatus('ENABLED')
        setErrors({})
    }

    const isSubmitting = addMutation.isPending || updateMutation.isPending

    return (
        <Dialog open={isOpen} onOpenChange={handleClose}>
            <DialogContent className='sm:max-w-[600px] max-h-[90vh] overflow-y-auto'>
                <DialogHeader>
                    <DialogTitle>
                        {isEdit ? '编辑仓库' : '新增仓库'}
                    </DialogTitle>
                </DialogHeader>

                <form onSubmit={handleSubmit} className='space-y-4 pr-2'>
                    <div className='space-y-2'>
                        <Label htmlFor='name'>仓库名称</Label>
                        <Input
                            id='name'
                            placeholder='请输入仓库名称'
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                        />
                        {errors.name && (
                            <p className='text-sm text-red-500'>{errors.name}</p>
                        )}
                    </div>

                    <div className='space-y-2'>
                        <AddressSelector
                            label='仓库地址'
                            value={addressInfo}
                            onChange={setAddressInfo}
                            placeholder='点击选择仓库地址...'
                            error={errors.address}
                        />
                    </div>

                    <div className='space-y-2'>
                        <Label htmlFor='cost'>月仓储费用(元)</Label>
                        <Input
                            id='cost'
                            type='number'
                            step='0.01'
                            min='0'
                            placeholder='0.00'
                            value={monthlyWarehouseCost}
                            onChange={(e) => setMonthlyWarehouseCost(parseFloat(e.target.value) || 0)}
                        />
                        {errors.monthlyWarehouseCost && (
                            <p className='text-sm text-red-500'>{errors.monthlyWarehouseCost}</p>
                        )}
                    </div>

                    <div className='space-y-2'>
                        <Label htmlFor='status'>状态</Label>
                        <Select value={status} onValueChange={setStatus}>
                            <SelectTrigger>
                                <SelectValue placeholder='选择状态' />
                            </SelectTrigger>
                            <SelectContent>
                                {warehouseStatusOptions.map((option) => (
                                    <SelectItem key={option.value} value={option.value}>
                                        {option.label}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    <div className='flex justify-end space-x-2 pt-4'>
                        <Button type='button' variant='outline' onClick={handleClose}>
                            取消
                        </Button>
                        <Button type='submit' disabled={isSubmitting}>
                            {isSubmitting ? (isEdit ? '保存中...' : '新增中...') : (isEdit ? '保存' : '新增')}
                        </Button>
                    </div>
                </form>
            </DialogContent>
        </Dialog>
    )
} 