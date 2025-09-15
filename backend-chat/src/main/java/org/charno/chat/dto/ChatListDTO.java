package org.charno.chat.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 聊天列表项DTO
 */
@Data
public class ChatListDTO {
    
    /** 用户ID */
    private Long userId;
    
    /** 用户名 */
    private String userName;
    
    /** 用户头像 */
    private String userAvatar;
    
    /** 最后一条消息内容 */
    private String lastMessage;
    
    /** 最后消息时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastMessageTime;
    
    /** 未读消息数量 */
    private Integer unreadCount;
    
    /** 是否在线 */
    private Boolean isOnline;
    
    public ChatListDTO() {}
    
    public ChatListDTO(Long userId, String userName, String userAvatar, 
                      String lastMessage, LocalDateTime lastMessageTime, 
                      Integer unreadCount, Boolean isOnline) {
        this.userId = userId;
        this.userName = userName;
        this.userAvatar = userAvatar;
        this.lastMessage = lastMessage;
        this.lastMessageTime = lastMessageTime;
        this.unreadCount = unreadCount;
        this.isOnline = isOnline;
    }
} 