import '../models/sys_menu.dart';
import '../utils/request.dart';

/// 系统菜单管理API
class SysMenuApi {
  /// 添加菜单
  static Future<SysMenu?> add(SysMenu menu) async {
    final data = await HttpRequest.post<Map<String, dynamic>>(
      '/system/menu',
      data: menu.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysMenu.fromJson(data) : null;
  }

  /// 删除菜单
  static Future<bool> delete(int id) async {
    await HttpRequest.delete<void>(
      '/system/menu/$id',
    );
    return true;
  }

  /// 更新菜单
  static Future<SysMenu?> update(SysMenu menu) async {
    final data = await HttpRequest.put<Map<String, dynamic>>(
      '/system/menu',
      data: menu.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysMenu.fromJson(data) : null;
  }

  /// 根据ID获取菜单
  static Future<SysMenu?> getById(int id) async {
    final data = await HttpRequest.get<Map<String, dynamic>>(
      '/system/menu/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    
    return data != null ? SysMenu.fromJson(data) : null;
  }

  /// 获取菜单列表
  static Future<List<SysMenu>?> list({
    String? menuName,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (menuName != null) queryParams['menuName'] = menuName;
    if (status != null) queryParams['status'] = status;
    
    final data = await HttpRequest.get<List<dynamic>>(
      '/system/menu/list',
      queryParameters: queryParams,
      fromJson: (json) => json as List<dynamic>,
    );
    
    return data?.map((item) => SysMenu.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// 分页获取菜单列表
  static Future<Map<String, dynamic>?> page({
    int current = 1,
    int size = 10,
    String? menuName,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'current': current,
      'size': size,
    };
    if (menuName != null) queryParams['menuName'] = menuName;
    if (status != null) queryParams['status'] = status;
    
    final data = await HttpRequest.get<Map<String, dynamic>>(
      '/system/menu/page',
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
          SysMenu.fromJson(item as Map<String, dynamic>)).toList();
      }
      
      return result;
    }
    
    return null;
  }
}
