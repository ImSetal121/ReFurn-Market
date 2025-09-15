package org.charno.chat.manager;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * WebSocket会话管理器
 * 管理用户的长连接会话
 */
@Component
public class WebSocketSessionManager {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketSessionManager.class);

    // 用户ID -> WebSocket会话的映射
    private final Map<Long, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    
    // 会话ID -> 用户ID的映射
    private final Map<String, Long> sessionUserMap = new ConcurrentHashMap<>();
    
    // 在线用户ID集合
    private final Set<Long> onlineUsers = new CopyOnWriteArraySet<>();

    /**
     * 添加用户会话
     */
    public void addSession(Long userId, WebSocketSession session) {
        if (userId == null || session == null) {
            return;
        }
        
        // 如果用户已经有会话，先移除旧会话
        removeSessionByUserId(userId);
        
        userSessions.put(userId, session);
        sessionUserMap.put(session.getId(), userId);
        onlineUsers.add(userId);
        
        logger.info("用户 {} 连接成功，会话ID: {}", userId, session.getId());
        logger.info("当前在线用户数: {}", onlineUsers.size());
    }

    /**
     * 根据会话ID移除会话
     */
    public void removeSession(String sessionId) {
        if (sessionId == null) {
            return;
        }
        
        Long userId = sessionUserMap.remove(sessionId);
        if (userId != null) {
            userSessions.remove(userId);
            onlineUsers.remove(userId);
            logger.info("用户 {} 断开连接，会话ID: {}", userId, sessionId);
            logger.info("当前在线用户数: {}", onlineUsers.size());
        }
    }

    /**
     * 根据用户ID移除会话
     */
    public void removeSessionByUserId(Long userId) {
        if (userId == null) {
            return;
        }
        
        WebSocketSession session = userSessions.remove(userId);
        if (session != null) {
            sessionUserMap.remove(session.getId());
            onlineUsers.remove(userId);
            logger.info("移除用户 {} 的会话", userId);
        }
    }

    /**
     * 根据用户ID获取会话
     */
    public WebSocketSession getSession(Long userId) {
        return userSessions.get(userId);
    }

    /**
     * 根据会话ID获取用户ID
     */
    public Long getUserId(String sessionId) {
        return sessionUserMap.get(sessionId);
    }

    /**
     * 检查用户是否在线
     */
    public boolean isUserOnline(Long userId) {
        return userId != null && onlineUsers.contains(userId);
    }

    /**
     * 获取所有在线用户ID
     */
    public Set<Long> getOnlineUsers() {
        return new CopyOnWriteArraySet<>(onlineUsers);
    }

    /**
     * 获取在线用户数量
     */
    public int getOnlineUserCount() {
        return onlineUsers.size();
    }

    /**
     * 清空所有会话
     */
    public void clearAllSessions() {
        userSessions.clear();
        sessionUserMap.clear();
        onlineUsers.clear();
        logger.info("清空所有WebSocket会话");
    }
} 