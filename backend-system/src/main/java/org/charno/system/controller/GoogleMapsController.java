package org.charno.system.controller;

import org.charno.common.core.R;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 谷歌地图配置控制器
 * 
 * @author charno
 */
@RestController
@RequestMapping("/system/config/google-maps")
public class GoogleMapsController {
    
    @Value("${google.maps.api-key:}")
    private String apiKey;
    
    @Value("${google.maps.default-center.latitude:22.3193}")
    private Double defaultLatitude;
    
    @Value("${google.maps.default-center.longitude:114.1694}")
    private Double defaultLongitude;
    
    @Value("${google.maps.default-zoom:12}")
    private Integer defaultZoom;
    
    /**
     * 获取谷歌地图配置
     */
    @GetMapping
    public R<?> getGoogleMapsConfig() {
        Map<String, Object> config = new HashMap<>();
        config.put("apiKey", apiKey);
        config.put("defaultCenter", Map.of(
            "latitude", defaultLatitude,
            "longitude", defaultLongitude
        ));
        config.put("defaultZoom", defaultZoom);
        config.put("enabled", !apiKey.isEmpty());
        
        return R.ok(config);
    }
} 