import React, { useState } from 'react'
import { Button } from '@/components/ui/button'
import { MapPin, Info } from 'lucide-react'
import { AddressPreviewDialog } from './AddressPreviewDialog'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import type { AddressInfo } from '@/api/RfWarehouseController'

interface AddressButtonProps {
    address: string
    warehouseName?: string
}

export function AddressButton({ address, warehouseName }: AddressButtonProps) {
    const [isPreviewOpen, setIsPreviewOpen] = useState(false)
    const [isInfoOpen, setIsInfoOpen] = useState(false)
    const [addressInfo, setAddressInfo] = useState<AddressInfo | null>(null)

    // 解析地址信息
    const parseAddressInfo = (addressStr: string): AddressInfo | null => {
        try {
            // 尝试解析JSON格式的地址
            const parsed = JSON.parse(addressStr) as AddressInfo
            if (parsed.latitude && parsed.longitude && parsed.formattedAddress) {
                return parsed
            }
        } catch {
            // 如果不是JSON格式，认为是简单字符串地址，无法显示地图
        }
        return null
    }

    const handleClick = () => {
        const parsedAddress = parseAddressInfo(address)
        setAddressInfo(parsedAddress)

        if (parsedAddress) {
            setIsPreviewOpen(true)
        } else {
            setIsInfoOpen(true)
        }
    }

    // 获取显示的地址文本
    const getDisplayAddress = (): string => {
        const parsedAddress = parseAddressInfo(address)
        if (parsedAddress) {
            return parsedAddress.formattedAddress
        }
        return address
    }

    const displayAddress = getDisplayAddress()
    const hasLocation = parseAddressInfo(address) !== null

    return (
        <>
            <Button
                variant="outline"
                size="sm"
                className="h-auto p-2 text-left justify-start max-w-80 whitespace-normal"
                onClick={handleClick}
            >
                <MapPin className={`mr-2 h-4 w-4 flex-shrink-0 ${hasLocation ? 'text-blue-600' : 'text-gray-400'}`} />
                <span className="break-words text-sm">
                    {displayAddress}
                </span>
            </Button>

            <AddressPreviewDialog
                isOpen={isPreviewOpen}
                onClose={() => setIsPreviewOpen(false)}
                addressInfo={addressInfo}
                warehouseName={warehouseName}
            />

            {/* 简单地址信息对话框 */}
            <Dialog open={isInfoOpen} onOpenChange={setIsInfoOpen}>
                <DialogContent className='max-w-md'>
                    <DialogHeader>
                        <DialogTitle className='flex items-center gap-2'>
                            <Info className='h-5 w-5' />
                            地址信息
                        </DialogTitle>
                    </DialogHeader>
                    <div className='space-y-4'>
                        <div className='p-3 bg-muted rounded-lg'>
                            <div className='text-sm font-medium mb-1'>地址</div>
                            <div className='text-sm text-muted-foreground'>{address}</div>
                        </div>
                        <p className='text-sm text-muted-foreground'>
                            此地址没有地理位置信息，无法显示地图预览。
                        </p>
                        <div className='flex justify-end'>
                            <Button onClick={() => setIsInfoOpen(false)}>
                                关闭
                            </Button>
                        </div>
                    </div>
                </DialogContent>
            </Dialog>
        </>
    )
} 