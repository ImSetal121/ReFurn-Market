// src/api/auth.ts
// 为了保持向后兼容，重新导出AuthController中的方法
export {
  login,
  logout,
  getUserInfo,
  getMenus,
  register,
  AuthController
} from './AuthController';
