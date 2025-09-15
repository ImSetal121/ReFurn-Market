import axios from 'axios';
import type { InternalAxiosRequestConfig, AxiosResponse, AxiosError } from 'axios';
import { toast } from 'sonner';
import { useAuthStore } from '@/stores/authStore';

// 创建axios实例
const service = axios.create({
  baseURL: import.meta.env.MODE === 'development' ? 'http://localhost:8080' : 'http://localhost:8080',
  timeout: 10000,
  withCredentials: true,
});

// 请求拦截器
service.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const { accessToken } = useAuthStore.getState().auth;
    if (accessToken) {
      // 将token添加到请求头
      config.headers.Authorization = `Bearer ${accessToken}`;
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse) => {
    const res = response.data;

    // 如果接口返回成功状态码
    if (res.code === 200) {
      return res.data;
    }

    // 处理错误情况
    toast.error(res.message || 'Error');

    // 处理未授权情况
    if (res.code === 401) {
      useAuthStore.getState().auth.reset();
      // 可以在这里添加重定向逻辑
    }

    return Promise.reject(new Error(res.message || 'Error'));
  },
  (error: AxiosError) => {
    const errorMessage = (error.response?.data as { message?: string })?.message || error.message || 'Request failed';
    toast.error(errorMessage);

    if (error.response?.status === 401) {
      useAuthStore.getState().auth.reset();
      // 可以在这里添加重定向逻辑
    }

    return Promise.reject(error);
  }
);

// 封装GET请求
export function get<T = unknown>(url: string, params?: Record<string, unknown>): Promise<T> {
  return service.get(url, { params });
}

// 封装POST请求
export function post<T = unknown>(url: string, data?: unknown): Promise<T> {
  return service.post(url, data);
}

// 封装PUT请求
export function put<T = unknown>(url: string, data?: unknown): Promise<T> {
  return service.put(url, data);
}

// 封装DELETE请求
export function del<T = unknown>(url: string, params?: Record<string, unknown>): Promise<T> {
  return service.delete(url, { params });
}

// 导出axios实例
export default service;
