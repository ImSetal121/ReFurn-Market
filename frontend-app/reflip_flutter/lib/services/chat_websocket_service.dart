import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../models/chat_message.dart';
import '../stores/auth_store.dart';
import '../config/api_config.dart';

/// WebSocket聊天服务
class ChatWebSocketService {
  static ChatWebSocketService? _instance;
  static ChatWebSocketService get instance {
    _instance ??= ChatWebSocketService._internal();
    return _instance!;
  }

  ChatWebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _isManualDisconnect = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // 事件流控制器
  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // 公开的流
  Stream<WebSocketMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // 连接状态
  bool get isConnected => _channel != null;
  int? _currentUserId;

  /// 连接WebSocket
  Future<void> connect() async {
    // 严格检查登录状态
    if (!authStore.isAuthenticated) {
      print('WebSocket连接被阻止: 用户未登录');
      _errorController.add('请先登录后再进行聊天');
      _connectionController.add(false);
      return;
    }

    if (_isConnecting || isConnected) {
      print('WebSocket已连接或正在连接中');
      return;
    }

    final token = authStore.accessToken;
    if (token == null) {
      _errorController.add('用户未登录，无法建立聊天连接');
      return;
    }

    _isConnecting = true;
    _isManualDisconnect = false;

    try {
      // 构建WebSocket URL
      final wsUrl = _buildWebSocketUrl(token);
      print('正在连接WebSocket: $wsUrl');

      // 创建WebSocket连接
      _channel = IOWebSocketChannel.connect(
        wsUrl,
        protocols: ['chat'],
        headers: {'Authorization': 'Bearer $token'},
      );

      // 监听消息
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
        cancelOnError: false,
      );

      // 启动心跳
      _startHeartbeat();

      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionController.add(true);

      print('WebSocket连接成功');
    } catch (e) {
      _isConnecting = false;
      _connectionController.add(false);
      _errorController.add('连接失败: ${e.toString()}');
      print('WebSocket连接失败: $e');

      // 尝试重连
      _scheduleReconnect();
    }
  }

  /// 构建WebSocket URL
  String _buildWebSocketUrl(String token) {
    // 从API配置获取基础URL并转换为WebSocket URL
    final baseUrl = ApiConfig.baseUrl;
    String wsUrl;

    if (baseUrl.startsWith('https://')) {
      wsUrl = baseUrl.replaceFirst('https://', 'wss://');
    } else if (baseUrl.startsWith('http://')) {
      wsUrl = baseUrl.replaceFirst('http://', 'ws://');
    } else {
      wsUrl = 'ws://$baseUrl';
    }

    // 移除端口号并使用8081端口
    final uri = Uri.parse(wsUrl);
    final host = uri.host;

    return 'ws://$host:8081/chat/websocket?token=$token';
  }

  /// 断开连接
  void disconnect() {
    _isManualDisconnect = true;
    _stopHeartbeat();
    _stopReconnectTimer();
    _channel?.sink.close();
    _channel = null;
    _currentUserId = null;
    _connectionController.add(false);
    print('WebSocket连接已断开');
  }

  /// 发送消息
  Future<bool> sendMessage({
    required int receiverId,
    required String content,
    String messageType = 'text',
  }) async {
    // 检查登录状态
    if (!authStore.isAuthenticated) {
      _errorController.add('请先登录后再发送消息');
      return false;
    }

    if (!isConnected) {
      _errorController.add('未连接到聊天服务器');
      return false;
    }

    try {
      final message = WebSocketMessage.createChatMessage(
        receiverId: receiverId,
        content: content,
        messageType: messageType,
      );

      final jsonString = jsonEncode(message.toJson());
      _channel!.sink.add(jsonString);

      print('发送消息: $jsonString');
      return true;
    } catch (e) {
      _errorController.add('发送消息失败: ${e.toString()}');
      print('发送消息失败: $e');
      return false;
    }
  }

  /// 发送正在输入状态
  void sendTypingStatus({required int receiverId, required bool isTyping}) {
    if (!isConnected) return;

    try {
      final message = WebSocketMessage.createTypingMessage(
        receiverId: receiverId,
        isTyping: isTyping,
      );

      final jsonString = jsonEncode(message.toJson());
      _channel!.sink.add(jsonString);
    } catch (e) {
      print('发送正在输入状态失败: $e');
    }
  }

  /// 处理收到的消息
  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> json = jsonDecode(data.toString());
      final message = WebSocketMessage.fromJson(json);

      print('收到WebSocket消息: ${message.toString()}');

      // 处理连接成功消息
      if (message.type == 'connection' && message.userId != null) {
        _currentUserId = message.userId;
        print('连接成功，用户ID: $_currentUserId');
      }

      // 广播消息给监听者
      _messageController.add(message);
    } catch (e) {
      print('解析WebSocket消息失败: $e');
      _errorController.add('消息解析失败');
    }
  }

  /// 处理连接错误
  void _onError(error) {
    print('WebSocket错误: $error');
    _errorController.add('连接错误: ${error.toString()}');
    _connectionController.add(false);
  }

  /// 处理连接断开
  void _onDisconnected() {
    print('WebSocket连接断开');
    _channel = null;
    _stopHeartbeat();
    _connectionController.add(false);

    // 如果不是手动断开，尝试重连
    if (!_isManualDisconnect) {
      _scheduleReconnect();
    }
  }

  /// 启动心跳
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        try {
          final pingMessage = WebSocketMessage.createPingMessage();
          final jsonString = jsonEncode(pingMessage.toJson());
          _channel!.sink.add(jsonString);
          print('发送心跳');
        } catch (e) {
          print('发送心跳失败: $e');
        }
      }
    });
  }

  /// 停止心跳
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 安排重连
  void _scheduleReconnect() {
    if (_isManualDisconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _stopReconnectTimer();
    _reconnectAttempts++;

    print('将在${_reconnectDelay.inSeconds}秒后尝试第$_reconnectAttempts次重连');

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isManualDisconnect) {
        connect();
      }
    });
  }

  /// 停止重连定时器
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
    _errorController.close();
    _instance = null;
  }

  /// 获取当前用户ID
  int? get currentUserId => _currentUserId;

  /// 检查是否有聊天连接权限
  bool get canConnect {
    return authStore.isAuthenticated && authStore.accessToken != null;
  }

  /// 强制检查连接权限并断开无效连接
  void validateConnectionPermission() {
    if (!canConnect && isConnected) {
      print('检测到无效连接，强制断开');
      disconnect();
      _errorController.add('登录状态已失效，聊天连接已断开');
    }
  }
}
