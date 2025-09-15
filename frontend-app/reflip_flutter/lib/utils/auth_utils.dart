import 'package:flutter/material.dart';
import '../stores/auth_store.dart';
import '../pages/auth_portal_page.dart';

/// 认证工具类
/// 提供按需登录的功能
class AuthUtils {
  /// 检查用户是否已登录，如果未登录则显示登录门户页面
  /// 返回 true 表示用户已登录或登录成功，false 表示用户取消登录
  static Future<bool> requireLogin(
    BuildContext context, {
    String? message,
  }) async {
    print(
      'AuthUtils.requireLogin called, current auth status: ${authStore.isAuthenticated}',
    );

    // 如果用户已登录，直接返回 true
    if (authStore.isAuthenticated) {
      print('User already authenticated, returning true');
      return true;
    }

    print('User not authenticated, showing auth portal');

    // 检查Navigator是否可用
    if (!Navigator.of(context).mounted) {
      print('Navigator not mounted, returning false');
      return false;
    }

    try {
      // 显示登录门户页面
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => const AuthPortalPage(),
          fullscreenDialog: true,
        ),
      );

      print(
        'Auth portal returned with result: $result, current auth status: ${authStore.isAuthenticated}',
      );

      // 检查登录状态是否发生变化
      // 无论result是什么，都以实际的登录状态为准
      return authStore.isAuthenticated;
    } catch (e) {
      print('Error during navigation to auth portal: $e');
      return authStore.isAuthenticated;
    }
  }

  /// 显示需要登录的对话框
  static void showLoginRequiredDialog(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onLoginPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Login Required'),
          content: Text(
            message ??
                'This feature requires login. Would you like to login now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onLoginPressed != null) {
                  onLoginPressed();
                } else {
                  requireLogin(context);
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  /// 检查是否已登录，如果未登录则显示提示
  static bool checkLoginWithPrompt(
    BuildContext context, {
    String? title,
    String? message,
  }) {
    if (authStore.isAuthenticated) {
      return true;
    }

    showLoginRequiredDialog(context, title: title, message: message);
    return false;
  }
}
