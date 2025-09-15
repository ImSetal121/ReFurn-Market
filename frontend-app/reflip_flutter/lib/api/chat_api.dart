import '../utils/request.dart';
import '../models/chat_message.dart';

/// 聊天列表项模型
class ChatListItem {
  final int userId;
  final String userName;
  final String? userAvatar;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatListItem({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    return ChatListItem(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userName: json['userName'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] as String? ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
    };
  }
}

/// 聊天API接口
class ChatApi {
  static const String _baseUrl = '/api/chat';

  /// 获取聊天记录
  ///
  /// [otherUserId] 对方用户ID
  /// 返回聊天消息列表
  static Future<List<ChatMessage>?> getChatHistory(int otherUserId) async {
    return await HttpRequest.get<List<ChatMessage>>(
      '$_baseUrl/history/$otherUserId',
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ChatMessage.fromJson(item)).toList();
        }
        return null;
      },
    );
  }

  /// 分页获取聊天记录
  ///
  /// [otherUserId] 对方用户ID
  /// [page] 页码，从1开始
  /// [size] 每页大小，默认20
  /// 返回聊天消息列表
  static Future<List<ChatMessage>?> getChatHistoryPage(
    int otherUserId, {
    int page = 1,
    int size = 20,
  }) async {
    return await HttpRequest.get<List<ChatMessage>>(
      '$_baseUrl/history/$otherUserId/page',
      queryParameters: {'page': page, 'size': size},
      fromJson: (data) {
        // 处理分页数据结构
        if (data is Map<String, dynamic>) {
          final records = data['records'];
          if (records is List) {
            return records.map((item) => ChatMessage.fromJson(item)).toList();
          }
        }
        return null;
      },
    );
  }

  /// 获取未读消息
  ///
  /// 返回未读消息列表
  static Future<List<ChatMessage>?> getUnreadMessages() async {
    return await HttpRequest.get<List<ChatMessage>>(
      '$_baseUrl/unread',
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ChatMessage.fromJson(item)).toList();
        }
        return null;
      },
    );
  }

  /// 获取未读消息数量
  ///
  /// 返回未读消息数量
  static Future<int?> getUnreadMessageCount() async {
    return await HttpRequest.get<int>(
      '$_baseUrl/unread/count',
      fromJson: (data) => data as int?,
    );
  }

  /// 标记消息已读
  ///
  /// [messageId] 消息ID
  /// 返回是否成功
  static Future<bool> markMessageAsRead(int messageId) async {
    final result = await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/mark-read/$messageId',
      fromJson: (data) => data as Map<String, dynamic>?,
    );
    return result != null;
  }

  /// 批量标记消息已读
  ///
  /// [messageIds] 消息ID列表
  /// 返回是否成功
  static Future<bool> markMessagesAsRead(List<int> messageIds) async {
    final result = await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/mark-read/batch',
      data: {'messageIds': messageIds},
      fromJson: (data) => data as Map<String, dynamic>?,
    );
    return result != null;
  }

  /// 标记与指定用户的所有消息已读
  ///
  /// [otherUserId] 对方用户ID
  /// 返回是否成功
  static Future<bool> markChatAsRead(int otherUserId) async {
    final result = await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/mark-read/chat/$otherUserId',
      fromJson: (data) => data as Map<String, dynamic>?,
    );
    return result != null;
  }

  /// 检查用户是否在线
  ///
  /// [userId] 用户ID
  /// 返回是否在线
  static Future<bool> isUserOnline(int userId) async {
    final result = await HttpRequest.get<bool>(
      '$_baseUrl/online/$userId',
      fromJson: (data) => data as bool?,
    );
    return result ?? false;
  }

  /// 获取所有在线用户
  ///
  /// 返回在线用户ID列表
  static Future<List<int>?> getOnlineUsers() async {
    return await HttpRequest.get<List<int>>(
      '$_baseUrl/online/users',
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as int).toList();
        }
        return null;
      },
    );
  }

  /// 获取在线用户数量
  ///
  /// 返回在线用户数量
  static Future<int?> getOnlineUserCount() async {
    return await HttpRequest.get<int>(
      '$_baseUrl/online/count',
      fromJson: (data) => data as int?,
    );
  }

  /// 获取聊天列表
  ///
  /// 返回所有有过聊天记录的用户列表
  static Future<List<ChatListItem>?> getChatList() async {
    return await HttpRequest.get<List<ChatListItem>>(
      '$_baseUrl/list',
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ChatListItem.fromJson(item)).toList();
        }
        return null;
      },
    );
  }
}
