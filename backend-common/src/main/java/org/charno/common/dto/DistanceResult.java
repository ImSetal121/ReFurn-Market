package org.charno.common.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 距离计算结果 DTO
 * 
 * @author charno
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DistanceResult {
    
    /**
     * 距离（米）
     */
    private Long distanceInMeters;
    
    /**
     * 距离文本描述（如：5.2 km）
     */
    private String distanceText;
    
    /**
     * 持续时间（秒）
     */
    private Long durationInSeconds;
    
    /**
     * 持续时间文本描述（如：15 分钟）
     */
    private String durationText;
    
    /**
     * 起点地址
     */
    private String originAddress;
    
    /**
     * 终点地址
     */
    private String destinationAddress;
    
    /**
     * 状态（OK, NOT_FOUND, ZERO_RESULTS等）
     */
    private String status;
    
    /**
     * 构造函数 - 仅包含距离和时间
     */
    public DistanceResult(Long distanceInMeters, String distanceText, Long durationInSeconds, String durationText) {
        this.distanceInMeters = distanceInMeters;
        this.distanceText = distanceText;
        this.durationInSeconds = durationInSeconds;
        this.durationText = durationText;
        this.status = "OK";
    }
    
    /**
     * 创建错误结果
     */
    public static DistanceResult error(String status, String originAddress, String destinationAddress) {
        DistanceResult result = new DistanceResult();
        result.setStatus(status);
        result.setOriginAddress(originAddress);
        result.setDestinationAddress(destinationAddress);
        return result;
    }
    
    /**
     * 获取距离（公里）
     */
    public Double getDistanceInKilometers() {
        return distanceInMeters != null ? distanceInMeters / 1000.0 : null;
    }
    
    /**
     * 获取持续时间（分钟）
     */
    public Double getDurationInMinutes() {
        return durationInSeconds != null ? durationInSeconds / 60.0 : null;
    }
} 