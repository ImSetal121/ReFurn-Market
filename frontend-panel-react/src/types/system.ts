// src/types/system.ts

export interface BasePageQuery {
  current?: number;
  size?: number;
}

// 菜单
export interface SysMenu {
  id?: number;
  menuName: string;
  parentId?: number;
  orderNum?: number;
  path?: string;
  component?: string;
  query?: string;
  routeName?: string;
  isFrame?: number;
  isCache?: number;
  menuType?: string;
  visible?: string;
  status?: string;
  perms?: string;
  icon?: string;
  createBy?: string;
  createTime?: string;
  updateBy?: string;
  updateTime?: string;
  remark?: string;
}

export interface MenuQuery extends BasePageQuery {
  menuName?: string;
  status?: string;
}

// 角色
export interface SysRole {
  id?: number;
  key: string;
  name: string;
  description?: string;
  order?: number;
  status?: string;
  createBy?: string;
  createTime?: string;
  updateBy?: string;
  updateTime?: string;
}

export interface RoleQuery extends BasePageQuery {
  key?: string;
  name?: string;
}

// 用户
export interface SysUser {
  id?: number;
  username: string;
  password?: string;
  roleId?: number;
  wechatOpenId?: string;
  avatar?: string;
  nickname?: string;
  email?: string;
  phoneNumber?: string;
  sex?: string;
  lastLoginIp?: string;
  lastLoginDate?: string;
  createBy?: string;
  createTime?: string;
  updateBy?: string;
  updateTime?: string;
  isDelete?: boolean;
}

export interface UserQuery extends BasePageQuery {
  username?: string;
  nickname?: string;
  email?: string;
  phoneNumber?: string;
}
