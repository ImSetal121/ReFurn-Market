import { HTMLAttributes, useState } from 'react'
import { z } from 'zod'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useNavigate } from '@tanstack/react-router'
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
import { AuthController } from '@/api/AuthController'
import { toast } from 'sonner'
import { filterInvalidValues } from '@/utils/formCheck'
import { useAuthStore } from '@/stores/authStore'

type SignUpFormProps = HTMLAttributes<HTMLFormElement>

const formSchema = z
  .object({
    username: z
      .string()
      .min(1, { message: '请输入用户名' })
      .min(3, { message: '用户名至少3个字符' })
      .max(20, { message: '用户名最多20个字符' }),
    nickname: z
      .string()
      .optional(),
    email: z
      .string()
      .optional()
      .refine((val) => !val || z.string().email().safeParse(val).success, {
        message: '邮箱格式不正确',
      }),
    phoneNumber: z
      .string()
      .optional()
      .refine((val) => !val || /^[+]?[\d\s\-()]{7,20}$/.test(val), {
        message: '手机号格式不正确',
      }),
    password: z
      .string()
      .min(1, { message: '请输入密码' })
      .min(6, { message: '密码至少6个字符' }),
    confirmPassword: z.string().min(1, { message: '请确认密码' }),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: '两次输入的密码不一致',
    path: ['confirmPassword'],
  })

export function SignUpForm({ className, ...props }: SignUpFormProps) {
  const [isLoading, setIsLoading] = useState(false)
  const navigate = useNavigate()
  const { setAccessToken, setUser } = useAuthStore.getState().auth

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      username: '',
      nickname: '',
      email: '',
      phoneNumber: '',
      password: '',
      confirmPassword: '',
    },
  })

  async function onSubmit(data: z.infer<typeof formSchema>) {
    setIsLoading(true)

    try {
      // 准备注册数据，移除confirmPassword
      const { confirmPassword, ...registerData } = data

      // 过滤空值
      const filteredData = filterInvalidValues(registerData) as {
        username: string;
        password: string;
        email?: string;
        phoneNumber?: string;
        nickname?: string;
      }

      await AuthController.register(filteredData)

      toast.success('注册成功！请登录')

      // 跳转到登录页面
      navigate({ to: '/sign-in' })

    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : '注册失败，请重试'
      toast.error(errorMessage)
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

    // 跳转到主页
    navigate({ to: '/' })
  }

  const handleGoogleLoginError = (error: string) => {
    toast.error(error)
  }

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className={cn('grid gap-4', className)}
        {...props}
      >
        <FormField
          control={form.control}
          name='username'
          render={({ field }) => (
            <FormItem>
              <FormLabel>用户名 *</FormLabel>
              <FormControl>
                <Input placeholder='请输入用户名' {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name='nickname'
          render={({ field }) => (
            <FormItem>
              <FormLabel>昵称</FormLabel>
              <FormControl>
                <Input placeholder='请输入昵称（可选）' {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name='email'
          render={({ field }) => (
            <FormItem>
              <FormLabel>邮箱</FormLabel>
              <FormControl>
                <Input
                  type='email'
                  placeholder='请输入邮箱（可选）'
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name='phoneNumber'
          render={({ field }) => (
            <FormItem>
              <FormLabel>手机号</FormLabel>
              <FormControl>
                <Input
                  placeholder='请输入手机号（可选）'
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name='password'
          render={({ field }) => (
            <FormItem>
              <FormLabel>密码 *</FormLabel>
              <FormControl>
                <PasswordInput placeholder='请输入密码' {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name='confirmPassword'
          render={({ field }) => (
            <FormItem>
              <FormLabel>确认密码 *</FormLabel>
              <FormControl>
                <PasswordInput placeholder='请再次输入密码' {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button className='mt-2' disabled={isLoading}>
          {isLoading ? '注册中...' : '创建账户'}
        </Button>

        <div className='relative my-2'>
          <div className='absolute inset-0 flex items-center'>
            <span className='w-full border-t' />
          </div>
          <div className='relative flex justify-center text-xs uppercase'>
            <span className='bg-background text-muted-foreground px-2'>
              或者使用以下方式注册
            </span>
          </div>
        </div>

        <GoogleLoginButton
          onSuccess={handleGoogleLoginSuccess}
          onError={handleGoogleLoginError}
          disabled={isLoading}
        >
          使用 Google 注册
        </GoogleLoginButton>
      </form>
    </Form>
  )
}
