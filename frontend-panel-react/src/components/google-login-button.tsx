import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { AuthController } from '@/api/AuthController'
import { toast } from 'sonner'
import type { SysUser } from '@/types/system'

interface GoogleLoginButtonProps {
    onSuccess?: (data: { token: string; user: SysUser; isNewUser: boolean }) => void
    onError?: (error: string) => void
    disabled?: boolean
    children?: React.ReactNode
}

export function GoogleLoginButton({
    onSuccess,
    onError,
    disabled = false,
    children = '使用 Google 登录'
}: GoogleLoginButtonProps) {
    const [isLoading, setIsLoading] = useState(false)

    const handleGoogleLogin = async () => {
        setIsLoading(true)

        try {
            // 获取Google授权URL
            const authUrl = await AuthController.getGoogleAuthorizationUrl()

            // 打开新窗口进行Google授权
            const popup = window.open(
                authUrl,
                'google-login',
                'width=500,height=600,scrollbars=yes,resizable=yes'
            )

            if (!popup) {
                throw new Error('无法打开授权窗口，请检查浏览器弹窗设置')
            }

            let isProcessing = false // 防止重复处理

            // 监听授权回调
            const messageHandler = async (event: MessageEvent) => {
                if (event.origin !== window.location.origin) {
                    return
                }

                // 防止重复处理同一个消息
                if (isProcessing) {
                    return
                }

                if (event.data?.type === 'GOOGLE_AUTH_SUCCESS') {
                    isProcessing = true
                    const { code } = event.data

                    // 立即关闭弹窗和清理监听器
                    popup.close()
                    window.removeEventListener('message', messageHandler)

                    try {
                        // 使用授权码进行登录
                        const loginResult = await AuthController.googleLogin(code)
                        onSuccess?.(loginResult)
                        toast.success('Google登录成功')
                    } catch (error: unknown) {
                        const errorMessage = error instanceof Error ? error.message : 'Google登录失败'
                        onError?.(errorMessage)
                        toast.error(errorMessage)
                    } finally {
                        setIsLoading(false)
                    }
                } else if (event.data?.type === 'GOOGLE_AUTH_ERROR') {
                    isProcessing = true
                    const errorMessage = event.data.error || 'Google授权失败'
                    onError?.(errorMessage)
                    toast.error(errorMessage)
                    popup.close()
                    window.removeEventListener('message', messageHandler)
                    setIsLoading(false)
                }
            }

            window.addEventListener('message', messageHandler)

            // 检查弹窗是否被关闭
            const checkClosed = setInterval(() => {
                if (popup.closed) {
                    clearInterval(checkClosed)
                    window.removeEventListener('message', messageHandler)
                    if (!isProcessing) {
                        setIsLoading(false)
                    }
                }
            }, 1000)

        } catch (error: unknown) {
            const errorMessage = error instanceof Error ? error.message : '启动Google登录失败'
            onError?.(errorMessage)
            toast.error(errorMessage)
            setIsLoading(false)
        }
    }

    return (
        <Button
            type="button"
            variant="outline"
            onClick={handleGoogleLogin}
            disabled={disabled || isLoading}
            className="w-full"
        >
            <svg className="w-4 h-4 mr-2" viewBox="0 0 24 24">
                <path
                    fill="currentColor"
                    d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                    fill="currentColor"
                    d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                    fill="currentColor"
                    d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                />
                <path
                    fill="currentColor"
                    d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                />
            </svg>
            {isLoading ? '登录中...' : children}
        </Button>
    )
} 