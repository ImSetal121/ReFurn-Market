package org.charno.chat.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.chat.entity.ChatMessage;
import org.charno.chat.service.IChatMessageService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 聊天消息控制器
 */
@RestController
@RequestMapping("/api/chat/message")
public class ChatMessageController {

    @Autowired
    private IChatMessageService chatMessageService;

    /**
     * 发送消息
     */
    @PostMapping("/send")
    public R<Boolean> sendMessage(@RequestBody ChatMessage chatMessage) {
        boolean result = chatMessageService.save(chatMessage);
        return result ? R.ok(result) : R.fail("发送失败");
    }

    /**
     * 根据ID删除消息
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = chatMessageService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除消息
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = chatMessageService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新消息
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody ChatMessage chatMessage) {
        boolean result = chatMessageService.updateById(chatMessage);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询消息
     */
    @GetMapping("/{id}")
    public R<ChatMessage> getById(@PathVariable Long id) {
        ChatMessage chatMessage = chatMessageService.getById(id);
        return R.ok(chatMessage);
    }

    /**
     * 获取两个用户之间的聊天记录
     */
    @GetMapping("/history/{userId1}/{userId2}")
    public R<List<ChatMessage>> getChatHistory(@PathVariable Long userId1, @PathVariable Long userId2) {
        List<ChatMessage> result = chatMessageService.getChatHistory(userId1, userId2);
        return R.ok(result);
    }

    /**
     * 分页获取两个用户之间的聊天记录
     */
    @GetMapping("/history/page/{userId1}/{userId2}")
    public R<Page<ChatMessage>> getChatHistoryPage(
            @PathVariable Long userId1, 
            @PathVariable Long userId2,
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "20") Integer size) {
        Page<ChatMessage> page = new Page<>(current, size);
        Page<ChatMessage> result = chatMessageService.getChatHistoryPage(page, userId1, userId2);
        return R.ok(result);
    }

    /**
     * 获取用户的未读消息
     */
    @GetMapping("/unread/{userId}")
    public R<List<ChatMessage>> getUnreadMessages(@PathVariable Long userId) {
        List<ChatMessage> result = chatMessageService.getUnreadMessages(userId);
        return R.ok(result);
    }

    /**
     * 获取用户的未读消息数量
     */
    @GetMapping("/unread/count/{userId}")
    public R<Long> getUnreadCount(@PathVariable Long userId) {
        Long count = chatMessageService.getUnreadCount(userId);
        return R.ok(count);
    }

    /**
     * 标记消息为已读
     */
    @PutMapping("/read/{messageId}")
    public R<Boolean> markAsRead(@PathVariable Long messageId) {
        boolean result = chatMessageService.markAsRead(messageId);
        return result ? R.ok(result) : R.fail("标记失败");
    }

    /**
     * 批量标记消息为已读
     */
    @PutMapping("/read/batch")
    public R<Boolean> markAsReadBatch(@RequestBody List<Long> messageIds) {
        boolean result = chatMessageService.markAsReadBatch(messageIds);
        return result ? R.ok(result) : R.fail("批量标记失败");
    }

    /**
     * 标记两个用户之间的所有消息为已读
     */
    @PutMapping("/read/chat/{senderId}/{receiverId}")
    public R<Boolean> markChatAsRead(@PathVariable Long senderId, @PathVariable Long receiverId) {
        boolean result = chatMessageService.markChatAsRead(senderId, receiverId);
        return result ? R.ok(result) : R.fail("标记失败");
    }

    /**
     * 分页条件查询消息
     */
    @GetMapping("/page")
    public R<Page<ChatMessage>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            ChatMessage condition) {
        Page<ChatMessage> page = new Page<>(current, size);
        Page<ChatMessage> result = chatMessageService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询消息
     */
    @GetMapping("/list")
    public R<List<ChatMessage>> selectListWithCondition(ChatMessage condition) {
        List<ChatMessage> result = chatMessageService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有消息
     */
    @GetMapping("/all")
    public R<List<ChatMessage>> list() {
        List<ChatMessage> result = chatMessageService.list();
        return R.ok(result);
    }
} 