import 'package:flutter/material.dart';
import '../utils/request.dart';

/// Google Maps 配置数据模型
class GoogleMapsConfig {
  final String apiKey;
  final double defaultLatitude;
  final double defaultLongitude;
  final int defaultZoom;
  final bool enabled;

  GoogleMapsConfig({
    required this.apiKey,
    required this.defaultLatitude,
    required this.defaultLongitude,
    required this.defaultZoom,
    required this.enabled,
  });

  factory GoogleMapsConfig.fromJson(Map<String, dynamic> json) {
    final defaultCenter = json['defaultCenter'] as Map<String, dynamic>;
    return GoogleMapsConfig(
      apiKey: json['apiKey'] as String,
      defaultLatitude: defaultCenter['latitude'] as double,
      defaultLongitude: defaultCenter['longitude'] as double,
      defaultZoom: json['defaultZoom'] as int,
      enabled: json['enabled'] as bool,
    );
  }
}

/// 地址信息数据模型
class AddressInfo {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String? placeId;

  AddressInfo({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.placeId,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      formattedAddress: json['formattedAddress'] as String,
      placeId: json['placeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
      'placeId': placeId,
    };
  }

  /// 转换为JSON字符串
  String toJsonString() {
    return '''
{
  "latitude":$latitude,
  "longitude":$longitude,
  "formattedAddress":"$formattedAddress",
  "placeId":"${placeId ?? ''}"
}''';
  }
}

/// Google Maps 服务类
class GoogleMapsService {
  static GoogleMapsConfig? _config;

  /// 获取Google Maps配置
  static Future<GoogleMapsConfig?> getConfig() async {
    if (_config != null) return _config;

    try {
      final data = await HttpRequest.get<Map<String, dynamic>>(
        '/system/config/google-maps',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (data != null) {
        _config = GoogleMapsConfig.fromJson(data);
        return _config;
      }
    } catch (e) {
      debugPrint('Failed to load Google Maps config: $e');
    }

    return null;
  }

  /// 检查Google Maps是否可用
  static Future<bool> isAvailable() async {
    final config = await getConfig();
    return config?.enabled == true && config?.apiKey.isNotEmpty == true;
  }

  /// 清除缓存的配置
  static void clearCache() {
    _config = null;
  }
}
