import { get, post } from '@/utils/request';
import type { LoginRequest, LoginResponse, UserInfo } from '@/types/api';
import type { SysMenu, SysUser } from '@/types/system';

/**
 * 认证控制器API
 */
export class AuthController {
    /**
     * 登录
     * @param data 登录请求参数
     */
    static login(data: LoginRequest): Promise<LoginResponse> {
        return post('/auth/login', data);
    }

    /**
     * 登出
     */
    static logout(): Promise<void> {
        return post('/auth/logout');
    }

    /**
     * 注册
     * @param data 注册请求参数
     */
    static register(data: {
        username: string;
        password: string;
        email?: string;
        phoneNumber?: string;
        nickname?: string;
    }): Promise<SysUser> {
        return post('/auth/register', data);
    }

    /**
     * 获取用户信息
     */
    static getUserInfo(): Promise<UserInfo> {
        return get('/auth/info');
    }

    /**
     * 获取用户菜单
     */
    static getMenus(): Promise<SysMenu[]> {
        return get('/auth/menus');
    }

    /**
     * 获取Google授权URL
     */
    static getGoogleAuthorizationUrl(): Promise<string> {
        return get('/auth/google/authorization-url');
    }

    /**
     * Google登录
     * @param code Google授权码
     */
    static googleLogin(code: string): Promise<{
        token: string;
        user: SysUser;
        isNewUser: boolean;
    }> {
        return post('/auth/google/login', { code });
    }
}

// 导出默认实例方法（兼容现有代码）
export const login = AuthController.login;
export const logout = AuthController.logout;
export const getUserInfo = AuthController.getUserInfo;
export const getMenus = AuthController.getMenus;
export const register = AuthController.register; 