package org.charno.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户Stripe Express账户信息实体
 */
@Data
@TableName("sys_user_stripe_account")
public class SysUserStripeAccount {
    
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;
    
    private String stripeAccountId;
    
    /**
     * 账户状态: pending, active, restricted
     */
    private String accountStatus;
    
    /**
     * 验证状态: unverified, pending, verified
     */
    private String verificationStatus;
    
    /**
     * 账户能力状态JSON: 存储card_payments, transfers等能力的状态
     */
    private String capabilitiesJson;
    
    /**
     * 待完成要求JSON: 存储Stripe返回的requirements信息
     */
    private String requirementsJson;
    
    /**
     * 账户设置链接
     */
    private String accountLinkUrl;
    
    /**
     * 链接过期时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime linkExpiresAt;
    
    /**
     * 是否可以接收付款
     */
    private Boolean canReceivePayments;
    
    /**
     * 是否可以进行转账
     */
    private Boolean canMakeTransfers;
    
    /**
     * 最后同步时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @JsonDeserialize(using = LocalDateTimeDeserializer.class)
    @JsonSerialize(using = LocalDateTimeSerializer.class)
    private LocalDateTime lastSyncTime;
    
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