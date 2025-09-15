'use client'

import { useState } from 'react'
import { IconAlertTriangle } from '@tabler/icons-react'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { ConfirmDialog } from '@/components/confirm-dialog'
import { useDeleteUser } from '../data/users-service'
import { User } from '../data/schema'

interface Props {
  open: boolean
  onOpenChange: (open: boolean) => void
  currentRow: User
}

export function UsersDeleteDialog({ open, onOpenChange, currentRow }: Props) {
  const [value, setValue] = useState('')
  const deleteUserMutation = useDeleteUser()

  const handleDelete = async () => {
    if (value.trim() !== currentRow.username || !currentRow.id) return

    try {
      await deleteUserMutation.mutateAsync(currentRow.id)
      onOpenChange(false)
      setValue('')
    } catch (_error) {
      // 错误已在mutation中处理
    }
  }

  const isLoading = deleteUserMutation.isPending

  return (
    <ConfirmDialog
      open={open}
      onOpenChange={(state) => {
        if (!isLoading) {
          setValue('')
          onOpenChange(state)
        }
      }}
      handleConfirm={handleDelete}
      disabled={value.trim() !== currentRow.username || isLoading}
      title={
        <span className='text-destructive'>
          <IconAlertTriangle
            className='stroke-destructive mr-1 inline-block'
            size={18}
          />{' '}
          删除用户
        </span>
      }
      desc={
        <div className='space-y-4'>
          <p className='mb-2'>
            确定要删除用户{' '}
            <span className='font-bold'>{currentRow.username}</span> 吗？
            <br />
            此操作将永久删除该用户{currentRow.roleName ? `（角色：${currentRow.roleName}）` : ''}，
            此操作无法撤销。
          </p>

          <Label className='my-2'>
            用户名确认：
            <Input
              value={value}
              onChange={(e) => setValue(e.target.value)}
              placeholder='请输入用户名以确认删除'
              disabled={isLoading}
            />
          </Label>

          <Alert variant='destructive'>
            <AlertTitle>警告！</AlertTitle>
            <AlertDescription>
              请谨慎操作，此操作无法回滚。
            </AlertDescription>
          </Alert>
        </div>
      }
      confirmText={isLoading ? '删除中...' : '删除'}
      destructive
    />
  )
}
