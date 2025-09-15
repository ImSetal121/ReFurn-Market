import 'package:flutter/material.dart';
import 'dart:async';
import '../models/chat_message.dart';
import '../models/sys_user.dart';
import '../services/chat_websocket_service.dart';
import '../api/chat_api.dart';
import '../api/auth_api.dart';
import '../stores/auth_store.dart';

class ChatConversationPage extends StatefulWidget {
  final int? userId;
  final String userName;
  final String? userAvatar;
  final int? productId;
  final Map<String, dynamic>? productInfo;

  const ChatConversationPage({
    Key? key,
    this.userId,
    required this.userName,
    this.userAvatar,
    this.productId,
    this.productInfo,
  }) : super(key: key);

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ChatWebSocketService _chatService = ChatWebSocketService.instance;

  // 聊天相关状态
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  int? _otherUserId;
  bool _isInitialized = false;

  // 当前用户信息
  int? _currentUserId;
  String? _currentUserAvatar;
  bool _isLoadingUserInfo = true;

  // 流订阅
  StreamSubscription<WebSocketMessage>? _messageSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    // 只设置基本状态，不调用需要context的方法
    _otherUserId = widget.userId ?? widget.productInfo?['userId'] as int?;

    // 监听焦点变化以更新UI
    _messageFocusNode.addListener(() {
      if (mounted) {
        setState(() {}); // 更新键盘收起按钮的显示状态
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里进行需要context的初始化
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeChat();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }

  /// 初始化聊天
  void _initializeChat() async {
    // 检查是否有有效的用户ID
    if (_otherUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('无法获取聊天对象信息'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      });
      return;
    }

    // 获取当前用户信息
    await _loadCurrentUserInfo();

    // 验证用户ID不能相同
    if (_currentUserId != null && _currentUserId == _otherUserId) {
      print('错误：检测到当前用户ID与对方用户ID相同: $_currentUserId');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('错误：无法与自己聊天'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      });
      return;
    }

    print('聊天初始化 - 当前用户: $_currentUserId, 对方用户: $_otherUserId');

    // 标记消息为已读
    _markMessagesAsRead();

    // 初始化WebSocket连接
    _initializeWebSocket();

    // 加载聊天历史
    _loadChatHistory();
  }

