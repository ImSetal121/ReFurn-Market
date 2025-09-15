package org.charno.reflip.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 寄卖上架请求DTO
 */
@Data
public class ConsignmentListingRequest {
    
    // 商品基本信息
    private String name;
    private Long categoryId;
    private String type;
    private String category;
    private BigDecimal price;
    private Integer stock;
    private String description;
    private String imageUrlJson;
    private String address; // 取货地址
    
    // 物流信息
    private String pickupAddress;
    
    @JsonFormat(pattern = "yyyy-MM-dd")
    @JsonDeserialize(using = LocalDateDeserializer.class)
    private LocalDate appointmentPickupDate;
    
    private String appointmentPickupTimePeriod;
    private String notes; // 备注信息
    
    // 联系信息
    private String receiverName;
    private String receiverPhone;
} 