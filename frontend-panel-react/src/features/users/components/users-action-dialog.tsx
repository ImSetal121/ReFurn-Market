'use client'

import { z } from 'zod'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
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
import { SelectDropdown } from '@/components/select-dropdown'
import { AvatarUploader } from './avatar-uploader'
import { filterInvalidValues } from '@/utils/formCheck'
import { useUsers } from '../context/users-context'
import { useAddUser, useUpdateUser } from '../data/users-service'
import { User } from '../data/schema'

const formSchema = z
  .object({
    username: z.string().min(1, { message: '用户名是必填项' }),
    nickname: z.string().optional(),
    email: z
      .string()
      .optional()
      .refine((val) => !val || z.string().email().safeParse(val).success, {
        message: '邮箱格式不正确',
      }),
    phoneNumber: z.string().optional(),
    sex: z.enum(['M', 'F', '', 'unset']).optional(),
    wechatOpenId: z.string().optional(),
    avatar: z.string().optional(),
    googleSub: z.string().optional(),
    appleSub: z.string().optional(),
    password: z.string().transform((pwd) => pwd.trim()),
    confirmPassword: z.string().transform((pwd) => pwd.trim()),
    roleId: z.number().optional(),
    isEdit: z.boolean(),
  })
  .superRefine(({ isEdit, password, confirmPassword }, ctx) => {
    if (!isEdit || (isEdit && password !== '')) {
      if (password === '') {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: '密码是必填项',
          path: ['password'],
        })
      }

      if (password.length < 6) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: '密码至少需要6个字符',
          path: ['password'],
        })
      }

      if (password !== confirmPassword) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: '两次输入的密码不一致',
          path: ['confirmPassword'],
        })
      }
    }
  })

type UserForm = z.infer<typeof formSchema>

