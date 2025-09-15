package org.charno.reflip.dto;

import lombok.Data;

/**
 * 审批退货请求DTO
 */
@Data
public class AuditReturnRequestDto {
    
    /**
     * 退货记录ID
     */
    private Long returnRecordId;
    
    /**
     * 审核结果：APPROVED-同意，REJECTED-拒绝
     */
    private String auditResult;
    
    /**
     * 审核详细说明
     */
    private String auditDetail;
    
    /**
     * 运费承担方：SELLER-卖方，BUYER-买方，PLATFORM-平台
     */
    private String freightBearer;
    
    /**
     * 是否需要赔偿商品
     */
    private Boolean needCompensateProduct;
    
    /**
     * 赔偿承担方：SELLER-卖方，BUYER-买方，PLATFORM-平台
     */
    private String compensationBearer;
} 