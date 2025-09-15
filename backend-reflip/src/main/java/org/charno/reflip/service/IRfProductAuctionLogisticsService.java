package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfProductAuctionLogistics;
import java.util.List;

/**
 * 商品拍卖物流业务接口
 */
public interface IRfProductAuctionLogisticsService extends IBaseService<RfProductAuctionLogistics> {
    
    /**
     * 分页条件查询
     */
    Page<RfProductAuctionLogistics> selectPageWithCondition(Page<RfProductAuctionLogistics> page, RfProductAuctionLogistics condition);
    
    /**
     * 不分页条件查询
     */
    List<RfProductAuctionLogistics> selectListWithCondition(RfProductAuctionLogistics condition);
} 