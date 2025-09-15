import '../models/sys_role.dart';
import '../utils/request.dart';

/// 系统角色管理API
class SysRoleApi {
  /// 添加角色
  static Future<SysRole?> add(SysRole role) async {
    final data = await HttpRequest.post<Map<String, dynamic>>(
      '/system/role',
      data: role.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysRole.fromJson(data) : null;
  }

  /// 删除角色
  static Future<bool> delete(int id) async {
    await HttpRequest.delete<void>(
      '/system/role/$id',
    );
    return true;
  }

  /// 更新角色
  static Future<SysRole?> update(SysRole role) async {
    final data = await HttpRequest.put<Map<String, dynamic>>(
      '/system/role',
      data: role.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysRole.fromJson(data) : null;
  }

  /// 根据ID获取角色
  static Future<SysRole?> getById(int id) async {
    final data = await HttpRequest.get<Map<String, dynamic>>(
      '/system/role/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysRole.fromJson(data) : null;
  }

  /// 获取角色列表
  static Future<List<SysRole>?> list({
    String? key,
    String? name,
  }) async {
    final queryParams = <String, dynamic>{};
    if (key != null) queryParams['key'] = key;
    if (name != null) queryParams['name'] = name;
    
    final data = await HttpRequest.get<List<dynamic>>(
      '/system/role/list',
      queryParameters: queryParams,
      fromJson: (json) => json as List<dynamic>,
    );
    
    return data?.map((item) => SysRole.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// 分页获取角色列表
  static Future<Map<String, dynamic>?> page({
    int current = 1,
    int size = 10,
    String? key,
    String? name,
  }) async {
    final queryParams = <String, dynamic>{
      'current': current,
      'size': size,
    };
    if (key != null) queryParams['key'] = key;
    if (name != null) queryParams['name'] = name;
    
    final data = await HttpRequest.get<Map<String, dynamic>>(
      '/system/role/page',
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
          SysRole.fromJson(item as Map<String, dynamic>)).toList();
      }
      
      return result;
    }
    
    return null;
  }
}
