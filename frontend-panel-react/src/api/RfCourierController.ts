import { post } from '@/utils/request';

export interface AcceptTaskRequest {
    taskId: number;
    taskType: string;
}

export interface PickupRequest {
    taskId: number;
    imageUrls: Record<string, string>;
    remark?: string;
}

export interface DeliveryRequest {
    taskId: number;
    imageUrls: Record<string, string>;
    remark?: string;
}

// 后端响应格式
interface ApiResponse<T> {
    code: number;
    message: string;
    data: T;
    success: boolean;
    timestamp: number;
}

export const RfCourierController = {
    /**
     * 接取物流任务
     */
    acceptTask: async (data: AcceptTaskRequest): Promise<boolean> => {
        const response = await post<ApiResponse<boolean>>('/api/courier/accept-task', data);
        return response.data;
    },

    /**
     * 取货
     */
    pickupItem: async (data: PickupRequest): Promise<boolean> => {
        const response = await post<ApiResponse<boolean>>('/api/courier/pickup', data);
        return response.data;
    },

    /**
     * 送达
     */
    deliverItem: async (data: DeliveryRequest): Promise<boolean> => {
        const response = await post<ApiResponse<boolean>>('/api/courier/deliver', data);
        return response.data;
    }
}; 