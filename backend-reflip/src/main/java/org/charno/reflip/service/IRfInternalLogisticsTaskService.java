package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfInternalLogisticsTask;
import java.util.List;

/**
 * 内部物流任务业务接口
 */
public interface IRfInternalLogisticsTaskService extends IBaseService<RfInternalLogisticsTask> {
    
    /**
     * 分页条件查询
     */
    Page<RfInternalLogisticsTask> selectPageWithCondition(Page<RfInternalLogisticsTask> page, RfInternalLogisticsTask condition);
    
    /**
     * 不分页条件查询
     */
    List<RfInternalLogisticsTask> selectListWithCondition(RfInternalLogisticsTask condition);
} 