interface Props {
  currentRow?: User
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function UsersActionDialog({ currentRow, open, onOpenChange }: Props) {
  const isEdit = !!currentRow
  const { roles } = useUsers()
  const addUserMutation = useAddUser()
  const updateUserMutation = useUpdateUser()

  const form = useForm<UserForm>({
    resolver: zodResolver(formSchema),
    defaultValues: isEdit
      ? {
        username: currentRow.username,
        nickname: currentRow.nickname || '',
        email: currentRow.email || '',
        phoneNumber: currentRow.phoneNumber || '',
        sex: currentRow.sex === '' || !currentRow.sex ? 'unset' : currentRow.sex,
        wechatOpenId: currentRow.wechatOpenId || '',
        avatar: currentRow.avatar || '',
        googleSub: currentRow.googleSub || '',
        appleSub: currentRow.appleSub || '',
        roleId: currentRow.roleId,
        password: '',
        confirmPassword: '',
        isEdit,
      }
      : {
        username: '',
        nickname: '',
        email: '',
        phoneNumber: '',
        sex: 'unset',
        wechatOpenId: '',
        avatar: '',
        googleSub: '',
        appleSub: '',
        roleId: undefined,
        password: '',
        confirmPassword: '',
        isEdit,
      },
  })

  const onSubmit = async (values: UserForm) => {
    try {
      const userData: User = {
        username: values.username,
        nickname: values.nickname,
        email: values.email,
        phoneNumber: values.phoneNumber,
        sex: values.sex === 'unset' ? '' : values.sex,
        wechatOpenId: values.wechatOpenId,
        avatar: values.avatar,
        googleSub: values.googleSub,
        appleSub: values.appleSub,
        roleId: values.roleId,
        password: values.password || undefined,
      }

      // 过滤掉空值
      const filteredUserData = filterInvalidValues(userData) as User;

      if (isEdit && currentRow) {
        await updateUserMutation.mutateAsync({
          ...filteredUserData,
          id: currentRow.id,
        })
      } else {
        await addUserMutation.mutateAsync(filteredUserData)
      }

      form.reset()
      onOpenChange(false)
    } catch (_error) {
      // 错误已在mutation中处理，无需额外操作
    }
  }

  const roleOptions = roles.map(role => ({
    value: role.id!.toString(),
    label: role.name,
  }))

  const sexOptions = [
    { value: 'unset', label: '未设置' },
    { value: 'M', label: '男' },
    { value: 'F', label: '女' },
  ]

  const isLoading = addUserMutation.isPending || updateUserMutation.isPending

  return (
    <Dialog
      open={open}
      onOpenChange={(state) => {
        if (!isLoading) {
          form.reset()
          onOpenChange(state)
        }
      }}
    >
      <DialogContent className='sm:max-w-2xl'>
        <DialogHeader className='text-left'>
          <DialogTitle>{isEdit ? '编辑用户' : '添加用户'}</DialogTitle>
          <DialogDescription>
            {isEdit ? '更新用户信息' : '创建新用户'}
          </DialogDescription>
        </DialogHeader>
        <div className='-mr-4 h-[32rem] w-full overflow-y-auto py-1 pr-4'>
          <Form {...form}>
            <form
              id='user-form'
              onSubmit={form.handleSubmit(onSubmit)}
              className='space-y-4 p-0.5'
            >
              <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                <FormField
                  control={form.control}
                  name='username'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>用户名 *</FormLabel>
                      <FormControl>
                        <Input
                          placeholder='请输入用户名'
                          autoComplete='off'
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name='nickname'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>昵称</FormLabel>
                      <FormControl>
                        <Input
                          placeholder='请输入昵称'
                          autoComplete='off'
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name='email'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>邮箱</FormLabel>
                      <FormControl>
                        <Input
                          placeholder='请输入邮箱'
                          type='email'
                          autoComplete='off'
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
                    <FormItem className='space-y-2'>
                      <FormLabel>手机号</FormLabel>
                      <FormControl>
                        <Input
                          placeholder='请输入手机号'
                          autoComplete='off'
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name='sex'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>性别</FormLabel>
                      <FormControl>
                        <SelectDropdown
                          placeholder='请选择性别'
                          items={sexOptions}
                          defaultValue={field.value || ''}
                          onValueChange={(value) => field.onChange(value)}
                          isControlled={true}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name='roleId'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>角色</FormLabel>
                      <FormControl>
                        <SelectDropdown
                          placeholder='请选择角色'
                          items={roleOptions}
                          defaultValue={field.value?.toString() || ''}
                          onValueChange={(value) => field.onChange(value ? parseInt(value) : undefined)}
                          isControlled={true}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <FormField
                control={form.control}
                name='wechatOpenId'
                render={({ field }) => (
                  <FormItem className='space-y-2'>
                    <FormLabel>微信OpenID</FormLabel>
                    <FormControl>
                      <Input
                        placeholder='请输入微信OpenID'
                        autoComplete='off'
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name='avatar'
                render={({ field }) => (
                  <FormItem className='space-y-2'>
                    <FormLabel>用户头像</FormLabel>
                    <FormControl>
                      <AvatarUploader
                        value={field.value}
                        onChange={(value) => field.onChange(value)}
                        disabled={isLoading}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                <FormField
                  control={form.control}
                  name='googleSub'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>Google账号ID</FormLabel>
                      <FormControl>
                        <Input
                          placeholder='请输入Google账号ID'
                          autoComplete='off'
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name='appleSub'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>Apple账号ID</FormLabel>
                      <FormControl>
                        <Input
                          placeholder='请输入Apple账号ID'
                          autoComplete='off'
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <div className='grid grid-cols-1 md:grid-cols-2 gap-4'>
                <FormField
                  control={form.control}
                  name='password'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>
                        {isEdit ? '新密码' : '密码 *'}
                      </FormLabel>
                      <FormControl>
                        <PasswordInput
                          placeholder={isEdit ? '留空则不修改' : '请输入密码'}
                          autoComplete='new-password'
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name='confirmPassword'
                  render={({ field }) => (
                    <FormItem className='space-y-2'>
                      <FormLabel>确认密码</FormLabel>
                      <FormControl>
                        <PasswordInput
                          placeholder='请再次输入密码'
                          autoComplete='new-password'
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
            </form>
          </Form>
        </div>
        <DialogFooter>
          <Button
            type='button'
            variant='outline'
            onClick={() => onOpenChange(false)}
            disabled={isLoading}
          >
            取消
          </Button>
          <Button
            type='submit'
            form='user-form'
            disabled={isLoading}
          >
            {isLoading ? '保存中...' : '保存'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
