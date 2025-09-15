package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductSellRecord;
import java.util.List;

/**
 * 商品销售记录业务接口
 */
public interface IRfProductSellRecordService extends IBaseService<RfProductSellRecord> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductSellRecord> selectPageWithCondition(Page<RfProductSellRecord> page, RfProductSellRecord condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductSellRecord> selectListWithCondition(RfProductSellRecord condition);
} 