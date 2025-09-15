package org.charno.chat.config;

import org.apache.catalina.connector.Connector;
import org.charno.chat.handler.ChatWebSocketHandler;
import org.charno.chat.interceptor.WebSocketAuthInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

/**
 * 聊天WebSocket配置类
 * 配置WebSocket处理器，在主应用中运行但使用独立的路径
 */
@Configuration
@EnableWebSocket
public class ChatWebSocketConfig implements WebSocketConfigurer {

    @Autowired
    private ChatWebSocketHandler chatWebSocketHandler;
    
    @Autowired
    private WebSocketAuthInterceptor webSocketAuthInterceptor;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // 注册WebSocket处理器，允许跨域
        registry.addHandler(chatWebSocketHandler, "/chat/websocket")
                .addInterceptors(webSocketAuthInterceptor)
                .setAllowedOrigins("*");
    }

    /**
     * 配置额外的8081端口用于WebSocket连接
     * 这样客户端可以通过 ws://localhost:8081/chat/websocket 连接
     */
    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> webSocketPortCustomizer() {
        return factory -> {
            // 创建额外的连接器监听8081端口
            Connector connector = new Connector("org.apache.coyote.http11.Http11NioProtocol");
            connector.setPort(8081);
            connector.setScheme("http");
            connector.setSecure(false);
            
            // 添加连接器到Tomcat
            factory.addAdditionalTomcatConnectors(connector);
        };
    }
} 