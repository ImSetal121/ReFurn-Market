package org.charno.chat.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

/**
 * 聊天模块启动监听器
 * 在应用启动完成后输出聊天服务信息
 */
@Component
public class ChatModuleStartupListener implements ApplicationListener<ApplicationReadyEvent> {

    private static final Logger logger = LoggerFactory.getLogger(ChatModuleStartupListener.class);

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        logger.info("==============================================");
        logger.info("    ReFlip 聊天模块已启动！");
        logger.info("    主应用端口: 8080");
        logger.info("    WebSocket服务端口: 8081");
        logger.info("    WebSocket连接地址: ws://localhost:8081/chat/websocket");
        logger.info("    聊天API地址: http://localhost:8080/api/chat");
        logger.info("==============================================");
        
        // 输出WebSocket连接示例
        logger.info("WebSocket连接示例:");
        logger.info("  const websocket = new WebSocket('ws://localhost:8081/chat/websocket?token=YOUR_JWT_TOKEN');");
        
        // 输出消息格式示例
        logger.info("消息格式示例:");
        logger.info("  发送: {\"type\":\"chat\",\"receiverId\":123,\"content\":\"Hello!\",\"messageType\":\"text\"}");
    }
} 