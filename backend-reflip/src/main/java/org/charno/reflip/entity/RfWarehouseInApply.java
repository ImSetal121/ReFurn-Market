package org.charno.reflip.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 仓库入库申请实体
 */
@Data
@TableName("rf_warehouse_in_apply")
public class RfWarehouseInApply {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long warehouseId;
    
    private Long productId;

    private Long productSellRecordId;

    private Long productConsignmentRecordId;

    private Long productReturnRecordId;

    private Long productReturnToSellerRecordId;
    
    private String source;
    
    private Integer applyQuantity;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime applyTime;
    
    private String productImageUrlJson;
    
    private String auditResult;
    
    private String auditDetail;
    
    private String status;
    
    private Long warehouseInId;
    
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