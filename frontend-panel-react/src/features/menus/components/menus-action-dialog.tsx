import { useEffect } from 'react'
import { useForm } from 'react-hook-form'
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
import { Button } from '@/components/ui/button'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { Textarea } from '@/components/ui/textarea'
import { useCreateMenu, useUpdateMenu } from '../data/menus-service'
import type { SysMenu } from '@/types/system'

interface MenusActionDialogProps {
    menu: SysMenu | null
    open: boolean
    onOpenChange: (open: boolean) => void
}

export function MenusActionDialog({ menu, open, onOpenChange }: MenusActionDialogProps) {
    const isEdit = !!menu
    const createMenu = useCreateMenu()
    const updateMenu = useUpdateMenu()

    const form = useForm<SysMenu>({
        defaultValues: {
            menuName: '',
            parentId: undefined,
            orderNum: 0,
            path: '',
            component: '',
            query: '',
            routeName: '',
            isFrame: 1,
            isCache: 0,
            menuType: 'C',
            visible: '0',
            status: '0',
            perms: '',
            icon: '',
            remark: '',
        },
    })

    useEffect(() => {
        if (open) {
            if (isEdit && menu) {
                form.reset(menu)
            } else {
                form.reset({
                    menuName: '',
                    parentId: undefined,
                    orderNum: 0,
                    path: '',
                    component: '',
                    query: '',
                    routeName: '',
                    isFrame: 1,
                    isCache: 0,
                    menuType: 'C',
                    visible: '0',
                    status: '0',
                    perms: '',
                    icon: '',
                    remark: '',
                })
            }
        }
    }, [open, isEdit, menu, form])

    const onSubmit = async (data: SysMenu) => {
        try {
            // 确保菜单名称不为空
            if (!data.menuName?.trim()) {
                form.setError('menuName', {
                    type: 'manual',
                    message: '菜单名称不能为空'
                })
                return
            }

            if (isEdit && menu?.id) {
                await updateMenu.mutateAsync({ ...data, id: menu.id })
            } else {
                await createMenu.mutateAsync(data)
            }
            onOpenChange(false)
        } catch (_error) {
            // 错误处理已在service中完成
        }
    }

    const isPending = createMenu.isPending || updateMenu.isPending

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className='max-w-2xl max-h-[90vh] overflow-y-auto'>
                <DialogHeader>
                    <DialogTitle>{isEdit ? '编辑菜单' : '新增菜单'}</DialogTitle>
                    <DialogDescription>
                        {isEdit ? '修改菜单信息' : '创建新的菜单项'}
                    </DialogDescription>
                </DialogHeader>

                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className='space-y-4'>
                        <div className='grid grid-cols-2 gap-4'>
                            <FormField
                                control={form.control}
                                name='menuName'
                                rules={{ required: '菜单名称不能为空' }}
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>菜单名称 *</FormLabel>
                                        <FormControl>
                                            <Input placeholder='请输入菜单名称' {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name='menuType'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>菜单类型</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder='选择菜单类型' />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value='M'>目录</SelectItem>
                                                <SelectItem value='C'>菜单</SelectItem>
                                                <SelectItem value='F'>按钮</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className='grid grid-cols-2 gap-4'>
                            <FormField
                                control={form.control}
                                name='icon'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>图标</FormLabel>
                                        <FormControl>
                                            <Input placeholder='请输入图标' {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name='orderNum'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>排序</FormLabel>
                                        <FormControl>
                                            <Input
                                                type='number'
                                                placeholder='请输入排序号'
                                                {...field}
                                                value={field.value || ''}
                                                onChange={(e) => field.onChange(e.target.value ? Number(e.target.value) : undefined)}
                                            />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className='grid grid-cols-2 gap-4'>
                            <FormField
                                control={form.control}
                                name='path'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>路由地址</FormLabel>
                                        <FormControl>
                                            <Input placeholder='请输入路由地址' {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name='component'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>组件路径</FormLabel>
                                        <FormControl>
                                            <Input placeholder='请输入组件路径' {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className='grid grid-cols-2 gap-4'>
                            <FormField
                                control={form.control}
                                name='perms'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>权限标识</FormLabel>
                                        <FormControl>
                                            <Input placeholder='请输入权限标识' {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name='routeName'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>路由名称</FormLabel>
                                        <FormControl>
                                            <Input placeholder='请输入路由名称' {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <div className='grid grid-cols-2 gap-4'>
                            <FormField
                                control={form.control}
                                name='visible'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>显示状态</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder='选择显示状态' />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value='0'>显示</SelectItem>
                                                <SelectItem value='1'>隐藏</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name='status'
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>菜单状态</FormLabel>
                                        <Select onValueChange={field.onChange} value={field.value}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder='选择菜单状态' />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value='0'>正常</SelectItem>
                                                <SelectItem value='1'>停用</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name='remark'
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>备注</FormLabel>
                                    <FormControl>
                                        <Textarea placeholder='请输入备注信息' {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <DialogFooter>
                            <Button
                                type='button'
                                variant='outline'
                                onClick={() => onOpenChange(false)}
                                disabled={isPending}
                            >
                                取消
                            </Button>
                            <Button type='submit' disabled={isPending}>
                                {isPending ? '保存中...' : '保存'}
                            </Button>
                        </DialogFooter>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>
    )
} 