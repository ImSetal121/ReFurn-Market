import '../models/user_address.dart';
import '../utils/request.dart';

class UserAddressApi {
  static const String _basePath = '/api/user/address';

  /// 获取用户地址列表
  static Future<List<UserAddress>> getUserAddressList() async {
    try {
      final response = await HttpRequest.get<List<dynamic>>(
        '$_basePath/list',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response != null) {
        return response.map((json) => UserAddress.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get address list error: $e');
      rethrow;
    }
  }

  /// 获取默认地址
  static Future<UserAddress?> getDefaultAddress() async {
    try {
      final response = await HttpRequest.get<Map<String, dynamic>>(
        '$_basePath/default',
        fromJson: (data) => data as Map<String, dynamic>?,
      );

      return response != null ? UserAddress.fromJson(response) : null;
    } catch (e) {
      print('Get default address error: $e');
      rethrow;
    }
  }

  /// 根据ID获取地址详情
  static Future<UserAddress?> getAddressById(int id) async {
    try {
      final response = await HttpRequest.get<Map<String, dynamic>>(
        '$_basePath/$id',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      return response != null ? UserAddress.fromJson(response) : null;
    } catch (e) {
      print('Get address details error: $e');
      rethrow;
    }
  }

  /// 添加地址
  static Future<bool> addAddress(UserAddress address) async {
    try {
      final response = await HttpRequest.post<bool>(
        _basePath,
        data: address.toJson(),
        fromJson: (data) => data as bool,
      );

      return response ?? false;
    } catch (e) {
      print('Add address error: $e');
      rethrow;
    }
  }

  /// 更新地址
  static Future<bool> updateAddress(UserAddress address) async {
    try {
      final response = await HttpRequest.put<bool>(
        _basePath,
        data: address.toJson(),
        fromJson: (data) => data as bool,
      );

      return response ?? false;
    } catch (e) {
      print('Update address error: $e');
      rethrow;
    }
  }

  /// 删除地址
  static Future<bool> deleteAddress(int id) async {
    try {
      final response = await HttpRequest.delete<bool>(
        '$_basePath/$id',
        fromJson: (data) => data as bool,
      );

      return response ?? false;
    } catch (e) {
      print('Delete address error: $e');
      rethrow;
    }
  }

  /// 设置默认地址
  static Future<bool> setDefaultAddress(int id) async {
    try {
      final response = await HttpRequest.put<bool>(
        '$_basePath/$id/default',
        fromJson: (data) => data as bool,
      );

      return response ?? false;
    } catch (e) {
      print('Set default address error: $e');
      rethrow;
    }
  }
}
