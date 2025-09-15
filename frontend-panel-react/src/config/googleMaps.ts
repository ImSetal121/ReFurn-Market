// Google Maps 配置接口
export interface GoogleMapsConfig {
    apiKey: string
    defaultCenter: {
        latitude: number
        longitude: number
    }
    defaultZoom: number
    enabled: boolean
}

// 静态地图配置（不依赖后端API）
export const STATIC_GOOGLE_MAPS_CONFIG = {
    // 地图样式配置
    mapOptions: {
        disableDefaultUI: false,
        zoomControl: true,
        streetViewControl: true,
        fullscreenControl: true,
        mapTypeControl: false,
    },

    // 地址搜索选项
    autocompleteOptions: {
        fields: ['place_id', 'formatted_address', 'geometry', 'name'],
        componentRestrictions: { country: 'hk' }, // 限制为香港地区，可根据需要调整
    }
}

import { get } from '@/utils/request'

// 从后端获取Google Maps配置
export const fetchGoogleMapsConfig = async (): Promise<GoogleMapsConfig> => {
    try {
        // 使用项目统一的请求封装
        const data = await get<GoogleMapsConfig>('/system/config/google-maps')
        return data
    } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Error fetching Google Maps config:', error)
        // 返回默认配置
        return {
            apiKey: '',
            defaultCenter: {
                latitude: 22.3193,
                longitude: 114.1694
            },
            defaultZoom: 12,
            enabled: false
        }
    }
}

// 检查是否配置了Google Maps API Key
export const isGoogleMapsConfigured = (config: GoogleMapsConfig): boolean => {
    return Boolean(config.enabled) && Boolean(config.apiKey) && config.apiKey !== 'YOUR_GOOGLE_MAPS_API_KEY_HERE'
} 