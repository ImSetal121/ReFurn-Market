package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductReturnRecord;
import java.util.List;

/**
 * 商品退货记录业务接口
 */
public interface IRfProductReturnRecordService extends IBaseService<RfProductReturnRecord> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductReturnRecord> selectPageWithCondition(Page<RfProductReturnRecord> page, RfProductReturnRecord condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductReturnRecord> selectListWithCondition(RfProductReturnRecord condition);
    
    /**
     * 根据商品销售记录ID获取退货记录
     */
    RfProductReturnRecord getByProductSellRecordId(Long productSellRecordId);
} 