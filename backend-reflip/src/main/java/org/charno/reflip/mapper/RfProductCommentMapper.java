package org.charno.reflip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.charno.reflip.entity.RfProductComment;

/**
 * 商品留言数据访问层
 */
@Mapper
public interface RfProductCommentMapper extends BaseMapper<RfProductComment> {
} 