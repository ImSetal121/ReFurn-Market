import '../stores/auth_store.dart';
import '../services/stripe_service.dart';
import '../services/chat_websocket_service.dart';
import 'request.dart';

/// 初始化应用程序所需的所有服务
Future<void> initializeApp() async {
  // 初始化认证存储
  setupAuthStore();

  // 初始化认证状态
  await authStore.init();

  // 初始化HTTP请求服务
  HttpRequest.init();

  // 初始化Stripe支付服务
  await StripeService.init();

  // 初始化WebSocket聊天服务（不自动连接，等用户进入聊天页面时再连接）
  // ChatWebSocketService.instance 会在需要时自动创建实例
}
