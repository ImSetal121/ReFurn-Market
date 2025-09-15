/// 系统菜单实体
class SysMenu {
  final int? id;
  final String? menuName;
  final int? parentId;
  final int? orderNum;
  final String? path;
  final String? component;
  final String? query;
  final String? routeName;
  final int? isFrame;
  final int? isCache;
  final String? menuType;
  final String? visible;
  final String? status;
  final String? perms;
  final String? icon;
  final String? createBy;
  final String? createTime;
  final String? updateBy;
  final String? updateTime;
  final String? remark;

  SysMenu({
    this.id,
    this.menuName,
    this.parentId,
    this.orderNum,
    this.path,
    this.component,
    this.query,
    this.routeName,
    this.isFrame,
    this.isCache,
    this.menuType,
    this.visible,
    this.status,
    this.perms,
    this.icon,
    this.createBy,
    this.createTime,
    this.updateBy,
    this.updateTime,
    this.remark,
  });

  factory SysMenu.fromJson(Map<String, dynamic> json) {
    return SysMenu(
      id: json['id'] as int?,
      menuName: json['menuName'] as String?,
      parentId: json['parentId'] as int?,
      orderNum: json['orderNum'] as int?,
      path: json['path'] as String?,
      component: json['component'] as String?,
      query: json['query'] as String?,
      routeName: json['routeName'] as String?,
      isFrame: json['isFrame'] as int?,
      isCache: json['isCache'] as int?,
      menuType: json['menuType'] as String?,
      visible: json['visible'] as String?,
      status: json['status'] as String?,
      perms: json['perms'] as String?,
      icon: json['icon'] as String?,
      createBy: json['createBy'] as String?,
      createTime: json['createTime'] as String?,
      updateBy: json['updateBy'] as String?,
      updateTime: json['updateTime'] as String?,
      remark: json['remark'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (menuName != null) 'menuName': menuName,
      if (parentId != null) 'parentId': parentId,
      if (orderNum != null) 'orderNum': orderNum,
      if (path != null) 'path': path,
      if (component != null) 'component': component,
      if (query != null) 'query': query,
      if (routeName != null) 'routeName': routeName,
      if (isFrame != null) 'isFrame': isFrame,
      if (isCache != null) 'isCache': isCache,
      if (menuType != null) 'menuType': menuType,
      if (visible != null) 'visible': visible,
      if (status != null) 'status': status,
      if (perms != null) 'perms': perms,
      if (icon != null) 'icon': icon,
      if (createBy != null) 'createBy': createBy,
      if (createTime != null) 'createTime': createTime,
      if (updateBy != null) 'updateBy': updateBy,
      if (updateTime != null) 'updateTime': updateTime,
      if (remark != null) 'remark': remark,
    };
  }
}
