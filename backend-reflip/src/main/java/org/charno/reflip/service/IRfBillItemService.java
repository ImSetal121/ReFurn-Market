package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfBillItem;
import java.util.List;

/**
 * 账单项业务接口
 */
public interface IRfBillItemService extends IBaseService<RfBillItem> {
    
    /**
     * 分页条件查询
     */
    Page<RfBillItem> selectPageWithCondition(Page<RfBillItem> page, RfBillItem condition);
    
    /**
     * 不分页条件查询
     */
    List<RfBillItem> selectListWithCondition(RfBillItem condition);
} 