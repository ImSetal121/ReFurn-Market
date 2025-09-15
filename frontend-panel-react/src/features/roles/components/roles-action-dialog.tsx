import React from 'react'
import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'

import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'

import { useRolesContext } from '../context/roles-context'
import { useCreateRole, useUpdateRole } from '../data/roles-service'
import { roleSchema, type Role } from '../data/schema'

interface RolesActionDialogProps {
    currentRole: Role | null
    open: boolean
    onOpenChange: (open: boolean) => void
}

export function RolesActionDialog({ currentRole, open, onOpenChange }: RolesActionDialogProps) {
    const isEdit = !!currentRole

    const createRole = useCreateRole()
    const updateRole = useUpdateRole()

    const form = useForm<Role>({
        resolver: zodResolver(roleSchema),
        defaultValues: {
            key: '',
            name: '',
            description: '',
            order: 0,
            status: 'active',
        },
    })

    // 重置表单数据
    const resetForm = () => {
        if (currentRole) {
            form.reset({
                ...currentRole,
                order: currentRole.order || 0,
                status: currentRole.status || 'active',
            })
        } else {
            form.reset({
                key: '',
                name: '',
                description: '',
                order: 0,
                status: 'active',
            })
        }
    }

    // 监听对话框打开状态，重置表单
    React.useEffect(() => {
        if (open) {
            resetForm()
        }
    }, [open, currentRole])

    const onSubmit = async (data: Role) => {
        try {
            if (isEdit && currentRole?.id) {
                await updateRole.mutateAsync({ ...data, id: currentRole.id })
            } else {
                await createRole.mutateAsync(data)
            }
            onOpenChange(false)
            form.reset()
        } catch (_error) {
            // 错误处理已在service中完成
            // 这里可以添加额外的错误处理逻辑
        }
    }

    const isLoading = createRole.isPending || updateRole.isPending

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className='sm:max-w-[425px]'>
                <DialogHeader>
                    <DialogTitle>
                        {isEdit ? '编辑角色' : '添加角色'}
                    </DialogTitle>
                    <DialogDescription>
                        {isEdit ? '修改角色信息' : '创建新的系统角色'}
                    </DialogDescription>
                </DialogHeader>

                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className='space-y-4'>
                        <div className='grid gap-4 py-4'>
                            <FormField
                                control={form.control}
                                name='key'
                                render={({ field }) => (
                                    <FormItem className='space-y-2'>
                                        <FormLabel>角色标识 *</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder='请输入角色标识，如: admin'
                                                autoComplete='off'
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name='name'
                                render={({ field }) => (
                                    <FormItem className='space-y-2'>
                                        <FormLabel>角色名称 *</FormLabel>
                                        <FormControl>
                                            <Input
                                                placeholder='请输入角色名称，如: 管理员'
                                                autoComplete='off'
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name='description'
                                render={({ field }) => (
                                    <FormItem className='space-y-2'>
                                        <FormLabel>描述</FormLabel>
                                        <FormControl>
                                            <Textarea
                                                placeholder='请输入角色描述'
                                                rows={3}
                                                {...field}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <div className='grid grid-cols-2 gap-4'>
                                <FormField
                                    control={form.control}
                                    name='order'
                                    render={({ field }) => (
                                        <FormItem className='space-y-2'>
                                            <FormLabel>排序</FormLabel>
                                            <FormControl>
                                                <Input
                                                    type='number'
                                                    placeholder='0'
                                                    {...field}
                                                    onChange={(e) => field.onChange(Number(e.target.value))}
                                                />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />

                                <FormField
                                    control={form.control}
                                    name='status'
                                    render={({ field }) => (
                                        <FormItem className='space-y-2'>
                                            <FormLabel>状态</FormLabel>
                                            <Select
                                                onValueChange={field.onChange}
                                                defaultValue={field.value}
                                                value={field.value}
                                            >
                                                <FormControl>
                                                    <SelectTrigger>
                                                        <SelectValue placeholder='选择状态' />
                                                    </SelectTrigger>
                                                </FormControl>
                                                <SelectContent>
                                                    <SelectItem value='active'>启用</SelectItem>
                                                    <SelectItem value='inactive'>禁用</SelectItem>
                                                </SelectContent>
                                            </Select>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </div>
                        </div>

                        <DialogFooter>
                            <Button
                                type='button'
                                variant='outline'
                                onClick={() => onOpenChange(false)}
                                disabled={isLoading}
                            >
                                取消
                            </Button>
                            <Button type='submit' disabled={isLoading}>
                                {isLoading ? '保存中...' : isEdit ? '更新' : '创建'}
                            </Button>
                        </DialogFooter>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>
    )
} 