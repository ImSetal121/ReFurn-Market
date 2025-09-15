package org.charno.common.utils;

import com.google.maps.DistanceMatrixApi;
import com.google.maps.GeoApiContext;
import com.google.maps.model.*;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.extern.slf4j.Slf4j;
import org.charno.common.dto.DistanceResult;
import org.charno.common.dto.LocationDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;

import java.util.concurrent.TimeUnit;

/**
 * Google Maps 工具类
 * 
 * @author charno
 */
@Slf4j
@Component
public class GoogleMapsUtils {
    
    @Value("${google.maps.api-key:}")
    private String apiKey;
    
    private GeoApiContext context;
    
    @PostConstruct
    public void init() {
        if (apiKey != null && !apiKey.isEmpty()) {
            context = new GeoApiContext.Builder()
                    .apiKey(apiKey)
                    .connectTimeout(5, TimeUnit.SECONDS)
                    .readTimeout(10, TimeUnit.SECONDS)
                    .writeTimeout(10, TimeUnit.SECONDS)
                    .build();
            log.info("Google Maps API initialized successfully");
        } else {
            log.warn("Google Maps API key not configured");
        }
    }
    
    @PreDestroy
    public void destroy() {
        if (context != null) {
            context.shutdown();
        }
    }
    
    /**
     * 计算两个位置之间的距离和时间
     * 
     * @param origin 起点
     * @param destination 终点
     * @return 距离计算结果
     */
    public DistanceResult calculateDistance(LocationDto origin, LocationDto destination) {
        return calculateDistance(origin, destination, TravelMode.DRIVING);
    }
    
    /**
     * 计算两个位置之间的距离和时间（指定交通方式）
     * 
     * @param origin 起点
     * @param destination 终点
     * @param travelMode 交通方式
     * @return 距离计算结果
     */
    public DistanceResult calculateDistance(LocationDto origin, LocationDto destination, TravelMode travelMode) {
        if (context == null) {
            log.error("Google Maps API not initialized");
            return DistanceResult.error("API_NOT_INITIALIZED", 
                origin.getFormattedAddress(), destination.getFormattedAddress());
        }
        
        if (origin == null || destination == null) {
            log.error("Origin or destination is null");
            return DistanceResult.error("INVALID_REQUEST", null, null);
        }
        
        if (origin.getLatitude() == null || origin.getLongitude() == null ||
            destination.getLatitude() == null || destination.getLongitude() == null) {
            log.error("Origin or destination coordinates are null");
            return DistanceResult.error("INVALID_REQUEST", 
                origin.getFormattedAddress(), destination.getFormattedAddress());
        }
        
        try {
            // 创建起点和终点
            LatLng originLatLng = new LatLng(origin.getLatitude(), origin.getLongitude());
            LatLng destinationLatLng = new LatLng(destination.getLatitude(), destination.getLongitude());
            
            // 调用 Distance Matrix API
            DistanceMatrix matrix = DistanceMatrixApi.newRequest(context)
                    .origins(originLatLng)
                    .destinations(destinationLatLng)
                    .mode(travelMode)
                    .language("zh-CN")
                    .await();
            
            // 解析结果
            if (matrix.rows.length > 0 && matrix.rows[0].elements.length > 0) {
                DistanceMatrixElement element = matrix.rows[0].elements[0];
                
                if (element.status == DistanceMatrixElementStatus.OK) {
                    DistanceResult result = new DistanceResult();
                    result.setDistanceInMeters(element.distance.inMeters);
                    result.setDistanceText(element.distance.humanReadable);
                    result.setDurationInSeconds(element.duration.inSeconds);
                    result.setDurationText(element.duration.humanReadable);
                    result.setOriginAddress(origin.getFormattedAddress());
                    result.setDestinationAddress(destination.getFormattedAddress());
                    result.setStatus("OK");
                    
                    log.debug("Distance calculated: {} from {} to {}", 
                        element.distance.humanReadable, 
                        origin.getFormattedAddress(), 
                        destination.getFormattedAddress());
                    
                    return result;
                } else {
                    log.warn("Distance calculation failed with status: {}", element.status);
                    return DistanceResult.error(element.status.toString(), 
                        origin.getFormattedAddress(), destination.getFormattedAddress());
                }
            } else {
                log.warn("No results returned from Distance Matrix API");
                return DistanceResult.error("ZERO_RESULTS", 
                    origin.getFormattedAddress(), destination.getFormattedAddress());
            }
            
        } catch (Exception e) {
            log.error("Error calculating distance between {} and {}: {}", 
                origin.getFormattedAddress(), destination.getFormattedAddress(), e.getMessage(), e);
            return DistanceResult.error("UNKNOWN_ERROR", 
                origin.getFormattedAddress(), destination.getFormattedAddress());
        }
    }
    
    /**
     * 计算直线距离（Haversine 公式）
     * 
     * @param origin 起点
     * @param destination 终点
     * @return 直线距离（米）
     */
    public double calculateStraightLineDistance(LocationDto origin, LocationDto destination) {
        if (origin == null || destination == null ||
            origin.getLatitude() == null || origin.getLongitude() == null ||
            destination.getLatitude() == null || destination.getLongitude() == null) {
            return 0.0;
        }
        
        return calculateStraightLineDistance(
            origin.getLatitude(), origin.getLongitude(),
            destination.getLatitude(), destination.getLongitude()
        );
    }
    
    /**
     * 计算直线距离（Haversine 公式）
     * 
     * @param lat1 起点纬度
     * @param lon1 起点经度
     * @param lat2 终点纬度
     * @param lon2 终点经度
     * @return 直线距离（米）
     */
    public double calculateStraightLineDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371000; // 地球半径，单位：米
        
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c;
    }
    
    /**
     * 检查 Google Maps API 是否可用
     * 
     * @return true 如果 API 可用
     */
    public boolean isApiAvailable() {
        return context != null && apiKey != null && !apiKey.isEmpty();
    }
    
    /**
     * 从 JSON 字符串解析位置信息
     * 
     * @param addressJson JSON 格式的地址字符串
     * @return LocationDto 对象
     */
    public LocationDto parseLocationFromJson(String addressJson) {
        try {
            if (addressJson == null || addressJson.trim().isEmpty()) {
                return null;
            }
            
            JSONObject jsonObject = JSON.parseObject(addressJson);
            
            Double latitude = jsonObject.getDouble("latitude");
            Double longitude = jsonObject.getDouble("longitude");
            String formattedAddress = jsonObject.getString("formattedAddress");
            String placeId = jsonObject.getString("placeId");
            
            if (latitude != null && longitude != null) {
                LocationDto location = new LocationDto();
                location.setLatitude(latitude);
                location.setLongitude(longitude);
                location.setFormattedAddress(formattedAddress);
                location.setPlaceId(placeId);
                return location;
            }
            
            return null;
        } catch (Exception e) {
            log.error("Error parsing location from JSON: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * 将位置信息转换为 JSON 字符串
     * 
     * @param location 位置信息
     * @return JSON 字符串
     */
    public String locationToJson(LocationDto location) {
        try {
            if (location == null) {
                return null;
            }
            return JSON.toJSONString(location);
        } catch (Exception e) {
            log.error("Error converting location to JSON: {}", e.getMessage());
            return null;
        }
    }
} 