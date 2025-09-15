package org.charno.chat.service;

import com.alibaba.fastjson2.JSONObject;
import org.charno.chat.constants.ChatConstants;
import org.charno.chat.entity.ChatMessage;
import org.charno.chat.manager.WebSocketSessionManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.time.LocalDateTime;

/**
 * 消息推送服务
 * 用于主动向在线用户推送消息
 */
@Service
public class ChatMessagePushService {

    private static final Logger logger = LoggerFactory.getLogger(ChatMessagePushService.class);

    @Autowired
    private WebSocketSessionManager sessionManager;

    /**
     * 推送聊天消息给指定用户
     */
    public boolean pushMessageToUser(Long userId, ChatMessage message) {
        try {
            if (!sessionManager.isUserOnline(userId)) {
                logger.debug("用户 {} 不在线，无法推送消息", userId);
                return false;
            }

            WebSocketSession session = sessionManager.getSession(userId);
            if (session == null || !session.isOpen()) {
                logger.warn("用户 {} 的WebSocket会话无效", userId);
                sessionManager.removeSessionByUserId(userId);
                return false;
            }

            JSONObject messageJson = new JSONObject();
            messageJson.put("type", ChatConstants.MessageType.NEW_MESSAGE);
            messageJson.put("messageId", message.getId());
            messageJson.put("senderId", message.getSenderUserId());
            messageJson.put("content", message.getMessageContent());
            messageJson.put("messageType", message.getMessageType());
            messageJson.put("sendTime", message.getSendTime().toString());

            session.sendMessage(new TextMessage(messageJson.toString()));
            logger.info("成功推送消息给用户 {}", userId);
            return true;

        } catch (Exception e) {
            logger.error("推送消息给用户 {} 失败", userId, e);
            return false;
        }
    }

    /**
     * 推送系统消息给指定用户
     */
    public boolean pushSystemMessage(Long userId, String content, String messageType) {
        try {
            if (!sessionManager.isUserOnline(userId)) {
                logger.debug("用户 {} 不在线，无法推送系统消息", userId);
                return false;
            }

            WebSocketSession session = sessionManager.getSession(userId);
            if (session == null || !session.isOpen()) {
                logger.warn("用户 {} 的WebSocket会话无效", userId);
                sessionManager.removeSessionByUserId(userId);
                return false;
            }

            JSONObject messageJson = new JSONObject();
            messageJson.put("type", ChatConstants.MessageType.SYSTEM_MESSAGE);
            messageJson.put("messageType", messageType != null ? messageType : ChatConstants.ContentType.SYSTEM);
            messageJson.put("content", content);
            messageJson.put("timestamp", LocalDateTime.now().toString());

            session.sendMessage(new TextMessage(messageJson.toString()));
            logger.info("成功推送系统消息给用户 {}", userId);
            return true;

        } catch (Exception e) {
            logger.error("推送系统消息给用户 {} 失败", userId, e);
            return false;
        }
    }

    /**
     * 推送通知消息给指定用户
     */
    public boolean pushNotification(Long userId, String title, String content, String notificationType) {
        try {
            if (!sessionManager.isUserOnline(userId)) {
                logger.debug("用户 {} 不在线，无法推送通知", userId);
                return false;
            }

            WebSocketSession session = sessionManager.getSession(userId);
            if (session == null || !session.isOpen()) {
                logger.warn("用户 {} 的WebSocket会话无效", userId);
                sessionManager.removeSessionByUserId(userId);
                return false;
            }

            JSONObject notificationJson = new JSONObject();
            notificationJson.put("type", ChatConstants.MessageType.NOTIFICATION);
            notificationJson.put("notificationType", notificationType != null ? notificationType : ChatConstants.NotificationType.INFO);
            notificationJson.put("title", title);
            notificationJson.put("content", content);
            notificationJson.put("timestamp", LocalDateTime.now().toString());

            session.sendMessage(new TextMessage(notificationJson.toString()));
            logger.info("成功推送通知给用户 {}", userId);
            return true;

        } catch (Exception e) {
            logger.error("推送通知给用户 {} 失败", userId, e);
            return false;
        }
    }

    /**
     * 广播消息给所有在线用户
     */
    public void broadcastMessage(String content, String messageType) {
        try {
            JSONObject broadcastJson = new JSONObject();
            broadcastJson.put("type", ChatConstants.MessageType.BROADCAST);
            broadcastJson.put("messageType", messageType != null ? messageType : ChatConstants.MessageType.BROADCAST);
            broadcastJson.put("content", content);
            broadcastJson.put("timestamp", LocalDateTime.now().toString());

            String messageText = broadcastJson.toString();
            TextMessage textMessage = new TextMessage(messageText);

            int successCount = 0;
            int failCount = 0;

            for (Long userId : sessionManager.getOnlineUsers()) {
                try {
                    WebSocketSession session = sessionManager.getSession(userId);
                    if (session != null && session.isOpen()) {
                        session.sendMessage(textMessage);
                        successCount++;
                    } else {
                        sessionManager.removeSessionByUserId(userId);
                        failCount++;
                    }
                } catch (Exception e) {
                    logger.warn("广播消息给用户 {} 失败", userId, e);
                    failCount++;
                }
            }

            logger.info("广播消息完成，成功: {}, 失败: {}", successCount, failCount);

        } catch (Exception e) {
            logger.error("广播消息失败", e);
        }
    }

    /**
     * 推送用户状态变化消息
     */
    public boolean pushUserStatusChange(Long userId, String status, Object data) {
        try {
            if (!sessionManager.isUserOnline(userId)) {
                return false;
            }

            WebSocketSession session = sessionManager.getSession(userId);
            if (session == null || !session.isOpen()) {
                sessionManager.removeSessionByUserId(userId);
                return false;
            }

            JSONObject statusJson = new JSONObject();
            statusJson.put("type", ChatConstants.MessageType.USER_STATUS);
            statusJson.put("status", status);
            statusJson.put("data", data);
            statusJson.put("timestamp", LocalDateTime.now().toString());

            session.sendMessage(new TextMessage(statusJson.toString()));
            return true;

        } catch (Exception e) {
            logger.error("推送用户状态变化给用户 {} 失败", userId, e);
            return false;
        }
    }
} 