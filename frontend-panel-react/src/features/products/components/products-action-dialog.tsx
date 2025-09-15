import { useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Switch } from '@/components/ui/switch'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { useProductsContext } from '../context/products-context'
import { useAddProduct, useUpdateProduct } from '../data/products-service'
import { productSchema, type Product } from '../data/schema'

export function ProductsActionDialog() {
    const {
        isActionDialogOpen,
        setIsActionDialogOpen,
        selectedProduct,
        mode,
        reset,
    } = useProductsContext()

    const addProductMutation = useAddProduct()
    const updateProductMutation = useUpdateProduct()

    const form = useForm<Product>({
        resolver: zodResolver(productSchema),
        defaultValues: {
            name: '',
            userId: undefined,
            categoryId: undefined,
            type: '',
            category: '',
            price: 0,
            stock: 0,
            description: '',
            imageUrlJson: '',
            address: '',
            isAuction: false,
            isSelfPickup: false,
            status: 'LISTED',
        },
    })

    useEffect(() => {
        if (isActionDialogOpen && selectedProduct && mode === 'edit') {
            form.reset(selectedProduct)
        } else if (isActionDialogOpen && mode === 'add') {
            form.reset({
                name: '',
                userId: undefined,
                categoryId: undefined,
                type: '',
                category: '',
                price: 0,
                stock: 0,
                description: '',
                imageUrlJson: '',
                address: '',
                isAuction: false,
                isSelfPickup: false,
                status: 'LISTED',
            })
        }
    }, [isActionDialogOpen, selectedProduct, mode, form])

    const onSubmit = async (data: Product) => {
        try {
            if (mode === 'add') {
                await addProductMutation.mutateAsync(data)
            } else {
                await updateProductMutation.mutateAsync(data)
            }
            handleClose()
        } catch (_error) {
            // 错误已经在mutation中处理
        }
    }

    const handleClose = () => {
        setIsActionDialogOpen(false)
        form.reset()
        reset()
    }

    return (
        <Dialog open={isActionDialogOpen} onOpenChange={setIsActionDialogOpen}>
            <DialogContent className="sm:max-w-[600px] max-h-[90vh]">
                <DialogHeader>
                    <DialogTitle>
                        {mode === 'add' ? '添加商品' : '编辑商品'}
                    </DialogTitle>
                    <DialogDescription>
                        {mode === 'add'
                            ? '填写商品信息以添加新商品。'
                            : '修改商品信息后点击保存。'
                        }
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 max-h-[80vh] overflow-y-auto">
                    <div className="space-y-2">
                        <Label htmlFor="name">商品名称 *</Label>
                        <Input
                            id="name"
                            placeholder="请输入商品名称"
                            {...form.register('name')}
                        />
                        {form.formState.errors.name && (
                            <p className="text-sm text-red-500">{form.formState.errors.name.message}</p>
                        )}
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="userId">用户ID</Label>
                            <Input
                                id="userId"
                                type="number"
                                placeholder="用户ID"
                                {...form.register('userId', { valueAsNumber: true })}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="categoryId">分类ID</Label>
                            <Input
                                id="categoryId"
                                type="number"
                                placeholder="分类ID"
                                {...form.register('categoryId', { valueAsNumber: true })}
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="type">商品类型</Label>
                            <Input
                                id="type"
                                placeholder="请输入商品类型"
                                {...form.register('type')}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="category">分类名称</Label>
                            <Input
                                id="category"
                                placeholder="请输入分类名称"
                                {...form.register('category')}
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="price">价格</Label>
                            <Input
                                id="price"
                                type="number"
                                step="0.01"
                                placeholder="0.00"
                                {...form.register('price', { valueAsNumber: true })}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="stock">库存</Label>
                            <Input
                                id="stock"
                                type="number"
                                placeholder="0"
                                {...form.register('stock', { valueAsNumber: true })}
                            />
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="description">商品描述</Label>
                        <Textarea
                            id="description"
                            placeholder="请输入商品描述"
                            rows={3}
                            {...form.register('description')}
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="imageUrlJson">商品图片URL (JSON格式)</Label>
                        <Textarea
                            id="imageUrlJson"
                            placeholder='请输入图片URL JSON，如：["url1", "url2"]'
                            rows={2}
                            {...form.register('imageUrlJson')}
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="address">商品地址</Label>
                        <Input
                            id="address"
                            placeholder="请输入商品所在地址"
                            {...form.register('address')}
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="status">商品状态</Label>
                        <Select
                            value={form.watch('status')}
                            onValueChange={(value) => form.setValue('status', value)}
                        >
                            <SelectTrigger>
                                <SelectValue placeholder="请选择商品状态" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="LISTED">已上架</SelectItem>
                                <SelectItem value="UNLISTED">未上架</SelectItem>
                                <SelectItem value="SOLD">已卖出</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="flex items-center space-x-6">
                        <div className="flex items-center space-x-2">
                            <Switch
                                id="isAuction"
                                checked={form.watch('isAuction')}
                                onCheckedChange={(checked) => form.setValue('isAuction', checked)}
                            />
                            <Label htmlFor="isAuction">拍卖商品</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                            <Switch
                                id="isSelfPickup"
                                checked={form.watch('isSelfPickup')}
                                onCheckedChange={(checked) => form.setValue('isSelfPickup', checked)}
                            />
                            <Label htmlFor="isSelfPickup">支持自提</Label>
                        </div>
                    </div>

                    <DialogFooter>
                        <Button type="button" variant="outline" onClick={handleClose}>
                            取消
                        </Button>
                        <Button
                            type="submit"
                            disabled={addProductMutation.isPending || updateProductMutation.isPending}
                        >
                            {addProductMutation.isPending || updateProductMutation.isPending ? '保存中...' : '保存'}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    )
} 