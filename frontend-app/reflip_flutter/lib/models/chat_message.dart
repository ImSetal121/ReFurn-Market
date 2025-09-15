/// 聊天消息模型
class ChatMessage {
  final int? id;
  final int? senderId;
  final int? receiverId;
  final String? content;
  final String? messageType;
  final bool? isRead;
  final String? createTime;
  final String? updateTime;
  final bool? isDelete;
  final String? sendTime;
  final String? status;

  ChatMessage({
    this.id,
    this.senderId,
    this.receiverId,
    this.content,
    this.messageType,
    this.isRead,
    this.createTime,
    this.updateTime,
    this.isDelete,
    this.sendTime,
    this.status,
  });

  /// 从JSON创建ChatMessage实例
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      // 后端字段名映射
      senderId: json['senderUserId'] as int?,
      receiverId: json['receiverUserId'] as int?,
      content: json['messageContent'] as String?,
      messageType: json['messageType'] as String?,
      isRead: json['isRead'] as bool?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      isDelete: json['isDelete'] as bool?,
      sendTime: json['sendTime'] as String?,
      status: json['status'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUserId': senderId,
      'receiverUserId': receiverId,
      'messageContent': content,
      'messageType': messageType,
      'isRead': isRead,
      'createTime': createTime,
      'updateTime': updateTime,
      'isDelete': isDelete,
      'sendTime': sendTime,
      'status': status,
    };
  }

  /// 创建副本
  ChatMessage copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? content,
    String? messageType,
    bool? isRead,
    String? createTime,
    String? updateTime,
    bool? isDelete,
    String? sendTime,
    String? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      isDelete: isDelete ?? this.isDelete,
      sendTime: sendTime ?? this.sendTime,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ChatMessage{id: $id, senderId: $senderId, receiverId: $receiverId, content: $content, messageType: $messageType, isRead: $isRead, createTime: $createTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// WebSocket消息模型
class WebSocketMessage {
  final String type;
  final int? receiverId;
  final String? content;
  final String? messageType;
  final bool? isTyping;
  final int? messageId;
  final int? senderId;
  final String? sendTime;
  final String? status;
  final String? message;
  final int? userId;
  final int? timestamp;

  WebSocketMessage({
    required this.type,
    this.receiverId,
    this.content,
    this.messageType,
    this.isTyping,
    this.messageId,
    this.senderId,
    this.sendTime,
    this.status,
    this.message,
    this.userId,
    this.timestamp,
  });

  /// 从JSON创建WebSocketMessage实例
  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      receiverId: _parseIntFromDynamic(json['receiverId']),
      content: json['content'] as String?,
      messageType: json['messageType'] as String?,
      isTyping: json['isTyping'] as bool?,
      messageId: _parseIntFromDynamic(json['messageId']),
      senderId: _parseIntFromDynamic(json['senderId']),
      sendTime: json['sendTime'] as String?,
      status: json['status'] as String?,
      message: json['message'] as String?,
      userId: _parseIntFromDynamic(json['userId']),
      timestamp: _parseIntFromDynamic(json['timestamp']),
    );
  }

  /// 安全地从动态类型解析int
  static int? _parseIntFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'type': type};

    if (receiverId != null) data['receiverId'] = receiverId;
    if (content != null) data['content'] = content;
    if (messageType != null) data['messageType'] = messageType;
    if (isTyping != null) data['isTyping'] = isTyping;
    if (messageId != null) data['messageId'] = messageId;
    if (senderId != null) data['senderId'] = senderId;
    if (sendTime != null) data['sendTime'] = sendTime;
    if (status != null) data['status'] = status;
    if (message != null) data['message'] = message;
    if (userId != null) data['userId'] = userId;
    if (timestamp != null) data['timestamp'] = timestamp;

    return data;
  }

  /// 创建聊天消息
  static WebSocketMessage createChatMessage({
    required int receiverId,
    required String content,
    String messageType = 'text',
  }) {
    return WebSocketMessage(
      type: 'chat',
      receiverId: receiverId,
      content: content,
      messageType: messageType,
    );
  }

  /// 创建心跳消息
  static WebSocketMessage createPingMessage() {
    return WebSocketMessage(type: 'ping');
  }

  /// 创建正在输入消息
  static WebSocketMessage createTypingMessage({
    required int receiverId,
    required bool isTyping,
  }) {
    return WebSocketMessage(
      type: 'typing',
      receiverId: receiverId,
      isTyping: isTyping,
    );
  }

  @override
  String toString() {
    return 'WebSocketMessage{type: $type, receiverId: $receiverId, content: $content, messageType: $messageType}';
  }
}
