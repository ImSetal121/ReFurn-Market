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
import { Package, MapPin, DollarSign } from 'lucide-react'
import { TASK_TYPE_MAP } from '../data/schema'
import type { InternalLogisticsTask } from '../data/schema'

interface TaskAcceptDialogProps {
    open: boolean
    onOpenChange: (open: boolean) => void
    task: InternalLogisticsTask
    onAccept: () => void
}

export function TaskAcceptDialog({ open, onOpenChange, task, onAccept }: TaskAcceptDialogProps) {
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

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>确认接取任务</DialogTitle>
                    <DialogDescription>
                        请确认以下任务信息，确认后将无法取消
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
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
                            <div className="flex items-center gap-2">
                                <MapPin className="h-4 w-4" />
                                <span
                                    className="break-all max-w-[320px] text-sm text-gray-800"
                                    title={parseAddress(task.sourceAddress)?.formattedAddress}
                                >
                                    取货地址: {parseAddress(task.sourceAddress)?.formattedAddress}
                                </span>
                            </div>
                        )}
                        {task.targetAddress && (
                            <div className="flex items-center gap-2">
                                <MapPin className="h-4 w-4" />
                                <span
                                    className="break-all max-w-[320px] text-sm text-gray-800"
                                    title={parseAddress(task.targetAddress)?.formattedAddress}
                                >
                                    送达地址: {parseAddress(task.targetAddress)?.formattedAddress}
                                </span>
                            </div>
                        )}
                        {task.logisticsCost && (
                            <div className="flex items-center gap-2">
                                <DollarSign className="h-4 w-4" />
                                <span>物流费用: ¥{task.logisticsCost}</span>
                            </div>
                        )}
                    </div>
                </div>
                <DialogFooter>
                    <Button variant="outline" onClick={() => onOpenChange(false)}>
                        取消
                    </Button>
                    <Button onClick={onAccept}>
                        确认接取
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
} 