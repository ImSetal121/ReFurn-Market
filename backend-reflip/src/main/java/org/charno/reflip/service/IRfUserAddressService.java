package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfUserAddress;
import java.util.List;

/**
 * 用户地址业务接口
 */
public interface IRfUserAddressService extends IBaseService<RfUserAddress> {
    
    /**
     * 分页条件查询
     */
    Page<RfUserAddress> selectPageWithCondition(Page<RfUserAddress> page, RfUserAddress condition);
    
    /**
     * 不分页条件查询
     */
    List<RfUserAddress> selectListWithCondition(RfUserAddress condition);
} 