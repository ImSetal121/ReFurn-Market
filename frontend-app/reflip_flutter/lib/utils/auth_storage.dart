import '../stores/auth_store.dart';

class AuthStorage {
  /// 获取当前的访问token
  static Future<String?> getToken() async {
    return authStore.accessToken;
  }

  /// 保存token
  static Future<void> saveToken(String token) async {
    // 这里应该调用AuthStore的方法来保存token
    // 但由于AuthStore的实现可能不同，这里只是一个示例
    // 实际使用时需要根据AuthStore的具体实现来调整
  }

  /// 清除token
  static Future<void> clearToken() async {
    authStore.reset();
  }

  /// 检查是否已登录
  static bool isLoggedIn() {
    return authStore.isAuthenticated;
  }
}
