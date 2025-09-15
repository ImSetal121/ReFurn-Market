package org.charno.reflip.dto;

import lombok.Data;
import java.util.List;

/**
 * 确认收货请求DTO
 */
@Data
public class ConfirmReceiptRequest {
    /**
     * 订单ID
     */
    private String orderId;
    
    /**
     * 评价内容
     */
    private String comment;
    
    /**
     * 收货凭证图片列表
     */
    private List<String> receiptImages;
} 