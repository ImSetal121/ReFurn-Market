# Google Maps 工具类使用示例

## 概述

`GoogleMapsUtils` 是一个用于调用 Google Maps API 计算地理位置距离的工具类，支持路径距离和直线距离计算。

## 功能特性

- ✅ 计算两个位置之间的驾车路径距离和时间
- ✅ 支持多种交通方式（驾车、步行、骑行、公交）
- ✅ 计算直线距离（Haversine 公式）
- ✅ JSON 地址解析和转换
- ✅ API 状态检查
- ✅ 完善的错误处理和日志记录

## 配置

在 `application.yaml` 中配置 Google Maps API 密钥：

```yaml
google:
  maps:
    api-key: ${GOOGLE_MAPS_API_KEY:YOUR_API_KEY}
```

## 使用方法

### 1. 注入工具类

```java
@Autowired
private GoogleMapsUtils googleMapsUtils;
```

### 2. 创建位置对象

```java
// 起点：旧金山
LocationDto origin = new LocationDto(
    37.770231227984155, 
    -122.41060617607945, 
    "450 10th St, San Francisco, CA 94103美国"
);

// 终点：另一个位置
LocationDto destination = new LocationDto(
    37.7749, 
    -122.4194, 
    "San Francisco, CA, USA"
);
```

### 3. 计算路径距离

```java
// 默认驾车路径
DistanceResult result = googleMapsUtils.calculateDistance(origin, destination);

// 指定交通方式
DistanceResult walkingResult = googleMapsUtils.calculateDistance(
    origin, destination, TravelMode.WALKING
);

if ("OK".equals(result.getStatus())) {
    System.out.println("距离: " + result.getDistanceText());
    System.out.println("时间: " + result.getDurationText());
    System.out.println("距离(米): " + result.getDistanceInMeters());
    System.out.println("距离(公里): " + result.getDistanceInKilometers());
}
```

### 4. 计算直线距离

```java
double straightDistance = googleMapsUtils.calculateStraightLineDistance(origin, destination);
System.out.println("直线距离: " + (straightDistance / 1000.0) + " 公里");
```

### 5. JSON 地址解析

```java
String addressJson = """
{
  "latitude": 37.770231227984155,
  "longitude": -122.41060617607945,
  "formattedAddress": "450 10th St, San Francisco, CA 94103美国",
  "placeId": "ChIJgw2Zzih-j4ARbBBlXwrvToc"
}
""";

LocationDto location = googleMapsUtils.parseLocationFromJson(addressJson);
```

### 6. 位置转 JSON

```java
String json = googleMapsUtils.locationToJson(location);
```

## API 接口

### 1. 计算距离

**POST** `/system/distance/calculate`

请求体：
```json
{
  "origin": {
    "latitude": 37.770231227984155,
    "longitude": -122.41060617607945,
    "formattedAddress": "450 10th St, San Francisco, CA 94103美国"
  },
  "destination": {
    "latitude": 37.7749,
    "longitude": -122.4194,
    "formattedAddress": "San Francisco, CA, USA"
  }
}
```

响应：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "distanceInMeters": 1200,
    "distanceText": "1.2 km",
    "durationInSeconds": 240,
    "durationText": "4 分钟",
    "originAddress": "450 10th St, San Francisco, CA 94103美国",
    "destinationAddress": "San Francisco, CA, USA",
    "status": "OK"
  }
}
```

### 2. 计算直线距离

**POST** `/system/distance/straight-line`

### 3. 解析地址

**POST** `/system/distance/parse-location`

### 4. API 状态检查

**GET** `/system/distance/api-status`

## 交通方式

- `TravelMode.DRIVING` - 驾车（默认）
- `TravelMode.WALKING` - 步行
- `TravelMode.BICYCLING` - 骑行
- `TravelMode.TRANSIT` - 公共交通

## 错误处理

工具类会返回不同的状态码：

- `OK` - 成功
- `NOT_FOUND` - 未找到路径
- `ZERO_RESULTS` - 无结果
- `OVER_QUERY_LIMIT` - 超出查询限制
- `REQUEST_DENIED` - 请求被拒绝
- `INVALID_REQUEST` - 无效请求
- `UNKNOWN_ERROR` - 未知错误
- `API_NOT_INITIALIZED` - API 未初始化

## 注意事项

1. **API 配额**: Google Maps API 有每日免费配额，超出后会收费
2. **网络延迟**: API 调用需要网络请求，建议添加超时处理
3. **缓存**: 对于频繁查询的路径，建议实现缓存机制
4. **错误处理**: 始终检查返回结果的状态码

## 示例用例

### 仓库管理场景

```java
// 计算用户到最近仓库的距离
public LocationDto findNearestWarehouse(LocationDto userLocation, List<LocationDto> warehouses) {
    LocationDto nearest = null;
    double minDistance = Double.MAX_VALUE;
    
    for (LocationDto warehouse : warehouses) {
        double distance = googleMapsUtils.calculateStraightLineDistance(userLocation, warehouse);
        if (distance < minDistance) {
            minDistance = distance;
            nearest = warehouse;
        }
    }
    
    return nearest;
}
```

### 物流配送场景

```java
// 计算配送路径和时间
public DistanceResult calculateDeliveryDistance(String warehouseAddress, String deliveryAddress) {
    LocationDto warehouse = googleMapsUtils.parseLocationFromJson(warehouseAddress);
    LocationDto delivery = googleMapsUtils.parseLocationFromJson(deliveryAddress);
    
    return googleMapsUtils.calculateDistance(warehouse, delivery, TravelMode.DRIVING);
}
``` 