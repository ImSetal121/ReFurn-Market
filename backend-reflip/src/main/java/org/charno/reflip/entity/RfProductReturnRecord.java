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
 * 商品退货记录实体
 */
@Data
@TableName("rf_product_return_record")
public class RfProductReturnRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long productId;
    
    private Long productSellRecordId;
    
    private String returnReasonType;
    
    private String returnReasonDetail;

//    alter table rf_product_return_record
//    add pickup_address varchar;

    private String pickupAddress;

    private Boolean sellerAcceptReturn;

    private String sellerOpinionDetail;
    
    private String auditResult;
    
    private String auditDetail;
    
    private String freightBearer;
    
    private Long freightBearerUserId;
    
    private Boolean needCompensateProduct;
    
    private String compensationBearer;
    
    private Long compensationBearerUserId;
    
    private Boolean isAuction;
    
    private Boolean isUseLogisticsService;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime appointmentPickupTime;
    
    private Long internalLogisticsTaskId;
    
    private String externalLogisticsServiceName;
    
    private String externalLogisticsOrderNumber;
    
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