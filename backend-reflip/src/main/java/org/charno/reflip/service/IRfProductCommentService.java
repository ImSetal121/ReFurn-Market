package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductComment;
import java.util.List;

/**
 * 商品留言业务接口
 */
public interface IRfProductCommentService extends IBaseService<RfProductComment> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductComment> selectPageWithCondition(Page<RfProductComment> page, RfProductComment condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductComment> selectListWithCondition(RfProductComment condition);
} 