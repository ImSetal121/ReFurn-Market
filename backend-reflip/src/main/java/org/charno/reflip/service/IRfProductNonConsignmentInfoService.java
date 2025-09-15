package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductNonConsignmentInfo;
import java.util.List;

/**
 * 非寄卖信息业务接口
 */
public interface IRfProductNonConsignmentInfoService extends IBaseService<RfProductNonConsignmentInfo> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductNonConsignmentInfo> selectPageWithCondition(Page<RfProductNonConsignmentInfo> page, RfProductNonConsignmentInfo condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductNonConsignmentInfo> selectListWithCondition(RfProductNonConsignmentInfo condition);
} 