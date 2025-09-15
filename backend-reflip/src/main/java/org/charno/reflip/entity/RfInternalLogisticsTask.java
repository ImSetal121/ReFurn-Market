package org.charno.reflip.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 内部物流任务实体
 */
@Data
@TableName("rf_internal_logistics_task")
public class RfInternalLogisticsTask {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long productId;
    
    private Long productSellRecordId;

    private Long productConsignmentRecordId;

    private Long productReturnRecordId;

    private Long productReturnToSellerRecordId;
    
    private String taskType;
    
    private Long logisticsUserId;
    
    private String sourceAddress;
    
    private String sourceAddressImageUrlJson;
    
    private String targetAddress;
    
    private String targetAddressImageUrlJson;

    private String contactPhone;
    
    private BigDecimal logisticsCost;
    
    private String status;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime createTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime updateTime;
    
    @TableLogic
    private Boolean isDelete;
} 