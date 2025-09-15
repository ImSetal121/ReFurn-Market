package org.charno.reflip.dto;

import lombok.Data;
import java.util.Map;

@Data
public class DeliveryRequestDTO {
    private Long taskId;                        // 任务ID
    private Map<String, String> imageUrls;      // 图片URL集合
    private String remark;                      // 备注信息
} 