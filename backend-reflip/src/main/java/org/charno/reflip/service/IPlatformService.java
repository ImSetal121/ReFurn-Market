package org.charno.reflip.service;

import org.charno.reflip.dto.AuditReturnRequestDto;

/**
 * 平台管理服务接口
 */
public interface IPlatformService {
    
    /**
     * 审批退货申请
     * @param auditRequest 审批请求数据
     * @return 审批结果
     */
    boolean auditReturnRequest(AuditReturnRequestDto auditRequest);
} 