  /// 获取当前用户信息
  Future<void> _loadCurrentUserInfo() async {
    try {
      // 首先检查缓存
      if (authStore.isUserInfoCacheValid && authStore.currentUser != null) {
        final cachedUser = authStore.currentUser!;
        if (mounted) {
          setState(() {
            _currentUserId = cachedUser.id;
            _currentUserAvatar = cachedUser.avatar;
            _isLoadingUserInfo = false;
          });
          print('使用缓存的用户信息 - ID: $_currentUserId, 头像: $_currentUserAvatar');
          return;
        }
      }

      // 缓存无效或不存在，从API获取
      final userInfo = await AuthApi.getUserInfo();
      if (userInfo != null && userInfo['user'] != null && mounted) {
        final user = userInfo['user'] as SysUser;

        // 更新AuthStore缓存
        authStore.setCurrentUser(user);

        setState(() {
          _currentUserId = user.id;
          _currentUserAvatar = user.avatar;
          _isLoadingUserInfo = false;
        });
        print('从API获取用户信息 - ID: $_currentUserId, 头像: $_currentUserAvatar');
      }
    } catch (e) {
      print('获取当前用户信息失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingUserInfo = false;
        });
      }
    }
  }

  /// 标记与该用户的所有消息为已读
  Future<void> _markMessagesAsRead() async {
    if (_otherUserId == null) return;

    try {
      final success = await ChatApi.markChatAsRead(_otherUserId!);
      if (success) {
        print('已标记与用户 $_otherUserId 的消息为已读');
      } else {
        print('标记消息已读失败');
      }
    } catch (e) {
      print('标记消息已读异常: $e');
    }
  }

  /// 初始化WebSocket连接
  void _initializeWebSocket() {
    // 监听连接状态
    _connectionSubscription = _chatService.connectionStream.listen((
      isConnected,
    ) {
      if (mounted) {
        if (isConnected) {
          print('聊天连接已建立');
        } else {
          print('聊天连接已断开');
        }
      }
    });

    // 监听消息
    _messageSubscription = _chatService.messageStream.listen((wsMessage) {
      if (mounted) {
        _handleWebSocketMessage(wsMessage);
      }
    });

    // 监听错误
    _errorSubscription = _chatService.errorStream.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    });

    // 连接WebSocket
    _chatService.connect();
  }

  /// 处理WebSocket消息
  void _handleWebSocketMessage(WebSocketMessage wsMessage) {
    switch (wsMessage.type) {
      case 'new_message':
        // 收到新消息
        if (wsMessage.senderId != null &&
            wsMessage.content != null &&
            wsMessage.senderId == _otherUserId) {
          _addNewMessage(
            senderId: wsMessage.senderId!,
            content: wsMessage.content!,
            messageType: wsMessage.messageType ?? 'text',
            sendTime: wsMessage.sendTime,
          );
        }
        break;
      case 'message_sent':
        // 消息发送成功确认
        print('消息发送成功: ${wsMessage.messageId}');
        break;
      case 'typing':
        // 对方正在输入
        if (wsMessage.senderId == _otherUserId) {
          setState(() {
            _isTyping = wsMessage.isTyping ?? false;
          });
        }
        break;
      case 'pong':
        // 心跳响应
        print('收到心跳响应');
        break;
      case 'error':
        // 错误消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(wsMessage.message ?? '发生未知错误'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
    }
  }

  /// 添加新消息到列表
  void _addNewMessage({
    required int senderId,
    required String content,
    required String messageType,
    String? sendTime,
  }) {
    // 确保发送者和接收者不相同
    if (senderId == _otherUserId && _otherUserId == _currentUserId) {
      print(
        '错误：检测到发送者和接收者相同，senderId: $senderId, _currentUserId: $_currentUserId, _otherUserId: $_otherUserId',
      );
      return;
    }

    // 正确计算接收者ID
    int? receiverId;
    if (senderId == _currentUserId) {
      // 我发送的消息，接收者是对方
      receiverId = _otherUserId;
    } else if (senderId == _otherUserId) {
      // 对方发送的消息，接收者是我
      receiverId = _currentUserId;
    } else {
      print(
        '错误：无效的发送者ID，senderId: $senderId, _currentUserId: $_currentUserId, _otherUserId: $_otherUserId',
      );
      return;
    }

    if (receiverId == null) {
      print('错误：无法确定接收者ID');
      return;
    }

    print('添加消息 - 发送者: $senderId, 接收者: $receiverId, 内容: $content');

    final newMessage = ChatMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      messageType: messageType,
      isRead: false,
      createTime: sendTime ?? DateTime.now().toIso8601String(),
      sendTime: sendTime ?? DateTime.now().toIso8601String(),
    );

    setState(() {
      _messages.add(newMessage);
    });

    // 滚动到底部（延迟执行确保UI已更新）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// 加载聊天历史
  Future<void> _loadChatHistory() async {
    if (_otherUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final history = await ChatApi.getChatHistoryPage(
        _otherUserId!,
        page: 1,
        size: 50,
      );
      if (history != null && mounted) {
        // 将对方发送给我的消息标记为已读
        final updatedHistory = history.map((message) {
          if (message.senderId == _otherUserId &&
              message.receiverId == _currentUserId) {
            return message.copyWith(isRead: true);
          }
          return message;
        }).toList();

        setState(() {
          _messages = updatedHistory.reversed.toList(); // 反转以显示最新消息在底部
        });

        // 滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('加载聊天历史失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;

    // 获取当前滚动位置
    final position = _scrollController.position;

    // 如果内容高度不足以滚动，直接返回
    if (position.maxScrollExtent <= 0) return;

    // 平滑滚动到底部
    _scrollController
        .animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .catchError((error) {
          // 如果动画滚动失败，尝试立即跳转
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
  }

  /// 强制滚动到底部（用于消息发送后）
  void _forceScrollToBottom() {
    // 使用多重延迟确保UI完全更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();

      // 如果第一次滚动没有到达底部，再次尝试
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollToBottom();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部状态栏占位
            Container(width: 393, height: 12),

            // 聊天头部
            _buildChatHeader(),

            // 聊天消息列表
            Expanded(child: _buildMessageList()),

            // 底部输入区域
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      width: 369,
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 24,
              height: 24,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: const Color(0xFF1A1C1E),
              ),
            ),
          ),
          // 用户名 - 居中显示
          Expanded(
            child: Center(
              child: Text(
                widget.userName,
                style: const TextStyle(
                  color: Color(0xFF1A1C1E),
                  fontSize: 20,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
          // 右侧占位，保持布局平衡
          Container(width: 24, height: 24),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Container(
      height: 759,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                // 点击聊天区域收起键盘
                if (_messageFocusNode.hasFocus) {
                  _messageFocusNode.unfocus();
                }
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // 聊天消息列表
                    ..._buildMessageWidgets(),

                    // 正在输入指示器
                    if (_isTyping) ...[
                      const SizedBox(height: 16),
                      _buildTypingIndicator(),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  /// 构建消息组件列表
  List<Widget> _buildMessageWidgets() {
    List<Widget> widgets = [];

    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      final isMyMessage = message.senderId == _currentUserId;

      // 添加时间戳（每5分钟显示一次）
      if (i == 0 || _shouldShowTimestamp(_messages[i - 1], message)) {
        widgets.add(
          _buildTimestamp(message.sendTime ?? message.createTime ?? ''),
        );
        widgets.add(const SizedBox(height: 16));
      }

      // 添加消息气泡
      widgets.add(
        isMyMessage
            ? _buildMyMessage(message.content ?? '')
            : _buildOtherMessage(message.content ?? ''),
      );

      if (i < _messages.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  /// 判断是否应该显示时间戳
  bool _shouldShowTimestamp(
    ChatMessage prevMessage,
    ChatMessage currentMessage,
  ) {
    try {
      final prevTimeStr = prevMessage.sendTime ?? prevMessage.createTime ?? '';
      final currentTimeStr =
          currentMessage.sendTime ?? currentMessage.createTime ?? '';
      final prevTime = DateTime.parse(prevTimeStr);
      final currentTime = DateTime.parse(currentTimeStr);
      return currentTime.difference(prevTime).inMinutes >= 5;
    } catch (e) {
      return false;
    }
  }

  /// 构建时间戳
  Widget _buildTimestamp(String timeString) {
    String displayTime = '现在';
    try {
      final time = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inDays > 0) {
        displayTime = '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        displayTime = '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        displayTime = '${difference.inMinutes}分钟前';
      } else {
        displayTime = '刚刚';
      }
    } catch (e) {
      displayTime = timeString;
    }

    return Center(
      child: Opacity(
        opacity: 0.40,
        child: Text(
          displayTime,
          style: const TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 13,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.39,
          ),
        ),
      ),
    );
  }

  /// 构建正在输入指示器
  Widget _buildTypingIndicator() {
    return Container(
      width: 369,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 对方头像
          Container(
            width: 40,
            height: 40,
            decoration: const ShapeDecoration(
              color: Color(0xFF999999),
              shape: OvalBorder(),
            ),
            child: widget.userAvatar != null && widget.userAvatar!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      widget.userAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.white);
                      },
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 6),

          // 正在输入气泡
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '正在输入',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 15,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 4),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMessage(String message) {
    return Container(
      width: 369,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          Container(
            width: 40,
            height: 40,
            decoration: const ShapeDecoration(
              color: Color(0xFF989898),
              shape: OvalBorder(),
            ),
            child: widget.userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      widget.userAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.white);
                      },
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 6),

          // 消息气泡
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF1A1C1E),
                fontSize: 15,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMessage(String message) {
    return Container(
      width: 369,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 消息气泡
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: ShapeDecoration(
              color: const Color(0xFF007AFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.45,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 我的头像
          Container(
            width: 40,
            height: 40,
            decoration: const ShapeDecoration(
              color: Color(0xFF007AFF),
              shape: OvalBorder(),
            ),
            child: _buildCurrentUserAvatar(),
          ),
        ],
      ),
    );
  }

  /// 构建当前用户头像
  Widget _buildCurrentUserAvatar() {
    // 如果还在加载用户信息，显示加载指示器
    if (_isLoadingUserInfo) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // 如果有头像URL，显示网络图片
    if (_currentUserAvatar != null && _currentUserAvatar!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _currentUserAvatar!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('头像加载失败: $error');
            return const Icon(Icons.person, color: Colors.white);
          },
        ),
      );
    }

    // 默认头像
    return const Icon(Icons.person, color: Colors.white);
  }

  Widget _buildInputArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 输入框区域
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 输入框
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          textInputAction: TextInputAction.send,
                          maxLines: 1,
                          onChanged: (text) {
                            // 发送正在输入状态
                            if (text.isNotEmpty) {
                              _startTyping();
                            }
                            // 强制重建以更新发送按钮状态
                            setState(() {});

                            // 如果用户正在输入且内容不为空，确保视图保持在底部
                            if (text.isNotEmpty) {
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  if (mounted) {
                                    _scrollToBottom();
                                  }
                                },
                              );
                            }
                          },
                          onSubmitted: (text) {
                            // iOS键盘发送按钮触发
                            print('onSubmitted 被触发，文本内容: "$text"');
                            if (text.trim().isNotEmpty) {
                              _sendMessage();
                              // 发送后收起键盘
                              _messageFocusNode.unfocus();
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: '输入消息...',
                            hintStyle: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 16, top: -14),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A1C1E),
                          ),
                        ),
                      ),

                      // 键盘收起按钮（仅在有焦点时显示）
                      if (_messageFocusNode.hasFocus)
                        GestureDetector(
                          onTap: () {
                            _messageFocusNode.unfocus();
                            setState(() {}); // 更新UI隐藏按钮
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.keyboard_hide,
                              color: Color(0xFF666666),
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 发送按钮
              GestureDetector(
                onTap: _messageController.text.trim().isNotEmpty
                    ? () {
                        _sendMessage();
                        // 点击发送按钮后收起键盘
                        _messageFocusNode.unfocus();
                      }
                    : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _messageController.text.trim().isNotEmpty
                        ? const Color(0xFF007AFF)
                        : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: _messageController.text.trim().isNotEmpty
                        ? Colors.white
                        : const Color(0xFF999999),
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 加号按钮
              GestureDetector(
                onTap: _showMoreOptions,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF666666),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _otherUserId == null || _currentUserId == null) {
      print(
        '发送消息被跳过 - 内容为空或用户ID无效: content="$content", otherUserId=$_otherUserId, currentUserId=$_currentUserId',
      );
      return;
    }

    // 验证不能给自己发消息
    if (_currentUserId == _otherUserId) {
      print(
        '错误：尝试给自己发送消息，currentUserId: $_currentUserId, otherUserId: $_otherUserId',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('错误：无法给自己发送消息'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 停止正在输入状态
    _stopTyping();

    print('发送消息 - 从: $_currentUserId 到: $_otherUserId, 内容: $content');

    try {
      // 通过WebSocket发送消息
      final success = await _chatService.sendMessage(
        receiverId: _otherUserId!,
        content: content,
        messageType: 'text',
      );

      if (success) {
        // 立即添加到本地消息列表（发送方视角）
        _addNewMessage(
          senderId: _currentUserId!,
          content: content,
          messageType: 'text',
        );

        // 清空输入框并更新UI状态
        _messageController.clear();

        // 强制滚动到底部
        _forceScrollToBottom();

        // 延迟更新UI状态，确保所有操作完成
        if (mounted) {
          setState(() {}); // 更新发送按钮状态和键盘收起按钮状态
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('消息发送失败，请检查网络连接'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('发送消息异常: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 开始输入状态
  void _startTyping() {
    if (_otherUserId == null || !_chatService.isConnected) return;

    _chatService.sendTypingStatus(receiverId: _otherUserId!, isTyping: true);

    // 设置定时器，3秒后自动停止输入状态
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _stopTyping();
    });
  }

  /// 停止输入状态
  void _stopTyping() {
    if (_otherUserId == null || !_chatService.isConnected) return;

    _chatService.sendTypingStatus(receiverId: _otherUserId!, isTyping: false);

    _typingTimer?.cancel();
  }

  void _showMoreOptions() {
    // 显示暂未开放提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              '该功能暂未开放，敬请期待',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF666666),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
