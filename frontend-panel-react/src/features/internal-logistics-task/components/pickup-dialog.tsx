import { useState } from 'react'
import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Badge } from '@/components/ui/badge'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import { Package, MapPin, Upload, X } from 'lucide-react'
import { TASK_TYPE_MAP } from '../data/schema'
import type { InternalLogisticsTask } from '../data/schema'
import { S3UploadUtils, UploadResponse } from '@/utils/s3-upload'
import { toast } from 'sonner'

interface PickupDialogProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    task: InternalLogisticsTask
    onPickup: (imageUrls: Record<string, string>, remark: string) => void
}

export function PickupDialog({ open, onOpenChange, task, onPickup }: PickupDialogProps) {
    const [uploadedImages, setUploadedImages] = useState<UploadResponse[]>([])
    const [uploading, setUploading] = useState(false)
    const [remark, setRemark] = useState('')

    // 解析地址JSON
    const parseAddress = (addressJson?: string) => {
        if (!addressJson) return null
        try {
            const address = JSON.parse(addressJson)
            return {
                formattedAddress: address.formattedAddress,
                latitude: address.latitude,
                longitude: address.longitude
            }
        } catch {
            return null
        }
    }

    // 处理文件上传
    const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const files = event.target.files
        if (!files || files.length === 0) return

        setUploading(true)
        try {
            const uploadPromises = Array.from(files).map(async (file) => {
                // 验证文件类型
                if (!file.type.startsWith('image/')) {
                    throw new Error(`文件 ${file.name} 不是图片格式`)
                }

                // 验证文件大小（10MB）
                const maxSize = 10 * 1024 * 1024
                if (file.size > maxSize) {
                    throw new Error(`文件 ${file.name} 大小超过10MB限制`)
                }

                return await S3UploadUtils.uploadImage(file, (_progress) => {
                    // 可以在这里处理单个文件的上传进度
                })
            })

            const results = await Promise.all(uploadPromises)
            setUploadedImages(prev => [...prev, ...results])
            toast.success(`成功上传 ${results.length} 张图片`)
        } catch (error) {
            if (error instanceof Error) {
                toast.error(`图片上传失败: ${error.message}`)
            } else {
                toast.error('图片上传失败')
            }
        } finally {
            setUploading(false)
            // 清空文件输入，允许重复选择
            event.target.value = ''
        }
    }

    // 删除图片
    const handleRemoveImage = (index: number) => {
        setUploadedImages(prev => prev.filter((_, i) => i !== index))
    }

    // 确认取货
    const handleConfirmPickup = () => {
        if (uploadedImages.length === 0) {
            toast.error('请至少上传一张取货图片')
            return
        }

        // 构建图片URL JSON格式
        const imageUrls: Record<string, string> = {}
        uploadedImages.forEach((image, index) => {
            imageUrls[(index + 1).toString()] = image.fileUrl
        })

        onPickup(imageUrls, remark)
    }

    // 重置状态
    const handleClose = () => {
        setUploadedImages([])
        setRemark('')
        onOpenChange(false)
    }

    return (
        <Dialog open={open} onOpenChange={handleClose}>
            <DialogContent className="sm:max-w-[600px] max-h-[80vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>确认取货</DialogTitle>
                    <DialogDescription>
                        请上传取货照片并填写备注信息
                    </DialogDescription>
                </DialogHeader>

                <div className="grid gap-4 py-4">
                    {/* 任务信息 */}
                    <div className="space-y-2">
                        <div className="flex items-center gap-2">
                            <Badge variant="outline">任务ID</Badge>
                            <span>{task.id}</span>
                        </div>
                        <div className="flex items-center gap-2">
                            <Badge variant="outline">任务类型</Badge>
                            <span>{task.taskType ? TASK_TYPE_MAP[task.taskType as keyof typeof TASK_TYPE_MAP] : '-'}</span>
                        </div>
                        {task.productId && (
                            <div className="flex items-center gap-2">
                                <Package className="h-4 w-4" />
                                <span>商品ID: {task.productId}</span>
                            </div>
                        )}
                        {task.sourceAddress && (
                            <div className="flex items-start gap-2">
                                <MapPin className="h-4 w-4 mt-0.5" />
                                <span className="break-all text-sm">
                                    取货地址: {parseAddress(task.sourceAddress)?.formattedAddress}
                                </span>
                            </div>
                        )}
                    </div>

                    {/* 图片上传区域 */}
                    <div className="space-y-2">
                        <Label>取货照片 *</Label>
                        <div className="border-2 border-dashed border-gray-300 rounded-lg p-4">
                            <div className="text-center">
                                <input
                                    type="file"
                                    multiple
                                    accept="image/*"
                                    onChange={handleFileUpload}
                                    className="hidden"
                                    id="image-upload"
                                    disabled={uploading}
                                />
                                <label
                                    htmlFor="image-upload"
                                    className="cursor-pointer flex flex-col items-center gap-2"
                                >
                                    <Upload className="h-8 w-8 text-gray-400" />
                                    <span className="text-sm text-gray-600">
                                        {uploading ? '上传中...' : '点击上传图片或拖拽图片到此处'}
                                    </span>
                                    <span className="text-xs text-gray-400">
                                        支持 JPG、PNG、GIF 格式，最大 10MB
                                    </span>
                                </label>
                            </div>
                        </div>

                        {/* 已上传的图片预览 */}
                        {uploadedImages.length > 0 && (
                            <div className="grid grid-cols-3 gap-2 mt-4">
                                {uploadedImages.map((image, index) => (
                                    <div key={index} className="relative group">
                                        <img
                                            src={image.fileUrl}
                                            alt={`取货图片 ${index + 1}`}
                                            className="w-full h-20 object-cover rounded border"
                                        />
                                        <button
                                            onClick={() => handleRemoveImage(index)}
                                            className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                                        >
                                            <X className="h-3 w-3" />
                                        </button>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* 备注 */}
                    <div className="space-y-2">
                        <Label htmlFor="remark">备注</Label>
                        <Textarea
                            id="remark"
                            placeholder="请输入取货备注信息..."
                            value={remark}
                            onChange={(e) => setRemark(e.target.value)}
                            rows={3}
                        />
                    </div>
                </div>

                <DialogFooter>
                    <Button variant="outline" onClick={handleClose}>
                        取消
                    </Button>
                    <Button
                        onClick={handleConfirmPickup}
                        disabled={uploading || uploadedImages.length === 0}
                    >
                        {uploading ? '上传中...' : '确认取货'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}