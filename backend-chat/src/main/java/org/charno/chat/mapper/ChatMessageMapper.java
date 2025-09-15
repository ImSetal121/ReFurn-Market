package org.charno.chat.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.chat.entity.ChatMessage;

/**
 * 聊天消息数据访问层
 */
@Mapper
public interface ChatMessageMapper extends BaseMapper<ChatMessage> {
} 