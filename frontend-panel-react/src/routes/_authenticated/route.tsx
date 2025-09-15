import { createFileRoute, redirect } from '@tanstack/react-router'
import { toast } from 'sonner'
import Cookies from 'js-cookie'
import { AuthenticatedLayout } from '@/components/layout/authenticated-layout'
import { useAuthStore } from '@/stores/authStore'

export const Route = createFileRoute('/_authenticated')({
  component: AuthenticatedLayout,
  beforeLoad: async () => {
    // 直接从 Cookie 中检查是否有token
    const token = Cookies.get('reflip_token')
    
    // 同时检查 store 中的 token
    const { accessToken } = useAuthStore.getState().auth
    
    // 如果 Cookie 和 store 中都没有 token，则重定向到登录页
    if (!token && !accessToken) {
      console.log('未登录，重定向到登录页')
      toast.error('请先登录')
      
      // 强制清除状态
      useAuthStore.getState().auth.reset()
      
      throw redirect({
        to: '/sign-in-2',
        search: {
          redirect: window.location.pathname + window.location.search
        }
      })
    }
    
    // 如果 Cookie 中有 token 但 store 中没有，则更新 store
    if (token && !accessToken) {
      useAuthStore.getState().auth.setAccessToken(token)
    }
    
    return {}
  }
})
