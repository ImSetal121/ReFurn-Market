package org.charno.reflip.dto;

import lombok.Data;

@Data
public class AcceptTaskRequestDTO {
    private Long taskId;         // 任务ID
    private Long courierId;      // 快递员ID
    private String taskType;     // 任务类型（取货/送达）
} 