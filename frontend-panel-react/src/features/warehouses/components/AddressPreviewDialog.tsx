import React, { useEffect, useRef, useState } from 'react'
import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { MapPin, ExternalLink } from 'lucide-react'
import { fetchGoogleMapsConfig, isGoogleMapsConfigured, STATIC_GOOGLE_MAPS_CONFIG, type GoogleMapsConfig } from '@/config/googleMaps'
import type { AddressInfo } from '@/api/RfWarehouseController'

interface AddressPreviewDialogProps {
    isOpen: boolean
    onClose: () => void
    addressInfo: AddressInfo | null
    warehouseName?: string
}

export function AddressPreviewDialog({
    isOpen,
    onClose,
    addressInfo,
    warehouseName
}: AddressPreviewDialogProps) {
    const [isLoading, setIsLoading] = useState(false)
    const [googleMapsConfig, setGoogleMapsConfig] = useState<GoogleMapsConfig | null>(null)

    const mapRef = useRef<HTMLDivElement>(null)
    const mapInstanceRef = useRef<any>(null)
    const markerRef = useRef<any>(null)

    // 获取Google Maps配置
    useEffect(() => {
        const loadConfig = async () => {
            const config = await fetchGoogleMapsConfig()
            setGoogleMapsConfig(config)
        }
        loadConfig()
    }, [])

    // 加载Google Maps脚本
    const loadGoogleMapsScript = (): Promise<void> => {
        return new Promise((resolve, reject) => {
            if ((window as any).google && (window as any).google.maps) {
                resolve()
                return
            }

            if (!googleMapsConfig?.apiKey) {
                reject(new Error('Google Maps API key not configured'))
                return
            }

            const script = document.createElement('script')
            script.src = `https://maps.googleapis.com/maps/api/js?key=${googleMapsConfig.apiKey}&libraries=places&language=zh-CN`
            script.async = true
            script.defer = true
            script.onload = () => resolve()
            script.onerror = () => reject(new Error('Failed to load Google Maps script'))
            document.head.appendChild(script)
        })
    }

    // 初始化地图
    const initializeMap = async () => {
        if (!mapRef.current || !googleMapsConfig || !addressInfo) return

        try {
            setIsLoading(true)
            await loadGoogleMapsScript()

            const google = (window as any).google
            const position = {
                lat: addressInfo.latitude,
                lng: addressInfo.longitude
            }

            // 创建地图实例
            const map = new google.maps.Map(mapRef.current, {
                center: position,
                zoom: 15, // 较高的缩放级别以显示详细位置
                ...STATIC_GOOGLE_MAPS_CONFIG.mapOptions
            })

            mapInstanceRef.current = map

            // 创建标记
            const marker = new google.maps.Marker({
                map,
                position,
                title: warehouseName || '仓库位置',
            })

            markerRef.current = marker

            // 创建信息窗口
            const infoWindow = new google.maps.InfoWindow({
                content: `
                    <div style="padding: 8px; max-width: 300px;">
                        <h4 style="margin: 0 0 8px 0; font-weight: bold;">${warehouseName || '仓库位置'}</h4>
                        <p style="margin: 0; font-size: 14px; color: #666;">${addressInfo.formattedAddress}</p>
                    </div>
                `
            })

            // 默认显示信息窗口
            infoWindow.open(map, marker)

            // 点击标记时显示信息窗口
            marker.addListener('click', () => {
                infoWindow.open(map, marker)
            })

        } catch (error) {
            // eslint-disable-next-line no-console
            console.error('Failed to initialize Google Maps:', error)
        } finally {
            setIsLoading(false)
        }
    }

    // 打开对话框时初始化地图
    useEffect(() => {
        if (isOpen && googleMapsConfig && isGoogleMapsConfigured(googleMapsConfig) && addressInfo) {
            // 延迟初始化，确保DOM元素已渲染
            setTimeout(initializeMap, 100)
        }
    }, [isOpen, googleMapsConfig, addressInfo])

    // 清理地图实例
    useEffect(() => {
        return () => {
            if (markerRef.current) {
                markerRef.current.setMap(null)
            }
            if (mapInstanceRef.current) {
                mapInstanceRef.current = null
            }
        }
    }, [])

    // 在Google Maps中打开
    const openInGoogleMaps = () => {
        if (!addressInfo) return

        const url = `https://www.google.com/maps?q=${addressInfo.latitude},${addressInfo.longitude}`
        window.open(url, '_blank')
    }

    if (!addressInfo) {
        return null
    }

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className='max-w-2xl'>
                <DialogHeader>
                    <DialogTitle className='flex items-center gap-2'>
                        <MapPin className='h-5 w-5' />
                        {warehouseName ? `${warehouseName} - 位置预览` : '位置预览'}
                    </DialogTitle>
                </DialogHeader>

                <div className='space-y-4'>
                    {/* 地址信息 */}
                    <div className='p-3 bg-muted rounded-lg'>
                        <div className='text-sm font-medium mb-1'>地址</div>
                        <div className='text-sm text-muted-foreground'>{addressInfo.formattedAddress}</div>
                        <div className='text-xs text-muted-foreground mt-1'>
                            纬度: {addressInfo.latitude.toFixed(6)}, 经度: {addressInfo.longitude.toFixed(6)}
                        </div>
                    </div>

                    {/* 地图容器 */}
                    {googleMapsConfig && isGoogleMapsConfigured(googleMapsConfig) ? (
                        <div className='relative'>
                            {isLoading && (
                                <div className='absolute inset-0 flex items-center justify-center bg-background/80 z-10 rounded-lg'>
                                    <div className='text-sm'>加载地图中...</div>
                                </div>
                            )}
                            <div
                                ref={mapRef}
                                className='w-full h-80 rounded-lg border'
                            />
                        </div>
                    ) : (
                        <div className='p-8 border border-dashed rounded-lg text-center text-muted-foreground'>
                            <MapPin className='mx-auto h-8 w-8 mb-2' />
                            <p className='text-sm'>Google Maps未配置</p>
                            <p className='text-xs'>无法显示地图预览</p>
                        </div>
                    )}

                    {/* 操作按钮 */}
                    <div className='flex justify-between'>
                        <Button variant='outline' onClick={openInGoogleMaps}>
                            <ExternalLink className='mr-2 h-4 w-4' />
                            在Google Maps中打开
                        </Button>
                        <Button onClick={onClose}>
                            关闭
                        </Button>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    )
} 