package org.charno.chat.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.chat.entity.ChatMessage;
import org.charno.chat.dto.ChatListDTO;
import org.charno.chat.manager.WebSocketSessionManager;
import org.charno.chat.service.IChatMessageService;
import org.charno.common.core.R;
import org.charno.common.security.LoginUser;
import org.charno.common.utils.SecurityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

/**
 * 聊天控制器
 * 提供HTTP API接口用于获取聊天记录、发送消息等功能
 */
@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private static final Logger logger = LoggerFactory.getLogger(ChatController.class);

    @Autowired
    private IChatMessageService chatMessageService;

    @Autowired
    private WebSocketSessionManager sessionManager;

    /**
     * 获取聊天列表
     * 返回与当前用户有过聊天记录的所有用户信息
     */
    @GetMapping("/list")
    public R<List<ChatListDTO>> getChatList() {
        try {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            if (loginUser == null || loginUser.getUser() == null) {
                return R.fail("未登录");
            }
            
            Long currentUserId = loginUser.getUser().getId();
            List<ChatListDTO> chatList = chatMessageService.getChatList(currentUserId);
            
            return R.ok(chatList, "获取聊天列表成功");
        } catch (Exception e) {
            logger.error("获取聊天列表失败", e);
            return R.fail("获取聊天列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取与指定用户的聊天记录
     */
    @GetMapping("/history/{otherUserId}")
    public R<List<ChatMessage>> getChatHistory(@PathVariable Long otherUserId) {
        try {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            if (loginUser == null || loginUser.getUser() == null) {
                return R.fail("未登录");
            }
            
            Long currentUserId = loginUser.getUser().getId();
            List<ChatMessage> messages = chatMessageService.getChatHistory(currentUserId, otherUserId);
            
            return R.ok(messages, "获取聊天记录成功");
        } catch (Exception e) {
            logger.error("获取聊天记录失败", e);
            return R.fail("获取聊天记录失败: " + e.getMessage());
        }
    }

    /**
     * 分页获取与指定用户的聊天记录
     */
    @GetMapping("/history/{otherUserId}/page")
    public R<Page<ChatMessage>> getChatHistoryPage(
            @PathVariable Long otherUserId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            if (loginUser == null || loginUser.getUser() == null) {
                return R.fail("未登录");
            }
            
            Long currentUserId = loginUser.getUser().getId();
            Page<ChatMessage> pageInfo = new Page<>(page, size);
            Page<ChatMessage> result = chatMessageService.getChatHistoryPage(pageInfo, currentUserId, otherUserId);
            
            return R.ok(result, "获取聊天记录成功");
        } catch (Exception e) {
            logger.error("分页获取聊天记录失败", e);
            return R.fail("分页获取聊天记录失败: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的未读消息
     */
    @GetMapping("/unread")
    public R<List<ChatMessage>> getUnreadMessages() {
        try {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            if (loginUser == null || loginUser.getUser() == null) {
                return R.fail("未登录");
            }
            
            Long currentUserId = loginUser.getUser().getId();
            List<ChatMessage> unreadMessages = chatMessageService.getUnreadMessages(currentUserId);
            
            return R.ok(unreadMessages, "获取未读消息成功");
        } catch (Exception e) {
            logger.error("获取未读消息失败", e);
            return R.fail("获取未读消息失败: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的未读消息数量
     */
    @GetMapping("/unread/count")
    public R<Long> getUnreadCount() {
        try {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            if (loginUser == null || loginUser.getUser() == null) {
                return R.fail("未登录");
            }
            
            Long currentUserId = loginUser.getUser().getId();
            Long unreadCount = chatMessageService.getUnreadCount(currentUserId);
            
            return R.ok(unreadCount, "获取未读消息数量成功");
        } catch (Exception e) {
            logger.error("获取未读消息数量失败", e);
            return R.fail("获取未读消息数量失败: " + e.getMessage());
        }
    }

    /**
     * 标记消息为已读
     */
    @PostMapping("/mark-read/{messageId}")
    public R<Boolean> markAsRead(@PathVariable Long messageId) {
        try {
            boolean success = chatMessageService.markAsRead(messageId);
            if (success) {
                return R.ok(true, "标记已读成功");
            } else {
                return R.fail("标记已读失败");
            }
        } catch (Exception e) {
            logger.error("标记消息已读失败", e);
            return R.fail("标记消息已读失败: " + e.getMessage());
        }
    }

    /**
     * 批量标记消息为已读
     */
    @PostMapping("/mark-read/batch")
    public R<Boolean> markAsReadBatch(@RequestBody List<Long> messageIds) {
        try {
            boolean success = chatMessageService.markAsReadBatch(messageIds);
            if (success) {
                return R.ok(true, "批量标记已读成功");
            } else {
                return R.fail("批量标记已读失败");
            }
        } catch (Exception e) {
            logger.error("批量标记消息已读失败", e);
            return R.fail("批量标记消息已读失败: " + e.getMessage());
        }
    }

    /**
     * 标记与指定用户的所有消息为已读
     */
    @PostMapping("/mark-read/chat/{otherUserId}")
    public R<Boolean> markChatAsRead(@PathVariable Long otherUserId) {
        try {
            LoginUser loginUser = SecurityUtils.getLoginUser();
            if (loginUser == null || loginUser.getUser() == null) {
                return R.fail("未登录");
            }
            
            Long currentUserId = loginUser.getUser().getId();
            boolean success = chatMessageService.markChatAsRead(otherUserId, currentUserId);
            
            if (success) {
                return R.ok(true, "标记聊天已读成功");
            } else {
                return R.fail("标记聊天已读失败");
            }
        } catch (Exception e) {
            logger.error("标记聊天已读失败", e);
            return R.fail("标记聊天已读失败: " + e.getMessage());
        }
    }

    /**
     * 检查用户是否在线
     */
    @GetMapping("/online/{userId}")
    public R<Boolean> isUserOnline(@PathVariable Long userId) {
        try {
            boolean isOnline = sessionManager.isUserOnline(userId);
            return R.ok(isOnline, isOnline ? "用户在线" : "用户离线");
        } catch (Exception e) {
            logger.error("检查用户在线状态失败", e);
            return R.fail("检查用户在线状态失败: " + e.getMessage());
        }
    }

    /**
     * 获取所有在线用户
     */
    @GetMapping("/online/users")
    public R<Set<Long>> getOnlineUsers() {
        try {
            Set<Long> onlineUsers = sessionManager.getOnlineUsers();
            return R.ok(onlineUsers, "获取在线用户成功");
        } catch (Exception e) {
            logger.error("获取在线用户失败", e);
            return R.fail("获取在线用户失败: " + e.getMessage());
        }
    }

    /**
     * 获取在线用户数量
     */
    @GetMapping("/online/count")
    public R<Integer> getOnlineUserCount() {
        try {
            int count = sessionManager.getOnlineUserCount();
            return R.ok(count, "获取在线用户数量成功");
        } catch (Exception e) {
            logger.error("获取在线用户数量失败", e);
            return R.fail("获取在线用户数量失败: " + e.getMessage());
        }
    }
} 