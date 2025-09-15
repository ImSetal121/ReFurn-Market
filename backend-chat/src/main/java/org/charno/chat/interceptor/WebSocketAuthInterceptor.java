package org.charno.chat.interceptor;

import org.charno.common.utils.JwtUtils;
import org.charno.common.utils.RedisUtils;
import org.charno.common.security.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

/**
 * WebSocket认证拦截器
 * 参考AuthenticationFilter的逻辑进行WebSocket连接认证
 */
@Component
public class WebSocketAuthInterceptor implements HandshakeInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketAuthInterceptor.class);

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private RedisUtils redisUtils;

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                   WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        
        logger.debug("WebSocket握手请求: {}", request.getURI());
        
        // 从请求参数中获取token
        String token = getTokenFromRequest(request);
        
        if (token == null || token.isEmpty()) {
            logger.warn("WebSocket握手失败: 未提供token");
            return false;
        }

        // 验证token
        if (!jwtUtils.validateToken(token)) {
            logger.warn("WebSocket握手失败: token无效");
            return false;
        }

        // 获取用户信息
        LoginUser loginUser = (LoginUser) redisUtils.getLoginUser(token);
        if (loginUser == null) {
            logger.warn("WebSocket握手失败: 无法获取用户信息");
            return false;
        }

        // 将用户信息存储到WebSocket会话属性中
        attributes.put("loginUser", loginUser);
        attributes.put("token", token);
        attributes.put("userId", loginUser.getUser().getId());
        
        logger.info("WebSocket握手成功: 用户ID={}, 用户名={}", 
                   loginUser.getUser().getId(), loginUser.getUser().getUsername());
        
        // 刷新token过期时间
        redisUtils.refreshToken(token);
        
        return true;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
                               WebSocketHandler wsHandler, Exception exception) {
        if (exception != null) {
            logger.error("WebSocket握手后发生异常", exception);
        }
    }

    /**
     * 从请求中获取token
     * 支持从Header的Authorization字段或查询参数token字段获取
     */
    private String getTokenFromRequest(ServerHttpRequest request) {
        // 首先尝试从Authorization header获取
        String authHeader = request.getHeaders().getFirst("Authorization");
        if (authHeader != null && !authHeader.isEmpty()) {
            if (authHeader.startsWith("Bearer ")) {
                return authHeader.substring(7);
            } else {
                return authHeader;
            }
        }
        
        // 然后尝试从查询参数获取
        String query = request.getURI().getQuery();
        if (query != null) {
            String[] params = query.split("&");
            for (String param : params) {
                String[] keyValue = param.split("=");
                if (keyValue.length == 2 && "token".equals(keyValue[0])) {
                    return keyValue[1];
                }
            }
        }
        
        return null;
    }
} 