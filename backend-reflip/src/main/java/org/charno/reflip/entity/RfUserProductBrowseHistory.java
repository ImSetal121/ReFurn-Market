package org.charno.reflip.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.Data;
import org.charno.common.entity.SysUser;
import java.time.LocalDateTime;

/**
 * 用户商品浏览记录实体
 */
@Data
@TableName("rf_user_product_browse_history")
public class RfUserProductBrowseHistory {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    // 用户信息（不存储在数据库中，仅用于返回结果）
    @TableField(exist = false)
    private SysUser userInfo;

    private Long productId;

    // 商品信息（不存储在数据库中，仅用于返回结果）
    @TableField(exist = false)
    private RfProduct productInfo;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime browseTime;

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