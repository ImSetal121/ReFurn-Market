import { ColumnDef } from '@tanstack/react-table'
import { cn } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import LongText from '@/components/long-text'
import { User } from '../data/schema'
import { DataTableColumnHeader } from './data-table-column-header'
import { DataTableRowActions } from './data-table-row-actions'

export const columns: ColumnDef<User>[] = [
  {
    id: 'select',
    header: ({ table }) => (
      <Checkbox
        checked={
          table.getIsAllPageRowsSelected() ||
          (table.getIsSomePageRowsSelected() && 'indeterminate')
        }
        onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
        aria-label='Select all'
        className='translate-y-[2px]'
      />
    ),
    meta: {
      className: cn(
        'sticky md:table-cell left-0 z-10 rounded-tl',
        'bg-background transition-colors duration-200 group-hover/row:bg-muted group-data-[state=selected]/row:bg-muted'
      ),
    },
    cell: ({ row }) => (
      <Checkbox
        checked={row.getIsSelected()}
        onCheckedChange={(value) => row.toggleSelected(!!value)}
        aria-label='Select row'
        className='translate-y-[2px]'
      />
    ),
    enableSorting: false,
    enableHiding: false,
  },
  {
    accessorKey: 'id',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='ID' />
    ),
    cell: ({ row }) => (
      <div className='w-fit text-nowrap font-mono text-sm'>{row.getValue('id')}</div>
    ),
    meta: { className: 'w-16' },
  },
  {
    accessorKey: 'username',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='用户名' />
    ),
    cell: ({ row }) => (
      <LongText className='max-w-36 font-medium'>{row.getValue('username')}</LongText>
    ),
    meta: {
      className: cn(
        'drop-shadow-[0_1px_2px_rgb(0_0_0_/_0.1)] dark:drop-shadow-[0_1px_2px_rgb(255_255_255_/_0.1)] lg:drop-shadow-none',
        'bg-background transition-colors duration-200 group-hover/row:bg-muted group-data-[state=selected]/row:bg-muted',
        'sticky left-6 md:table-cell'
      ),
    },
    enableHiding: false,
  },
  {
    accessorKey: 'avatar',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='头像' />
    ),
    cell: ({ row }) => {
      const avatar = row.getValue('avatar') as string
      const nickname = row.getValue('nickname') as string
      const username = row.getValue('username') as string

      return (
        <Avatar className='h-8 w-8'>
          <AvatarImage src={avatar} alt={nickname || username} />
          <AvatarFallback className='text-xs'>
            {(nickname || username)?.charAt(0)?.toUpperCase()}
          </AvatarFallback>
        </Avatar>
      )
    },
    meta: { className: 'w-16' },
    enableSorting: false,
  },
  {
    accessorKey: 'nickname',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='昵称' />
    ),
    cell: ({ row }) => {
      const nickname = row.getValue('nickname') as string
      return <LongText className='max-w-36'>{nickname || '-'}</LongText>
    },
    meta: { className: 'w-36' },
    filterFn: 'includesString',
  },
  {
    accessorKey: 'email',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='邮箱' />
    ),
    cell: ({ row }) => {
      const email = row.getValue('email') as string
      return <div className='w-fit text-nowrap'>{email || '-'}</div>
    },
    filterFn: 'includesString',
  },
  {
    accessorKey: 'phoneNumber',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='手机号' />
    ),
    cell: ({ row }) => {
      const phoneNumber = row.getValue('phoneNumber') as string
      return <div className='font-mono'>{phoneNumber || '-'}</div>
    },
    enableSorting: false,
    filterFn: 'includesString',
  },
  {
    accessorKey: 'sex',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='性别' />
    ),
    cell: ({ row }) => {
      const sex = row.getValue('sex') as string
      const sexMap = {
        'M': '男',
        'F': '女',
      }
      return <div>{sexMap[sex as keyof typeof sexMap] || '未设置'}</div>
    },
    enableSorting: false,
    meta: { className: 'w-20' },
    filterFn: (row, _id, value) => {
      const sex = row.getValue('sex') as string
      const normalizedSex = (sex === '' || !sex) ? 'unset' : sex
      return value.includes(normalizedSex)
    },
  },
  {
    accessorKey: 'roleName',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='角色' />
    ),
    cell: ({ row }) => {
      const roleName = row.original.roleName || row.original.clientRole
      return (
        <div className='flex items-center gap-x-2'>
          <Badge variant='secondary' className='text-xs'>
            {roleName || '未分配'}
          </Badge>
        </div>
      )
    },
    enableSorting: false,
  },
  {
    accessorKey: 'wechatOpenId',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='微信OpenID' />
    ),
    cell: ({ row }) => {
      const wechatOpenId = row.getValue('wechatOpenId') as string
      return (
        <div className='max-w-32'>
          {wechatOpenId ? (
            <LongText className='font-mono text-xs'>{wechatOpenId}</LongText>
          ) : (
            <span className='text-muted-foreground'>未绑定</span>
          )}
        </div>
      )
    },
    enableSorting: false,
  },
  {
    accessorKey: 'googleSub',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='Google账号' />
    ),
    cell: ({ row }) => {
      const googleSub = row.getValue('googleSub') as string
      const googleLinkedTime = row.original.googleLinkedTime
      return (
        <div className='max-w-32'>
          {googleSub ? (
            <div>
              <LongText className='font-mono text-xs'>{googleSub}</LongText>
              {googleLinkedTime && (
                <div className='text-xs text-muted-foreground mt-1'>
                  绑定时间: {new Date(googleLinkedTime).toLocaleDateString('zh-CN')}
                </div>
              )}
            </div>
          ) : (
            <span className='text-muted-foreground'>未绑定</span>
          )}
        </div>
      )
    },
    enableSorting: false,
  },
  {
    accessorKey: 'appleSub',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='Apple账号' />
    ),
    cell: ({ row }) => {
      const appleSub = row.getValue('appleSub') as string
      const appleLinkedTime = row.original.appleLinkedTime
      return (
        <div className='max-w-32'>
          {appleSub ? (
            <div>
              <LongText className='font-mono text-xs'>{appleSub}</LongText>
              {appleLinkedTime && (
                <div className='text-xs text-muted-foreground mt-1'>
                  绑定时间: {new Date(appleLinkedTime).toLocaleDateString('zh-CN')}
                </div>
              )}
            </div>
          ) : (
            <span className='text-muted-foreground'>未绑定</span>
          )}
        </div>
      )
    },
    enableSorting: false,
  },
  {
    accessorKey: 'lastLoginIp',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='最后登录IP' />
    ),
    cell: ({ row }) => {
      const lastLoginIp = row.getValue('lastLoginIp') as string
      return <div className='font-mono text-sm'>{lastLoginIp || '-'}</div>
    },
    enableSorting: false,
  },
  {
    accessorKey: 'lastLoginDate',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='最后登录时间' />
    ),
    cell: ({ row }) => {
      const lastLoginDate = row.getValue('lastLoginDate') as string
      if (!lastLoginDate) return '-'

      try {
        const date = new Date(lastLoginDate)
        return (
          <div className='text-sm'>
            <div>{date.toLocaleDateString('zh-CN')}</div>
            <div className='text-xs text-muted-foreground'>
              {date.toLocaleTimeString('zh-CN', { hour12: false })}
            </div>
          </div>
        )
      } catch {
        return <div className='text-sm'>{lastLoginDate}</div>
      }
    },
    enableSorting: true,
  },
  {
    accessorKey: 'status',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='状态' />
    ),
    cell: ({ row }) => {
      const isDelete = row.original.isDelete
      const status = isDelete ? 'inactive' : 'active'
      const statusMap = {
        active: { label: '正常', color: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' },
        inactive: { label: '已删除', color: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300' },
        suspended: { label: '暂停', color: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300' },
      }
      const statusInfo = statusMap[status] || statusMap.active

      return (
        <div className='flex space-x-2'>
          <Badge variant='outline' className={cn('capitalize', statusInfo.color)}>
            {statusInfo.label}
          </Badge>
        </div>
      )
    },
    filterFn: (row, _id, value) => {
      const isDelete = row.original.isDelete
      const status = isDelete ? 'inactive' : 'active'
      return value.includes(status)
    },
    enableHiding: false,
    enableSorting: false,
  },
  {
    accessorKey: 'createBy',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='创建人' />
    ),
    cell: ({ row }) => {
      const createBy = row.getValue('createBy') as string
      return <div className='text-sm'>{createBy || '-'}</div>
    },
    enableSorting: false,
  },
  {
    accessorKey: 'createTime',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='创建时间' />
    ),
    cell: ({ row }) => {
      const createTime = row.getValue('createTime') as string
      if (!createTime) return '-'

      try {
        const date = new Date(createTime)
        return (
          <div className='text-sm'>
            <div>{date.toLocaleDateString('zh-CN')}</div>
            <div className='text-xs text-muted-foreground'>
              {date.toLocaleTimeString('zh-CN', { hour12: false })}
            </div>
          </div>
        )
      } catch {
        return <div className='text-sm'>{createTime}</div>
      }
    },
    enableSorting: true,
  },
  {
    accessorKey: 'updateBy',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='更新人' />
    ),
    cell: ({ row }) => {
      const updateBy = row.getValue('updateBy') as string
      return <div className='text-sm'>{updateBy || '-'}</div>
    },
    enableSorting: false,
  },
  {
    accessorKey: 'updateTime',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title='更新时间' />
    ),
    cell: ({ row }) => {
      const updateTime = row.getValue('updateTime') as string
      if (!updateTime) return '-'

      try {
        const date = new Date(updateTime)
        return (
          <div className='text-sm'>
            <div>{date.toLocaleDateString('zh-CN')}</div>
            <div className='text-xs text-muted-foreground'>
              {date.toLocaleTimeString('zh-CN', { hour12: false })}
            </div>
          </div>
        )
      } catch {
        return <div className='text-sm'>{updateTime}</div>
      }
    },
    enableSorting: true,
  },
  {
    id: 'actions',
    cell: DataTableRowActions,
    meta: {
      className: 'sticky right-0 bg-background transition-colors duration-200 group-hover/row:bg-muted group-data-[state=selected]/row:bg-muted'
    },
  },
]
