package org.charno.chat.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.chat.entity.ChatMessage;
import org.charno.chat.dto.ChatListDTO;
import java.util.List;

/**
 * 聊天消息业务接口
 */
public interface IChatMessageService extends IBaseService<ChatMessage> {
    
    /**
     * 分页条件查询
     */
    Page<ChatMessage> selectPageWithCondition(Page<ChatMessage> page, ChatMessage condition);
    
    /**
     * 不分页条件查询
     */
    List<ChatMessage> selectListWithCondition(ChatMessage condition);
    
    /**
     * 获取两个用户之间的聊天记录
     */
    List<ChatMessage> getChatHistory(Long userId1, Long userId2);
    
    /**
     * 分页获取两个用户之间的聊天记录
     */
    Page<ChatMessage> getChatHistoryPage(Page<ChatMessage> page, Long userId1, Long userId2);
    
    /**
     * 获取用户的所有未读消息
     */
    List<ChatMessage> getUnreadMessages(Long userId);
    
    /**
     * 标记消息为已读
     */
    boolean markAsRead(Long messageId);
    
    /**
     * 批量标记消息为已读
     */
    boolean markAsReadBatch(List<Long> messageIds);
    
    /**
     * 标记两个用户之间的所有消息为已读
     */
    boolean markChatAsRead(Long senderId, Long receiverId);
    
    /**
     * 获取用户的未读消息数量
     */
    Long getUnreadCount(Long userId);
    
    /**
     * 获取用户的聊天列表
     * 返回与当前用户有过聊天记录的所有用户信息
     */
    List<ChatListDTO> getChatList(Long currentUserId);
} 