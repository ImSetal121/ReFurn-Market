package org.charno.system.controller;

import org.charno.common.core.R;
import org.charno.common.dto.DistanceResult;
import org.charno.common.dto.LocationDto;
import org.charno.common.utils.GoogleMapsUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 距离计算控制器
 * 
 * @author charno
 */
@RestController
@RequestMapping("/system/distance")
public class DistanceController {
    
    @Autowired
    private GoogleMapsUtils googleMapsUtils;
    
    /**
     * 计算两个位置之间的距离
     */
    @PostMapping("/calculate")
    public R<?> calculateDistance(@RequestBody DistanceRequest request) {
        try {
            if (request.getOrigin() == null || request.getDestination() == null) {
                return R.fail("起点和终点不能为空");
            }
            
            LocationDto origin = request.getOrigin();
            LocationDto destination = request.getDestination();
            
            // 验证坐标
            if (origin.getLatitude() == null || origin.getLongitude() == null ||
                destination.getLatitude() == null || destination.getLongitude() == null) {
                return R.fail("坐标信息不完整");
            }
            
            DistanceResult result = googleMapsUtils.calculateDistance(origin, destination);
            return R.ok(result);
            
        } catch (Exception e) {
            return R.fail("计算距离失败: " + e.getMessage());
        }
    }
    
    /**
     * 计算直线距离
     */
    @PostMapping("/straight-line")
    public R<?> calculateStraightLineDistance(@RequestBody DistanceRequest request) {
        try {
            if (request.getOrigin() == null || request.getDestination() == null) {
                return R.fail("起点和终点不能为空");
            }
            
            LocationDto origin = request.getOrigin();
            LocationDto destination = request.getDestination();
            
            double distance = googleMapsUtils.calculateStraightLineDistance(origin, destination);
            
            return R.ok(new StraightLineDistanceResult(distance, distance / 1000.0));
            
        } catch (Exception e) {
            return R.fail("计算直线距离失败: " + e.getMessage());
        }
    }
    
    /**
     * 解析 JSON 地址
     */
    @PostMapping("/parse-location")
    public R<?> parseLocation(@RequestBody String addressJson) {
        try {
            LocationDto location = googleMapsUtils.parseLocationFromJson(addressJson);
            if (location != null) {
                return R.ok(location);
            } else {
                return R.fail("地址解析失败");
            }
        } catch (Exception e) {
            return R.fail("地址解析失败: " + e.getMessage());
        }
    }
    
    /**
     * 检查 API 状态
     */
    @GetMapping("/api-status")
    public R<?> getApiStatus() {
        boolean available = googleMapsUtils.isApiAvailable();
        return R.ok(new ApiStatusResult(available, available ? "API 可用" : "API 不可用或未配置"));
    }
    
    /**
     * 距离计算请求
     */
    public static class DistanceRequest {
        private LocationDto origin;
        private LocationDto destination;
        
        public LocationDto getOrigin() {
            return origin;
        }
        
        public void setOrigin(LocationDto origin) {
            this.origin = origin;
        }
        
        public LocationDto getDestination() {
            return destination;
        }
        
        public void setDestination(LocationDto destination) {
            this.destination = destination;
        }
    }
    
    /**
     * 直线距离结果
     */
    public static class StraightLineDistanceResult {
        private double distanceInMeters;
        private double distanceInKilometers;
        
        public StraightLineDistanceResult(double distanceInMeters, double distanceInKilometers) {
            this.distanceInMeters = distanceInMeters;
            this.distanceInKilometers = distanceInKilometers;
        }
        
        public double getDistanceInMeters() {
            return distanceInMeters;
        }
        
        public void setDistanceInMeters(double distanceInMeters) {
            this.distanceInMeters = distanceInMeters;
        }
        
        public double getDistanceInKilometers() {
            return distanceInKilometers;
        }
        
        public void setDistanceInKilometers(double distanceInKilometers) {
            this.distanceInKilometers = distanceInKilometers;
        }
    }
    
    /**
     * API 状态结果
     */
    public static class ApiStatusResult {
        private boolean available;
        private String message;
        
        public ApiStatusResult(boolean available, String message) {
            this.available = available;
            this.message = message;
        }
        
        public boolean isAvailable() {
            return available;
        }
        
        public void setAvailable(boolean available) {
            this.available = available;
        }
        
        public String getMessage() {
            return message;
        }
        
        public void setMessage(String message) {
            this.message = message;
        }
    }
} 