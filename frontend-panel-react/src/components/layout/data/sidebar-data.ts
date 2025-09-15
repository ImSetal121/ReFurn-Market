import {
  IconBarrierBlock,
  IconBrowserCheck,
  IconBug,
  IconChecklist,
  IconError404,
  IconHelp,
  IconLayoutDashboard,
  IconLock,
  IconLockAccess,
  IconMessages,
  IconNotification,
  IconPackages,
  IconPalette,
  IconServerOff,
  IconSettings,
  IconTool,
  IconUserCog,
  IconUserOff,
  IconUsers,
  IconShield,
  IconMenu2,
  IconBuilding,
  IconReceipt,
  IconFileText,
} from '@tabler/icons-react'
import { AudioWaveform, Command, GalleryVerticalEnd } from 'lucide-react'
// import { ClerkLogo } from '@/assets/clerk-logo'
import { type SidebarData } from '../types'
// 不再需要导入useAuthStore

// 定义用户类型
interface User {
  nickname?: string
  email?: string
  avatar?: string
}

// 创建一个函数来获取侧边栏数据，这样可以动态获取用户信息
export const getSidebarData = (user: User | null = null): SidebarData => {
  return {
    user: {
      name: user?.nickname || '未登录',
      email: user?.email || 'guest@example.com',
      avatar: user?.avatar || '/avatars/shadcn.jpg',
    },
    teams: [
      {
        name: 'ReFlip Admin',
        logo: Command,
        plan: 'ReFlip v1.0.0',
      },
      // {
      //   name: 'Acme Inc',
      //   logo: GalleryVerticalEnd,
      //   plan: 'Enterprise',
      // },
      // {
      //   name: 'Acme Corp.',
      //   logo: AudioWaveform,
      //   plan: 'Startup',
      // },
    ],
    navGroups: [
      {
        title: 'General',
        items: [
          {
            title: 'Dashboard',
            url: '/',
            icon: IconLayoutDashboard,
          }
          // ,{
          //   title: 'Tasks',
          //   url: '/tasks',
          //   icon: IconChecklist,
          // },
          // {
          //   title: 'Apps',
          //   url: '/apps',
          //   icon: IconPackages,
          // },
          // {
          //   title: 'Chats',
          //   url: '/chats',
          //   badge: '3',
          //   icon: IconMessages,
          // },
          // {
          //   title: 'Secured by Clerk',
          //   icon: ClerkLogo,
          //   items: [
          //     {
          //       title: 'Sign In',
          //       url: '/clerk/sign-in',
          //     },
          //     {
          //       title: 'Sign Up',
          //       url: '/clerk/sign-up',
          //     },
          //     {
          //       title: 'User Management',
          //       url: '/clerk/user-management',
          //     },
          //   ],
          // },
        ],
      },
      {
        title: 'System',
        items: [
          {
            title: 'Users',
            url: '/users',
            icon: IconUsers,
          },
          {
            title: 'Roles',
            url: '/roles',
            icon: IconShield,
          },
          {
            title: 'Menus',
            url: '/menus',
            icon: IconMenu2,
          }
        ]
      },
      {
        title: 'Service',
        items: [
          {
            title: 'Products',
            url: '/products',
            icon: IconPackages,
          },
          {
            title: 'Warehouses',
            url: '/warehouses',
            icon: IconBuilding,
          },
          {
            title: 'Auction Logistics',
            url: '/product-auction-logistics',
            icon: IconTool,
          },
          {
            title: 'Warehouse Stock',
            url: '/warehouse-stock',
            icon: IconPackages,
          },
          {
            title: 'Internal Logistics',
            url: '/internal-logistics-task',
            icon: IconTool,
          },
          {
            title: 'Sales Records',
            url: '/product-sell-records',
            icon: IconReceipt,
          },
          {
            title: 'Return Records',
            url: '/product-return-records',
            icon: IconReceipt,
          },
          {
            title: 'Return to Seller',
            url: '/product-return-to-seller',
            icon: IconReceipt,
          },
          {
            title: 'Balance Details',
            url: '/balance-details',
            icon: IconReceipt,
          },
          {
            title: 'Bill Items',
            url: '/bill-items',
            icon: IconFileText,
          }
        ]
      },
      // {
      //   title: 'Pages',
      //   items: [
      //     {
      //       title: 'Auth',
      //       icon: IconLockAccess,
      //       items: [
      //         {
      //           title: 'Sign In',
      //           url: '/sign-in',
      //         },
      //         {
      //           title: 'Sign In (2 Col)',
      //           url: '/sign-in-2',
      //         },
      //         {
      //           title: 'Sign Up',
      //           url: '/sign-up',
      //         },
      //         {
      //           title: 'Forgot Password',
      //           url: '/forgot-password',
      //         },
      //         {
      //           title: 'OTP',
      //           url: '/otp',
      //         },
      //       ],
      //     },
      //     {
      //       title: 'Errors',
      //       icon: IconBug,
      //       items: [
      //         {
      //           title: 'Unauthorized',
      //           url: '/401',
      //           icon: IconLock,
      //         },
      //         {
      //           title: 'Forbidden',
      //           url: '/403',
      //           icon: IconUserOff,
      //         },
      //         {
      //           title: 'Not Found',
      //           url: '/404',
      //           icon: IconError404,
      //         },
      //         {
      //           title: 'Internal Server Error',
      //           url: '/500',
      //           icon: IconServerOff,
      //         },
      //         {
      //           title: 'Maintenance Error',
      //           url: '/503',
      //           icon: IconBarrierBlock,
      //         },
      //       ],
      //     },
      //   ],
      // },
      // {
      //   title: 'Other',
      //   items: [
      //     {
      //       title: 'Settings',
      //       icon: IconSettings,
      //       items: [
      //         {
      //           title: 'Profile',
      //           url: '/settings',
      //           icon: IconUserCog,
      //         },
      //         {
      //           title: 'Account',
      //           url: '/settings/account',
      //           icon: IconTool,
      //         },
      //         {
      //           title: 'Appearance',
      //           url: '/settings/appearance',
      //           icon: IconPalette,
      //         },
      //         {
      //           title: 'Notifications',
      //           url: '/settings/notifications',
      //           icon: IconNotification,
      //         },
      //         {
      //           title: 'Display',
      //           url: '/settings/display',
      //           icon: IconBrowserCheck,
      //         },
      //       ],
      //     },
      //     {
      //       title: 'Help Center',
      //       url: '/help-center',
      //       icon: IconHelp,
      //     },
      //   ],
      // },
    ],
  }
}

