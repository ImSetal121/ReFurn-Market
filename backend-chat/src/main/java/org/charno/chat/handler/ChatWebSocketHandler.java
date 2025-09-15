package org.charno.chat.handler;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import org.charno.chat.constants.ChatConstants;
import org.charno.chat.entity.ChatMessage;
import org.charno.chat.manager.WebSocketSessionManager;
import org.charno.chat.service.IChatMessageService;
import org.charno.common.security.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;

import java.time.LocalDateTime;

/**
 * WebSocket处理器
 * 处理连接建立、消息接收、连接关闭等事件
 */
@Component
public class ChatWebSocketHandler implements WebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger(ChatWebSocketHandler.class);

    @Autowired
    private WebSocketSessionManager sessionManager;

    @Autowired
    private IChatMessageService chatMessageService;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        // 从会话属性中获取用户信息
        LoginUser loginUser = (LoginUser) session.getAttributes().get("loginUser");
        Long userId = (Long) session.getAttributes().get("userId");
        
        if (loginUser != null && userId != null) {
            // 将会话添加到管理器
            sessionManager.addSession(userId, session);
            
            // 发送连接成功消息
            JSONObject response = new JSONObject();
            response.put("type", ChatConstants.MessageType.CONNECTION);
            response.put("status", "success");
            response.put("message", "连接成功");
            response.put("userId", userId);
            response.put("timestamp", LocalDateTime.now().toString());
            
            session.sendMessage(new TextMessage(response.toString()));
            
            logger.info("用户 {} 建立WebSocket连接成功", userId);
        } else {
            logger.error("WebSocket连接建立失败：无法获取用户信息");
            session.close();
        }
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {
        if (message instanceof TextMessage textMessage) {
            handleTextMessage(session, textMessage);
        } else if (message instanceof BinaryMessage) {
            logger.warn("暂不支持二进制消息");
        }
    }

    /**
     * 处理文本消息
     */
    private void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        logger.debug("收到WebSocket消息: {}", payload);
        
        try {
            JSONObject messageJson = JSON.parseObject(payload);
            String messageType = messageJson.getString("type");
            
            switch (messageType) {
                case ChatConstants.MessageType.CHAT -> handleChatMessage(session, messageJson);
                case ChatConstants.MessageType.PING -> handlePingMessage(session);
                case ChatConstants.MessageType.TYPING -> handleTypingMessage(session, messageJson);
                default -> logger.warn("未知的消息类型: {}", messageType);
            }
        } catch (Exception e) {
            logger.error("处理WebSocket消息失败", e);
            sendErrorMessage(session, "消息处理失败: " + e.getMessage());
        }
    }

    /**
     * 处理聊天消息
     */
    private void handleChatMessage(WebSocketSession session, JSONObject messageJson) throws Exception {
        Long senderId = (Long) session.getAttributes().get("userId");
        Long receiverId = messageJson.getLong("receiverId");
        String content = messageJson.getString("content");
        String msgType = messageJson.getString("messageType");
        
        if (senderId == null || receiverId == null || content == null) {
            sendErrorMessage(session, "消息参数不完整");
            return;
        }
        
        // 验证不能给自己发消息
        if (senderId.equals(receiverId)) {
            logger.warn("用户 {} 尝试给自己发送消息，已拒绝", senderId);
            sendErrorMessage(session, "不能给自己发送消息");
            return;
        }
        
        // 创建聊天消息对象
        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setSenderUserId(senderId);
        chatMessage.setReceiverUserId(receiverId);
        chatMessage.setMessageContent(content);
        chatMessage.setMessageType(msgType != null ? msgType : ChatConstants.ContentType.TEXT);
        chatMessage.setSendTime(LocalDateTime.now());
        chatMessage.setStatus(ChatConstants.MessageStatus.SENT);
        chatMessage.setIsRead(false);
        chatMessage.setCreateTime(LocalDateTime.now());
        chatMessage.setUpdateTime(LocalDateTime.now());
        chatMessage.setIsDelete(false);
        
        // 保存消息到数据库
        boolean saved = chatMessageService.save(chatMessage);
        if (!saved) {
            sendErrorMessage(session, "消息保存失败");
            return;
        }
        
        // 发送确认消息给发送者
        JSONObject senderResponse = new JSONObject();
        senderResponse.put("type", ChatConstants.MessageType.MESSAGE_SENT);
        senderResponse.put("messageId", chatMessage.getId());
        senderResponse.put("status", "success");
        senderResponse.put("timestamp", chatMessage.getSendTime().toString());
        session.sendMessage(new TextMessage(senderResponse.toString()));
        
        // 检查接收者是否在线，如果在线则推送消息
        if (sessionManager.isUserOnline(receiverId)) {
            WebSocketSession receiverSession = sessionManager.getSession(receiverId);
            if (receiverSession != null && receiverSession.isOpen()) {
                JSONObject receiverMessage = new JSONObject();
                receiverMessage.put("type", ChatConstants.MessageType.NEW_MESSAGE);
                receiverMessage.put("messageId", chatMessage.getId());
                receiverMessage.put("senderId", senderId);
                receiverMessage.put("content", content);
                receiverMessage.put("messageType", chatMessage.getMessageType());
                receiverMessage.put("sendTime", chatMessage.getSendTime().toString());
                
                receiverSession.sendMessage(new TextMessage(receiverMessage.toString()));
                logger.info("消息已推送给在线用户 {}", receiverId);
            }
        } else {
            logger.info("用户 {} 不在线，消息已保存到数据库", receiverId);
        }
    }

    /**
     * 处理心跳消息
     */
    private void handlePingMessage(WebSocketSession session) throws Exception {
        JSONObject pongResponse = new JSONObject();
        pongResponse.put("type", ChatConstants.MessageType.PONG);
        pongResponse.put("timestamp", LocalDateTime.now().toString());
        session.sendMessage(new TextMessage(pongResponse.toString()));
    }

    /**
     * 处理正在输入消息
     */
    private void handleTypingMessage(WebSocketSession session, JSONObject messageJson) throws Exception {
        Long senderId = (Long) session.getAttributes().get("userId");
        Long receiverId = messageJson.getLong("receiverId");
        Boolean isTyping = messageJson.getBoolean("isTyping");
        
        if (senderId == null || receiverId == null || isTyping == null) {
            return;
        }
        
        // 如果接收者在线，转发正在输入状态
        if (sessionManager.isUserOnline(receiverId)) {
            WebSocketSession receiverSession = sessionManager.getSession(receiverId);
            if (receiverSession != null && receiverSession.isOpen()) {
                JSONObject typingMessage = new JSONObject();
                typingMessage.put("type", ChatConstants.MessageType.TYPING);
                typingMessage.put("senderId", senderId);
                typingMessage.put("isTyping", isTyping);
                
                receiverSession.sendMessage(new TextMessage(typingMessage.toString()));
            }
        }
    }

    /**
     * 发送错误消息
     */
    private void sendErrorMessage(WebSocketSession session, String errorMsg) throws Exception {
        JSONObject errorResponse = new JSONObject();
        errorResponse.put("type", ChatConstants.MessageType.ERROR);
        errorResponse.put("message", errorMsg);
        errorResponse.put("timestamp", LocalDateTime.now().toString());
        session.sendMessage(new TextMessage(errorResponse.toString()));
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        logger.error("WebSocket传输错误", exception);
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            sessionManager.removeSessionByUserId(userId);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus closeStatus) throws Exception {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            sessionManager.removeSession(session.getId());
            logger.info("用户 {} 断开WebSocket连接，状态: {}", userId, closeStatus);
        }
    }

    @Override
    public boolean supportsPartialMessages() {
        return false;
    }
} 