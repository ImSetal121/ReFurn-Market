import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../models/sys_user.dart';

// 全局单例实例
final GetIt getIt = GetIt.instance;

// 初始化服务
void setupAuthStore() {
  getIt.registerLazySingleton<AuthStore>(() => AuthStore());
}

class AuthStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _accessToken;
  SysUser? _currentUser;
  DateTime? _userInfoCacheTime;

  // 缓存有效期（5分钟）
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // 获取当前的访问令牌
  String? get accessToken => _accessToken;

  // 获取当前用户信息
  SysUser? get currentUser => _currentUser;

  // 检查用户信息缓存是否有效
  bool get isUserInfoCacheValid {
    if (_currentUser == null || _userInfoCacheTime == null) return false;
    return DateTime.now().difference(_userInfoCacheTime!) < _cacheExpiration;
  }

  // 初始化，从安全存储中加载令牌
  Future<void> init() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  // 设置新的访问令牌
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await _storage.write(key: 'accessToken', value: token);
  }

  // 设置当前用户信息
  void setCurrentUser(SysUser user) {
    _currentUser = user;
    _userInfoCacheTime = DateTime.now();
  }

  // 清除用户信息缓存
  void clearUserCache() {
    _currentUser = null;
    _userInfoCacheTime = null;
  }

  // 重置认证状态（登出）
  Future<void> reset() async {
    _accessToken = null;
    _currentUser = null;
    _userInfoCacheTime = null;
    await _storage.delete(key: 'accessToken');
  }

  // 检查用户是否已认证
  bool get isAuthenticated => _accessToken != null;
}

// 便捷方法，获取AuthStore实例
AuthStore get authStore => getIt<AuthStore>();