// 基础数据结构
export const sidebarData: SidebarData = {
  user: {
    name: '未登录',
    email: 'guest@example.com',
    avatar: '/avatars/shadcn.jpg',
  },
  teams: [
    {
      name: 'Shadcn Admin',
      logo: Command,
      plan: 'Vite + ShadcnUI',
    },
    {
      name: 'Acme Inc',
      logo: GalleryVerticalEnd,
      plan: 'Enterprise',
    },
    {
      name: 'Acme Corp.',
      logo: AudioWaveform,
      plan: 'Premium',
    },
  ],
  navGroups: [
    {
      title: 'Overview',
      items: [
        {
          title: 'Dashboard',
          url: '/',
          icon: IconLayoutDashboard,
        },
        {
          title: 'Users',
          url: '/settings',
          icon: IconUsers,
        },
        {
          title: 'Settings',
          url: '/settings',
          icon: IconSettings,
        },
      ],
    },
    {
      title: 'UI Components',
      items: [
        {
          title: 'Colors',
          url: '/settings',
          icon: IconPalette,
        },
        {
          title: 'Typography',
          url: '/settings',
          icon: IconPackages,
        },
        {
          title: 'Authentication',
          items: [
            {
              title: 'Sign In',
              url: '/sign-in',
              icon: IconLock,
            },
            {
              title: 'Sign Up',
              url: '/sign-up',
              icon: IconUserCog,
            },
            {
              title: 'Forgot Password',
              url: '/forgot-password',
              icon: IconLockAccess,
            },
            {
              title: 'Reset Password',
              url: '/forgot-password',
              icon: IconLockAccess,
            },
          ],
        },
        {
          title: 'Error Pages',
          items: [
            {
              title: '403',
              url: '/403',
              icon: IconBarrierBlock,
            },
            {
              title: '404',
              url: '/404',
              icon: IconError404,
            },
            {
              title: '500',
              url: '/500',
              icon: IconServerOff,
            },
            {
              title: 'Maintenance',
              url: '/500',
              icon: IconTool,
            },
          ],
        },
      ],
    },
    {
      title: 'Forms',
      items: [
        {
          title: 'Input',
          url: '/settings',
          icon: IconBrowserCheck,
        },
        {
          title: 'Validation',
          url: '/settings',
          icon: IconChecklist,
        },
        {
          title: 'Wizard',
          url: '/settings',
          icon: IconBug,
        },
      ],
    },
    {
      title: 'Extra Pages',
      items: [
        {
          title: 'Profile',
          url: '/settings',
          icon: IconUserOff,
        },
        {
          title: 'Notifications',
          url: '/settings',
          icon: IconNotification,
        },
        {
          title: 'Chat',
          url: '/settings',
          icon: IconMessages,
        },
        {
          title: 'Help Center',
          url: '/settings',
          icon: IconHelp,
        },
      ],
    }
  ]
}
