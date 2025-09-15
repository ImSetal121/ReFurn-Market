package org.charno.reflip.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.Data;
import org.charno.common.entity.SysUser;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商品实体
 */
@Data
@TableName("rf_product")
public class RfProduct {
    
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;
    
    // 用户信息（不存储在数据库中，仅用于返回结果）
    @TableField(exist = false)
    private SysUser userInfo;
    
    private String name;
    
    private Long categoryId;
    
    private String type;

    private String category;
    
    private BigDecimal price;
    
    private Integer stock;
    
    private String description;
    
    private String imageUrlJson;
    
    private Boolean isAuction;

    private Long warehouseId;

    private Long warehouseStockId;

    private String address;
    
    private Boolean isSelfPickup;

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