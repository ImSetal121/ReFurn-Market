import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'stores/auth_store.dart';
import 'utils/app_init.dart';
import 'routes/app_routes.dart';

void main() async {
  // 确保Flutter框架初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  // 设置应用程序方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化应用程序服务
  await initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 检查用户是否已登录
    final isLoggedIn = authStore.isAuthenticated;

    return MaterialApp(
      title: 'ReFlip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // 使用AppRoutes类管理路由
      initialRoute: AppRoutes.initialRoute(isLoggedIn),
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
