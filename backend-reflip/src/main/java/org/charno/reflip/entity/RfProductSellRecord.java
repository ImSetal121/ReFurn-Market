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
 * 商品销售记录实体
 */
@Data
@TableName("rf_product_sell_record")
public class RfProductSellRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long productId;
    
    // 商品信息（不存储在数据库中，仅用于返回结果）
    @TableField(exist = false)
    private RfProduct product;
    
    private Long sellerUserId;
    
    private Long buyerUserId;
    
    private BigDecimal finalProductPrice;
    
    private Boolean isAuction;
    
    private Long productWarehouseShipmentId;

    private Long internalLogisticsTaskId;
    
    private Boolean isSelfPickup;
    
    private Long productSelfPickupLogisticsId;
    
    private String buyerReceiptImageUrlJson;
    
    private String sellerReturnImageUrlJson;
    
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