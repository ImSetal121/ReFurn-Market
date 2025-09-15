import { HTMLAttributes, useState } from 'react'
import { z } from 'zod'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Link, useNavigate } from '@tanstack/react-router'
import { IconBrandApple } from '@tabler/icons-react'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { PasswordInput } from '@/components/password-input'
import { GoogleLoginButton } from '@/components/google-login-button'
import { login } from '@/api/auth'
import { useAuthStore } from '@/stores/authStore'

type UserAuthFormProps = HTMLAttributes<HTMLFormElement>

const formSchema = z.object({
  username: z
    .string()
    .min(1, { message: '请输入用户名' }),
  password: z
    .string()
    .min(1, {
      message: '请输入密码',
    })
})

export function UserAuthForm({ className, ...props }: UserAuthFormProps) {
  const [isLoading, setIsLoading] = useState(false)
  const navigate = useNavigate()
  // 获取URL查询参数
  const urlParams = new URLSearchParams(window.location.search)
  const redirect = urlParams.get('redirect') || undefined
  const { setAccessToken, setUser } = useAuthStore.getState().auth

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      username: '',
      password: '',
    },
  })

  async function onSubmit(data: z.infer<typeof formSchema>) {
    try {
      setIsLoading(true)
      const response = await login({
        username: data.username,
        password: data.password
      })

      // 保存token和用户信息
      setAccessToken(response.token)
      setUser(response.user)

      toast.success('登录成功')

      // 如果有重定向地址，跳转到重定向地址，否则跳转到dashboard
      if (redirect) {
        navigate({ to: redirect as string })
      } else {
        navigate({ to: '/' })
      }
    } catch (_error) {
      toast.error('登录失败，请检查用户名和密码')
    } finally {
      setIsLoading(false)
    }
  }

  const handleGoogleLoginSuccess = (data: { token: string; user: import('@/types/system').SysUser; isNewUser: boolean }) => {
    // 保存token和用户信息
    setAccessToken(data.token)
    setUser(data.user)

    if (data.isNewUser) {
      toast.success('Google注册成功，欢迎加入！')
    } else {
      toast.success('Google登录成功')
    }

    // 跳转
    if (redirect) {
      navigate({ to: redirect as string })
    } else {
      navigate({ to: '/' })
    }
  }

  const handleGoogleLoginError = (error: string) => {
    toast.error(error)
  }

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className={cn('grid gap-3', className)}
        {...props}
      >
        <FormField
          control={form.control}
          name='username'
          render={({ field }) => (
            <FormItem>
              <FormLabel>用户名</FormLabel>
              <FormControl>
                <Input placeholder='请输入用户名' {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name='password'
          render={({ field }) => (
            <FormItem className='relative'>
              <FormLabel>密码</FormLabel>
              <FormControl>
                <PasswordInput placeholder='请输入密码' {...field} />
              </FormControl>
              <FormMessage />
              <Link
                to='/forgot-password'
                className='text-muted-foreground absolute -top-0.5 right-0 text-sm font-medium hover:opacity-75'
              >
                忘记密码?
              </Link>
            </FormItem>
          )}
        />
        <Button className='mt-2' disabled={isLoading}>
          登录
        </Button>

        <div className='relative my-2'>
          <div className='absolute inset-0 flex items-center'>
            <span className='w-full border-t' />
          </div>
          <div className='relative flex justify-center text-xs uppercase'>
            <span className='bg-background text-muted-foreground px-2'>
              或者使用以下方式登录
            </span>
          </div>
        </div>

        <div className='grid grid-cols-2 gap-2'>
          <GoogleLoginButton
            onSuccess={handleGoogleLoginSuccess}
            onError={handleGoogleLoginError}
            disabled={isLoading}
          >
            Google
          </GoogleLoginButton>
          <Button variant='outline' type='button' disabled={isLoading}>
            <IconBrandApple className='h-4 w-4' /> Apple
          </Button>
        </div>
      </form>
    </Form>
  )
}
