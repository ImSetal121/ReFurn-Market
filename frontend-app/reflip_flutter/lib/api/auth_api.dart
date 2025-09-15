import '../models/login_user.dart';
import '../models/sys_menu.dart';
import '../models/sys_user.dart';
import '../models/sys_role.dart';
import '../utils/request.dart';

/// 认证相关API
class AuthApi {
  /// 登录
  static Future<LoginUser?> login(String username, String password) async {
    final data = await HttpRequest.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': username, 'password': password},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (data != null) {
      // 直接创建LoginUser对象，不做额外处理
      return LoginUser.fromJson(data);
    }

    return null;
  }

  /// Google移动端登录
  static Future<LoginUser?> googleMobileLogin(
    String idToken, {
    String clientType = 'ios',
  }) async {
    final data = await HttpRequest.post<Map<String, dynamic>>(
      '/auth/google/mobile-login',
      data: {'idToken': idToken, 'clientType': clientType},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (data != null) {
      return LoginUser.fromJson(data);
    }

    return null;
  }

  /// 登出
  static Future<bool> logout() async {
    await HttpRequest.post<void>('/auth/logout');
    return true;
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final data = await HttpRequest.get<Map<String, dynamic>>(
      '/auth/info',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (data != null) {
      final result = <String, dynamic>{};

      if (data['user'] != null) {
        result['user'] = SysUser.fromJson(data['user'] as Map<String, dynamic>);
      }

      if (data['role'] != null) {
        result['role'] = SysRole.fromJson(data['role'] as Map<String, dynamic>);
      }

      return result;
    }

    return null;
  }

  /// 获取用户菜单
  static Future<List<SysMenu>?> getMenus() async {
    final data = await HttpRequest.get<List<dynamic>>(
      '/auth/menus',
      fromJson: (json) => json as List<dynamic>,
    );

    return data
        ?.map((item) => SysMenu.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 注册
  static Future<SysUser?> register(
    String username,
    String password,
    String nickname,
  ) async {
    final data = await HttpRequest.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'username': username, 'password': password, 'nickname': nickname},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return data != null ? SysUser.fromJson(data) : null;
  }
}
