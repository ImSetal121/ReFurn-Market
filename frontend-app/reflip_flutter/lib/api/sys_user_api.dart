import '../models/sys_user.dart';
import '../utils/request.dart';

/// 系统用户管理API
class SysUserApi {
  /// 添加用户
  static Future<SysUser?> add(SysUser user) async {
    final data = await HttpRequest.post<Map<String, dynamic>>(
      '/system/user',
      data: user.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysUser.fromJson(data) : null;
  }

  /// 删除用户
  static Future<bool> delete(int id) async {
    await HttpRequest.delete<void>(
      '/system/user/$id',
    );
    return true;
  }

  /// 更新用户
  static Future<SysUser?> update(SysUser user) async {
    final data = await HttpRequest.put<Map<String, dynamic>>(
      '/system/user',
      data: user.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysUser.fromJson(data) : null;
  }

  /// 根据ID获取用户
  static Future<SysUser?> getById(int id) async {
    final data = await HttpRequest.get<Map<String, dynamic>>(
      '/system/user/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysUser.fromJson(data) : null;
  }

  /// 获取用户列表
  static Future<List<SysUser>?> list({
    String? username,
    String? nickname,
    String? email,
    String? phoneNumber,
  }) async {
    final queryParams = <String, dynamic>{};
    if (username != null) queryParams['username'] = username;
    if (nickname != null) queryParams['nickname'] = nickname;
    if (email != null) queryParams['email'] = email;
    if (phoneNumber != null) queryParams['phoneNumber'] = phoneNumber;
    
    final data = await HttpRequest.get<List<dynamic>>(
      '/system/user/list',
      queryParameters: queryParams,
      fromJson: (json) => json as List<dynamic>,
    );
    
    return data?.map((item) => SysUser.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// 分页获取用户列表
  static Future<Map<String, dynamic>?> page({
    int current = 1,
    int size = 10,
    String? username,
    String? nickname,
    String? email,
    String? phoneNumber,
  }) async {
    final queryParams = <String, dynamic>{
      'current': current,
      'size': size,
    };
    if (username != null) queryParams['username'] = username;
    if (nickname != null) queryParams['nickname'] = nickname;
    if (email != null) queryParams['email'] = email;
    if (phoneNumber != null) queryParams['phoneNumber'] = phoneNumber;
    
    final data = await HttpRequest.get<Map<String, dynamic>>(
      '/system/user/page',
      queryParameters: queryParams,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    if (data != null) {
      final result = <String, dynamic>{};
      result['total'] = data['total'] as int;
      result['size'] = data['size'] as int;
      result['current'] = data['current'] as int;
      
      if (data['records'] != null) {
        final records = data['records'] as List<dynamic>;
        result['records'] = records.map((item) => 
          SysUser.fromJson(item as Map<String, dynamic>)).toList();
      }
      
      return result;
    }
    
    return null;
  }
}
