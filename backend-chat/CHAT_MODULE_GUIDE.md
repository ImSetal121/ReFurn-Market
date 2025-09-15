# ReFlip 聊天模块使用指南

## 概述

ReFlip聊天模块已集成到主应用中，提供实时聊天功能。模块配置了独立的8081端口用于WebSocket连接，同时HTTP API通过主应用的8080端口提供服务。

## 快速开始

### 1. 启动应用
运行主应用的`BackendStartApplication`，聊天模块会自动启动并输出相关信息：

```
==============================================
    ReFlip 聊天模块已启动！
    主应用端口: 8080
    WebSocket服务端口: 8081
    WebSocket连接地址: ws://localhost:8081/chat/websocket
    聊天API地址: http://localhost:8080/api/chat
==============================================
```

### 2. 获取JWT Token
首先通过主应用登录获取Token：

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "your_username", "password": "your_password"}'
```

### 3. 建立WebSocket连接

```javascript
// 使用Token连接WebSocket
const token = "your_jwt_token_here";
const websocket = new WebSocket(`ws://localhost:8081/chat/websocket?token=${token}`);

websocket.onopen = function(event) {
    console.log("WebSocket连接成功");
};

websocket.onmessage = function(event) {
    const data = JSON.parse(event.data);
    console.log("收到消息:", data);
};
```

### 4. 发送消息

```javascript
// 发送聊天消息
const message = {
    type: "chat",
    receiverId: 123,
    content: "Hello, World!",
    messageType: "text"
};
websocket.send(JSON.stringify(message));

// 发送心跳
websocket.send(JSON.stringify({type: "ping"}));

// 发送正在输入状态
websocket.send(JSON.stringify({
    type: "typing",
    receiverId: 123,
    isTyping: true
}));
```

## 消息格式

### 发送消息类型

| 类型 | 说明 | 参数 |
|------|------|------|
| `chat` | 聊天消息 | `receiverId`, `content`, `messageType` |
| `ping` | 心跳检测 | 无 |
| `typing` | 正在输入 | `receiverId`, `isTyping` |

### 接收消息类型

| 类型 | 说明 | 包含字段 |
|------|------|----------|
| `connection` | 连接成功 | `status`, `message`, `userId` |
| `new_message` | 新消息 | `messageId`, `senderId`, `content`, `messageType`, `sendTime` |
| `message_sent` | 消息发送成功 | `messageId`, `status` |
| `pong` | 心跳响应 | `timestamp` |
| `typing` | 对方正在输入 | `senderId`, `isTyping` |
| `error` | 错误消息 | `message` |

## HTTP API接口

所有HTTP API都通过主应用的8080端口访问，需要在Header中携带JWT Token。

### 聊天记录
- `GET /api/chat/history/{otherUserId}` - 获取聊天记录
- `GET /api/chat/history/{otherUserId}/page?page=1&size=20` - 分页获取聊天记录

### 未读消息
- `GET /api/chat/unread` - 获取未读消息
- `GET /api/chat/unread/count` - 获取未读消息数量

### 消息操作
- `POST /api/chat/mark-read/{messageId}` - 标记消息已读
- `POST /api/chat/mark-read/batch` - 批量标记已读
- `POST /api/chat/mark-read/chat/{otherUserId}` - 标记与指定用户的所有消息已读

### 在线状态
- `GET /api/chat/online/{userId}` - 检查用户是否在线
- `GET /api/chat/online/users` - 获取所有在线用户
- `GET /api/chat/online/count` - 获取在线用户数量

## 架构说明

### 端口配置
- **主应用端口**: 8080 (HTTP API, Web界面)
- **WebSocket端口**: 8081 (WebSocket长连接)

### 核心组件
1. **ChatWebSocketConfig**: 配置WebSocket和8081端口
2. **WebSocketAuthInterceptor**: JWT认证拦截器
3. **ChatWebSocketHandler**: 消息处理器
4. **WebSocketSessionManager**: 会话管理器
5. **ChatMessagePushService**: 消息推送服务

### 消息流程
1. 客户端通过JWT Token建立WebSocket连接
2. 发送消息到WebSocket服务器
3. 服务器保存消息到数据库
4. 检查接收者是否在线
5. 如果在线，实时推送消息；如果离线，消息等待下次上线获取

## 测试建议

### 功能测试
1. 测试JWT认证是否正常
2. 测试消息发送和接收
3. 测试在线状态管理
4. 测试心跳机制
5. 测试错误处理

### 性能测试
1. 并发连接数测试
2. 消息吞吐量测试
3. 内存使用情况监控

## 注意事项

1. **认证**: 所有WebSocket连接都需要有效的JWT Token
2. **跨域**: 默认允许所有域名，生产环境需要配置
3. **连接管理**: 系统会自动清理无效连接
4. **消息大小**: 默认限制为8KB
5. **数据库**: 消息会持久化存储，注意定期清理

## 扩展功能

可以基于现有架构扩展以下功能：
- 群聊功能
- 文件传输
- 消息加密
- 消息撤回
- 聊天室功能
- 消息转发 