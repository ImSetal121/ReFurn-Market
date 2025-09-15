import React, { useEffect, useRef, useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog'
import { MapPin, Search } from 'lucide-react'
import { fetchGoogleMapsConfig, isGoogleMapsConfigured, STATIC_GOOGLE_MAPS_CONFIG, type GoogleMapsConfig } from '@/config/googleMaps'
import type { AddressInfo } from '@/api/RfWarehouseController'

interface AddressSelectorProps {
    value?: AddressInfo | null
    onChange: (address: AddressInfo | null) => void
    label?: string
    placeholder?: string
    error?: string
}

export function AddressSelector({
    value,
    onChange,
    label = '仓库地址',
    placeholder = '点击选择地址...',
    error
}: AddressSelectorProps) {
    const [isDialogOpen, setIsDialogOpen] = useState(false)
    const [isLoading, setIsLoading] = useState(false)
    const [searchValue, setSearchValue] = useState('')
    const [googleMapsConfig, setGoogleMapsConfig] = useState<GoogleMapsConfig | null>(null)

    const mapRef = useRef<HTMLDivElement>(null)
    const searchInputRef = useRef<HTMLInputElement>(null)
    const mapInstanceRef = useRef<any>(null)
    const markerRef = useRef<any>(null)
    const autocompleteRef = useRef<any>(null)

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
        if (!mapRef.current || !googleMapsConfig) return

        try {
            setIsLoading(true)
            await loadGoogleMapsScript()

            const google = (window as any).google
            const defaultCenter = {
                lat: googleMapsConfig.defaultCenter.latitude,
                lng: googleMapsConfig.defaultCenter.longitude
            }

            // 创建地图实例
            const map = new google.maps.Map(mapRef.current, {
                center: value ? { lat: value.latitude, lng: value.longitude } : defaultCenter,
                zoom: googleMapsConfig.defaultZoom,
                ...STATIC_GOOGLE_MAPS_CONFIG.mapOptions
            })

            mapInstanceRef.current = map

            // 创建标记
            const marker = new google.maps.Marker({
                map,
                draggable: true,
                position: value ? { lat: value.latitude, lng: value.longitude } : defaultCenter,
            })

            markerRef.current = marker

            // 初始化自动完成搜索
            if (searchInputRef.current) {
                const autocomplete = new google.maps.places.Autocomplete(
                    searchInputRef.current,
                    STATIC_GOOGLE_MAPS_CONFIG.autocompleteOptions
                )

                autocompleteRef.current = autocomplete

                // 监听地点选择
                autocomplete.addListener('place_changed', () => {
                    const place = autocomplete.getPlace()
                    if (place.geometry && place.geometry.location) {
                        const position = place.geometry.location
                        const lat = position.lat()
                        const lng = position.lng()

                        map.setCenter({ lat, lng })
                        marker.setPosition({ lat, lng })

                        updateAddress(lat, lng, place.formatted_address || '', place.place_id)
                    }
                })
            }

            // 监听标记拖拽
            marker.addListener('dragend', (event: any) => {
                if (event.latLng) {
                    const lat = event.latLng.lat()
                    const lng = event.latLng.lng()
                    reverseGeocode(lat, lng)
                }
            })

            // 监听地图点击
            map.addListener('click', (event: any) => {
                if (event.latLng) {
                    const lat = event.latLng.lat()
                    const lng = event.latLng.lng()
                    marker.setPosition({ lat, lng })
                    reverseGeocode(lat, lng)
                }
            })

        } catch (error) {
            // eslint-disable-next-line no-console
            console.error('Failed to initialize Google Maps:', error)
        } finally {
            setIsLoading(false)
        }
    }

    // 反向地理编码获取地址
    const reverseGeocode = (lat: number, lng: number) => {
        const google = (window as any).google
        const geocoder = new google.maps.Geocoder()
        geocoder.geocode(
            { location: { lat, lng } },
            (results: any, status: any) => {
                if (status === 'OK' && results && results[0]) {
                    updateAddress(lat, lng, results[0].formatted_address, results[0].place_id)
                } else {
                    updateAddress(lat, lng, `${lat.toFixed(6)}, ${lng.toFixed(6)}`)
                }
            }
        )
    }

    // 更新地址信息
    const updateAddress = (lat: number, lng: number, formattedAddress: string, placeId?: string) => {
        const addressInfo: AddressInfo = {
            latitude: lat,
            longitude: lng,
            formattedAddress,
            placeId
        }
        onChange(addressInfo)
    }

    // 打开对话框时初始化地图
    useEffect(() => {
        if (isDialogOpen && googleMapsConfig && isGoogleMapsConfigured(googleMapsConfig)) {
            // 延迟初始化，确保DOM元素已渲染
            setTimeout(initializeMap, 100)
        }
    }, [isDialogOpen, googleMapsConfig])

    // 清理地图实例
    useEffect(() => {
        return () => {
            if (autocompleteRef.current && (window as any).google) {
                (window as any).google.maps.event.clearInstanceListeners(autocompleteRef.current)
            }
            if (markerRef.current) {
                markerRef.current.setMap(null)
            }
            if (mapInstanceRef.current) {
                // Google Maps实例会自动清理
                mapInstanceRef.current = null
            }
        }
    }, [])

    const handleConfirm = () => {
        setIsDialogOpen(false)
    }

    const handleClear = () => {
        onChange(null)
        setSearchValue('')
    }

    if (!googleMapsConfig || !isGoogleMapsConfigured(googleMapsConfig)) {
        return (
            <div className='space-y-2'>
                <Label>{label}</Label>
                <div className='p-4 border border-dashed rounded-lg text-center text-muted-foreground'>
                    <MapPin className='mx-auto h-8 w-8 mb-2' />
                    <p className='text-sm'>Google Maps未配置</p>
                    <p className='text-xs'>请在后端配置Google Maps API密钥</p>
                </div>
                {error && <p className='text-sm text-red-500'>{error}</p>}
            </div>
        )
    }

    return (
        <div className='space-y-2'>
            <Label>{label}</Label>
            <div className='flex gap-2'>
                <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                    <DialogTrigger asChild>
                        <Button variant='outline' className='flex-1 justify-start text-left font-normal h-auto min-h-[40px] py-2 px-3 whitespace-normal'>
                            <MapPin className='mr-2 h-4 w-4 flex-shrink-0 mt-0.5' />
                            <span className='break-words'>
                                {value ? value.formattedAddress : placeholder}
                            </span>
                        </Button>
                    </DialogTrigger>
                    <DialogContent className='max-w-4xl max-h-[80vh] overflow-hidden'>
                        <DialogHeader>
                            <DialogTitle>选择地址位置</DialogTitle>
                        </DialogHeader>

                        <div className='space-y-4'>
                            {/* 搜索框 */}
                            <div className='flex gap-2'>
                                <div className='flex-1 relative'>
                                    <Search className='absolute left-3 top-3 h-4 w-4 text-muted-foreground' />
                                    <Input
                                        ref={searchInputRef}
                                        placeholder='搜索地址或地点...'
                                        value={searchValue}
                                        onChange={(e) => setSearchValue(e.target.value)}
                                        className='pl-9'
                                    />
                                </div>
                            </div>

                            {/* 地图容器 */}
                            <div className='relative'>
                                {isLoading && (
                                    <div className='absolute inset-0 flex items-center justify-center bg-background/80 z-10'>
                                        <div className='text-sm'>加载地图中...</div>
                                    </div>
                                )}
                                <div
                                    ref={mapRef}
                                    className='w-full h-96 rounded-lg border'
                                    style={{ minHeight: '400px' }}
                                />
                            </div>

                            {/* 当前选择的地址信息 */}
                            {value && (
                                <div className='p-3 bg-muted rounded-lg space-y-1'>
                                    <div className='text-sm font-medium'>已选择地址：</div>
                                    <div className='text-sm text-muted-foreground'>{value.formattedAddress}</div>
                                    <div className='text-xs text-muted-foreground'>
                                        纬度: {value.latitude.toFixed(6)}, 经度: {value.longitude.toFixed(6)}
                                    </div>
                                </div>
                            )}

                            {/* 操作按钮 */}
                            <div className='flex justify-end gap-2'>
                                <Button variant='outline' onClick={handleClear}>
                                    清除
                                </Button>
                                <Button onClick={handleConfirm}>
                                    确认选择
                                </Button>
                            </div>
                        </div>
                    </DialogContent>
                </Dialog>
            </div>
            {error && <p className='text-sm text-red-500'>{error}</p>}
        </div>
    )
} 