import { useEffect, useRef } from 'react'

export default function GoogleCallback() {
    const hasProcessed = useRef(false)

    useEffect(() => {
        // 防止重复处理
        if (hasProcessed.current) {
            return
        }
        hasProcessed.current = true

        // 从URL获取授权码或错误信息
        const urlParams = new URLSearchParams(window.location.search)
        const code = urlParams.get('code')
        const error = urlParams.get('error')

        if (error) {
            // 向父窗口发送错误信息
            window.opener?.postMessage({
                type: 'GOOGLE_AUTH_ERROR',
                error: error
            }, window.location.origin)
        } else if (code) {
            // 向父窗口发送授权码
            window.opener?.postMessage({
                type: 'GOOGLE_AUTH_SUCCESS',
                code: code
            }, window.location.origin)
        } else {
            // 未知错误
            window.opener?.postMessage({
                type: 'GOOGLE_AUTH_ERROR',
                error: '未收到授权码或错误信息'
            }, window.location.origin)
        }

        // 延迟关闭窗口，确保消息发送完成
        setTimeout(() => {
            window.close()
        }, 100)
    }, [])

    return (
        <div className="flex items-center justify-center min-h-screen">
            <div className="text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
                <p className="text-sm text-muted-foreground">正在处理Google授权...</p>
            </div>
        </div>
    )
} 