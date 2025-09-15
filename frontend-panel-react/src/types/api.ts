// src/types/api.ts
import type { SysUser, SysRole, SysMenu } from './system';

export interface BaseResponse<T> {
  code: number;
  message: string;
  data: T;
  success: boolean;
  timestamp: number;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: SysUser;
}

export interface UserInfo {
  user: SysUser;
  role: SysRole;
}

// 通用API响应类型
export type ApiResponse<T> = BaseResponse<T>

// 分页响应类型
export interface PageResponse<T> {
  records: T[]
  total: number
  size: number
  current: number
  pages: number
}
