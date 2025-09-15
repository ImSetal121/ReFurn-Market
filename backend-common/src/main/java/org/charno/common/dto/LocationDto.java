package org.charno.common.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 地址位置信息 DTO
 * 
 * @author charno
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LocationDto {
    
    /**
     * 纬度
     */
    private Double latitude;
    
    /**
     * 经度
     */
    private Double longitude;
    
    /**
     * 格式化地址
     */
    private String formattedAddress;
    
    /**
     * Google Place ID
     */
    private String placeId;
    
    /**
     * 构造函数 - 仅包含坐标
     */
    public LocationDto(Double latitude, Double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }
    
    /**
     * 构造函数 - 包含坐标和地址
     */
    public LocationDto(Double latitude, Double longitude, String formattedAddress) {
        this.latitude = latitude;
        this.longitude = longitude;
        this.formattedAddress = formattedAddress;
    }
} 