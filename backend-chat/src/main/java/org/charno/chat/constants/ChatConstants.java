package org.charno.chat.constants;

/**
 * 聊天模块常量类
 * 定义聊天相关的常量配置
 */
public class ChatConstants {

    /**
     * WebSocket相关常量
     */
    public static class WebSocket {
        /** WebSocket端口 */
        public static final int PORT = 8081;
        
        /** WebSocket路径 */
        public static final String ENDPOINT = "/chat/websocket";
        
        /** 心跳间隔（秒） */
        public static final int HEARTBEAT_INTERVAL = 30;
        
        /** 连接超时时间（秒） */
        public static final int CONNECTION_TIMEOUT = 60;
        
        /** 最大文本消息大小（字节） */
        public static final int MAX_TEXT_MESSAGE_SIZE = 8192;
        
        /** 最大二进制消息大小（字节） */
        public static final int MAX_BINARY_MESSAGE_SIZE = 8192;
    }

    /**
     * 消息类型常量
     */
    public static class MessageType {
        /** 聊天消息 */
        public static final String CHAT = "chat";
        
        /** 心跳消息 */
        public static final String PING = "ping";
        public static final String PONG = "pong";
        
        /** 正在输入 */
        public static final String TYPING = "typing";
        
        /** 连接状态 */
        public static final String CONNECTION = "connection";
        
        /** 新消息 */
        public static final String NEW_MESSAGE = "new_message";
        
        /** 消息已发送 */
        public static final String MESSAGE_SENT = "message_sent";
        
        /** 系统消息 */
        public static final String SYSTEM_MESSAGE = "system_message";
        
        /** 通知消息 */
        public static final String NOTIFICATION = "notification";
        
        /** 广播消息 */
        public static final String BROADCAST = "broadcast";
        
        /** 用户状态 */
        public static final String USER_STATUS = "user_status";
        
        /** 错误消息 */
        public static final String ERROR = "error";
    }

    /**
     * 消息状态常量
     */
    public static class MessageStatus {
        /** 已发送 */
        public static final String SENT = "sent";
        
        /** 已送达 */
        public static final String DELIVERED = "delivered";
        
        /** 已读 */
        public static final String READ = "read";
        
        /** 发送失败 */
        public static final String FAILED = "failed";
    }

    /**
     * 消息内容类型常量
     */
    public static class ContentType {
        /** 文本 */
        public static final String TEXT = "text";
        
        /** 图片 */
        public static final String IMAGE = "image";
        
        /** 文件 */
        public static final String FILE = "file";
        
        /** 语音 */
        public static final String VOICE = "voice";
        
        /** 视频 */
        public static final String VIDEO = "video";
        
        /** 系统 */
        public static final String SYSTEM = "system";
    }

    /**
     * 通知类型常量
     */
    public static class NotificationType {
        /** 信息 */
        public static final String INFO = "info";
        
        /** 警告 */
        public static final String WARNING = "warning";
        
        /** 错误 */
        public static final String ERROR = "error";
        
        /** 成功 */
        public static final String SUCCESS = "success";
    }
} 