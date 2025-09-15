import Cookies from 'js-cookie'
import { create } from 'zustand'
import type { SysUser } from '@/types/system'

const ACCESS_TOKEN = 'reflip_token'
const USER_INFO = 'reflip_user_info'

// 兼容后端返回的SysUser类型
type AuthUser = SysUser

interface AuthState {
  auth: {
    user: AuthUser | null
    setUser: (user: AuthUser | null) => void
    accessToken: string
    setAccessToken: (accessToken: string) => void
    resetAccessToken: () => void
    reset: () => void
  }
}

export const useAuthStore = create<AuthState>()((set) => {
  // 从 Cookie 中获取 token
  const cookieState = Cookies.get(ACCESS_TOKEN)
  // 如果 Cookie 中有 token，则使用它，否则使用空字符串
  const initToken = cookieState || ''
  
  // 从 localStorage 中获取用户信息
  let initUser = null
  try {
    const userInfoStr = localStorage.getItem(USER_INFO)
    if (userInfoStr) {
      initUser = JSON.parse(userInfoStr)
    }
  } catch (error) {
    console.error('解析用户信息失败:', error)
  }
  
  return {
    auth: {
      user: initUser,
      setUser: (user) =>
        set((state) => {
          // 将用户信息存储到 localStorage
          if (user) {
            localStorage.setItem(USER_INFO, JSON.stringify(user))
          } else {
            localStorage.removeItem(USER_INFO)
          }
          return { ...state, auth: { ...state.auth, user } }
        }),
      accessToken: initToken,
      setAccessToken: (accessToken) =>
        set((state) => {
          // 直接将token存储到Cookie中，不需要JSON.stringify
          Cookies.set(ACCESS_TOKEN, accessToken)
          return { ...state, auth: { ...state.auth, accessToken } }
        }),
      resetAccessToken: () =>
        set((state) => {
          Cookies.remove(ACCESS_TOKEN)
          return { ...state, auth: { ...state.auth, accessToken: '' } }
        }),
      reset: () =>
        set((state) => {
          // 清除Cookie中的token
          Cookies.remove(ACCESS_TOKEN)
          // 清除localStorage中的用户信息
          localStorage.removeItem(USER_INFO)
          return {
            ...state,
            auth: { ...state.auth, user: null, accessToken: '' },
          }
        }),
    },
  }
})

// export const useAuth = () => useAuthStore((state) => state.auth)
