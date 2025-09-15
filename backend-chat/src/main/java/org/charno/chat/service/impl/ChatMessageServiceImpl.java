package org.charno.chat.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.charno.chat.entity.ChatMessage;
import org.charno.chat.mapper.ChatMessageMapper;
import org.charno.chat.service.IChatMessageService;
import org.charno.chat.dto.ChatListDTO;
import org.charno.chat.manager.WebSocketSessionManager;
import org.charno.system.service.ISysUserService;
import org.charno.common.entity.SysUser;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.stream.Collectors;
import java.time.LocalDateTime;

/**
 * 聊天消息业务实现类
 */
@Service
public class ChatMessageServiceImpl extends ServiceImpl<ChatMessageMapper, ChatMessage> implements IChatMessageService {

    @Autowired
    private WebSocketSessionManager sessionManager;
    
    @Autowired
    private ISysUserService sysUserService;

    @Override
    public Page<ChatMessage> selectPageWithCondition(Page<ChatMessage> page, ChatMessage condition) {
        LambdaQueryWrapper<ChatMessage> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getSenderUserId() != null) {
                queryWrapper.eq(ChatMessage::getSenderUserId, condition.getSenderUserId());
            }
            if (condition.getReceiverUserId() != null) {
                queryWrapper.eq(ChatMessage::getReceiverUserId, condition.getReceiverUserId());
            }
            if (condition.getMessageType() != null && !condition.getMessageType().isEmpty()) {
                queryWrapper.eq(ChatMessage::getMessageType, condition.getMessageType());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(ChatMessage::getStatus, condition.getStatus());
            }
            if (condition.getIsRead() != null) {
                queryWrapper.eq(ChatMessage::getIsRead, condition.getIsRead());
            }
        }
        
        queryWrapper.orderByDesc(ChatMessage::getSendTime);
        return this.page(page, queryWrapper);
    }

    @Override
    public List<ChatMessage> selectListWithCondition(ChatMessage condition) {
        LambdaQueryWrapper<ChatMessage> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getSenderUserId() != null) {
                queryWrapper.eq(ChatMessage::getSenderUserId, condition.getSenderUserId());
            }
            if (condition.getReceiverUserId() != null) {
                queryWrapper.eq(ChatMessage::getReceiverUserId, condition.getReceiverUserId());
            }
            if (condition.getMessageType() != null && !condition.getMessageType().isEmpty()) {
                queryWrapper.eq(ChatMessage::getMessageType, condition.getMessageType());
            }
            if (condition.getStatus() != null && !condition.getStatus().isEmpty()) {
                queryWrapper.eq(ChatMessage::getStatus, condition.getStatus());
            }
            if (condition.getIsRead() != null) {
                queryWrapper.eq(ChatMessage::getIsRead, condition.getIsRead());
            }
        }
        
        queryWrapper.orderByDesc(ChatMessage::getSendTime);
        return this.list(queryWrapper);
    }

    @Override
    public List<ChatMessage> getChatHistory(Long userId1, Long userId2) {
        if (userId1 == null || userId2 == null) {
            return List.of();
        }
        
        LambdaQueryWrapper<ChatMessage> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.and(wrapper -> wrapper
            .and(w -> w.eq(ChatMessage::getSenderUserId, userId1).eq(ChatMessage::getReceiverUserId, userId2))
            .or(w -> w.eq(ChatMessage::getSenderUserId, userId2).eq(ChatMessage::getReceiverUserId, userId1))
        );
        queryWrapper.orderByDesc(ChatMessage::getSendTime);
        
        return this.list(queryWrapper);
    }

    @Override
    public Page<ChatMessage> getChatHistoryPage(Page<ChatMessage> page, Long userId1, Long userId2) {
        if (userId1 == null || userId2 == null) {
            return page;
        }
        
        LambdaQueryWrapper<ChatMessage> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.and(wrapper -> wrapper
            .and(w -> w.eq(ChatMessage::getSenderUserId, userId1).eq(ChatMessage::getReceiverUserId, userId2))
            .or(w -> w.eq(ChatMessage::getSenderUserId, userId2).eq(ChatMessage::getReceiverUserId, userId1))
        );
        queryWrapper.orderByDesc(ChatMessage::getSendTime);
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<ChatMessage> getUnreadMessages(Long userId) {
        if (userId == null) {
            return List.of();
        }
        
        LambdaQueryWrapper<ChatMessage> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ChatMessage::getReceiverUserId, userId)
                   .eq(ChatMessage::getIsRead, false)
                   .orderByDesc(ChatMessage::getSendTime);
        
        return this.list(queryWrapper);
    }

    @Override
    public boolean markAsRead(Long messageId) {
        if (messageId == null) {
            return false;
        }
        
        LambdaUpdateWrapper<ChatMessage> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(ChatMessage::getId, messageId)
                    .set(ChatMessage::getIsRead, true);
        
        return this.update(updateWrapper);
    }

    @Override
    public boolean markAsReadBatch(List<Long> messageIds) {
        if (messageIds == null || messageIds.isEmpty()) {
            return false;
        }
        
        LambdaUpdateWrapper<ChatMessage> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.in(ChatMessage::getId, messageIds)
                    .set(ChatMessage::getIsRead, true);
        
        return this.update(updateWrapper);
    }

    @Override
    public boolean markChatAsRead(Long senderId, Long receiverId) {
        if (senderId == null || receiverId == null) {
            return false;
        }
        
        LambdaUpdateWrapper<ChatMessage> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(ChatMessage::getSenderUserId, senderId)
                    .eq(ChatMessage::getReceiverUserId, receiverId)
                    .set(ChatMessage::getIsRead, true);
        
        return this.update(updateWrapper);
    }

    @Override
    public Long getUnreadCount(Long userId) {
        if (userId == null) {
            return 0L;
        }
        
        LambdaQueryWrapper<ChatMessage> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ChatMessage::getReceiverUserId, userId)
                   .eq(ChatMessage::getIsRead, false);
        
        return this.count(queryWrapper);
    }

    @Override
    public List<ChatListDTO> getChatList(Long currentUserId) {
        if (currentUserId == null) {
            return List.of();
        }

        // 1. 获取所有与当前用户相关的聊天消息，按对方用户分组
        LambdaQueryWrapper<ChatMessage> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.and(wrapper -> wrapper
            .eq(ChatMessage::getSenderUserId, currentUserId)
            .or(w -> w.eq(ChatMessage::getReceiverUserId, currentUserId))
        );
        queryWrapper.orderByDesc(ChatMessage::getSendTime);
        
        List<ChatMessage> allMessages = this.list(queryWrapper);
        if (allMessages.isEmpty()) {
            return List.of();
        }

        // 2. 按对方用户ID分组，获取每个聊天的最新消息
        Map<Long, ChatMessage> latestMessageMap = allMessages.stream()
            .collect(Collectors.toMap(
                message -> message.getSenderUserId().equals(currentUserId) 
                    ? message.getReceiverUserId() 
                    : message.getSenderUserId(),
                message -> message,
                (existing, replacement) -> 
                    existing.getSendTime().isAfter(replacement.getSendTime()) ? existing : replacement
            ));

        // 3. 获取所有对方用户的ID列表
        List<Long> otherUserIds = new ArrayList<>(latestMessageMap.keySet());
        if (otherUserIds.isEmpty()) {
            return List.of();
        }

        // 4. 批量获取用户信息
        List<SysUser> users = sysUserService.listByIds(otherUserIds);
        Map<Long, SysUser> userMap = users.stream()
            .collect(Collectors.toMap(SysUser::getId, user -> user));

        // 5. 构建聊天列表
        List<ChatListDTO> chatList = new ArrayList<>();
        for (Map.Entry<Long, ChatMessage> entry : latestMessageMap.entrySet()) {
            Long otherUserId = entry.getKey();
            ChatMessage latestMessage = entry.getValue();
            SysUser otherUser = userMap.get(otherUserId);
            
            if (otherUser == null) {
                continue; // 用户不存在，跳过
            }

            // 计算未读消息数量
            LambdaQueryWrapper<ChatMessage> unreadQuery = new LambdaQueryWrapper<>();
            unreadQuery.eq(ChatMessage::getSenderUserId, otherUserId)
                      .eq(ChatMessage::getReceiverUserId, currentUserId)
                      .eq(ChatMessage::getIsRead, false);
            int unreadCount = Math.toIntExact(this.count(unreadQuery));

            // 检查用户是否在线
            boolean isOnline = sessionManager.isUserOnline(otherUserId);

            // 创建聊天列表项
            ChatListDTO chatItem = new ChatListDTO(
                otherUserId,
                otherUser.getNickname() != null ? otherUser.getNickname() : otherUser.getUsername(),
                otherUser.getAvatar(),
                latestMessage.getMessageContent(),
                latestMessage.getSendTime(),
                unreadCount,
                isOnline
            );
            
            chatList.add(chatItem);
        }

        // 6. 按最后消息时间倒序排列
        chatList.sort((a, b) -> b.getLastMessageTime().compareTo(a.getLastMessageTime()));

        return chatList;
    }
} 