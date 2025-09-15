import 'package:flutter/material.dart';
import '../stores/auth_store.dart';
import '../pages/auth_portal_page.dart';

/// 路由守卫类
/// 用于保护需要认证的路由
class RouteGuard {
  /// 检查用户是否已认证
  /// 如果未认证，则重定向到认证门户页面
  static Route<dynamic> guardRoute(
    Widget Function(BuildContext) builder,
    RouteSettings settings,
  ) {
    // 检查认证状态
    final isAuthenticated = authStore.isAuthenticated;
    final token = authStore.accessToken;

    print(
      '路由守卫检查: 路由=${settings.name}, 认证状态=$isAuthenticated, Token=${token != null ? "存在" : "不存在"}',
    );

    if (isAuthenticated) {
      // 用户已认证，允许访问请求的路由
      print('用户已认证，允许访问: ${settings.name}');
      return MaterialPageRoute(builder: builder, settings: settings);
    } else {
      // 用户未认证，重定向到认证门户页面
      // 保存原始请求的路由，以便登录成功后可以重定向回来
      final redirectRoute = settings.name;
      print('用户未认证，重定向到认证门户页面。原始路由: $redirectRoute');

      // 强制清除认证状态
      authStore.reset();

      // 重定向到认证门户页面
      return MaterialPageRoute(
        builder: (context) =>
            AuthPortalPageWithRedirect(redirectRoute: redirectRoute),
        settings: const RouteSettings(name: '/auth-portal'),
      );
    }
  }
}

/// 包装AuthPortalPage以支持登录成功后的重定向
class AuthPortalPageWithRedirect extends StatefulWidget {
  final String? redirectRoute;

  const AuthPortalPageWithRedirect({Key? key, this.redirectRoute})
    : super(key: key);

  @override
  State<AuthPortalPageWithRedirect> createState() =>
      _AuthPortalPageWithRedirectState();
}

class _AuthPortalPageWithRedirectState
    extends State<AuthPortalPageWithRedirect> {
  @override
  void initState() {
    super.initState();
    // 监听认证状态变化
    _checkAuthenticationPeriodically();
  }

  void _checkAuthenticationPeriodically() {
    // 每隔一段时间检查认证状态
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return false;

      if (authStore.isAuthenticated) {
        print('检测到用户已登录，准备重定向到: ${widget.redirectRoute}');

        // 保存 context 引用，避免异步使用问题
        final navigator = Navigator.of(context);
        final redirectRoute = widget.redirectRoute;

        // 用户已登录，执行重定向
        if (redirectRoute != null && redirectRoute != '/auth-portal') {
          // 先清除路由栈并导航到首页，然后导航到目标页面
          navigator.pushNamedAndRemoveUntil('/home', (route) => false);
          // 等待一个微任务后导航到目标页面，确保首页已经建立
          Future.microtask(() {
            if (mounted) {
              navigator.pushNamed(redirectRoute);
            }
          });
        } else {
          // 如果没有重定向路由，清除路由栈并返回首页
          navigator.pushNamedAndRemoveUntil('/home', (route) => false);
        }
        return false;
      }

      return true; // 继续监听
    });
  }

  @override
  Widget build(BuildContext context) {
    return const AuthPortalPage();
  }
}
