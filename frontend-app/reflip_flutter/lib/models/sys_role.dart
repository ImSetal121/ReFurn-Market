/// 系统角色实体
class SysRole {
  final int? id;
  final String? roleName;
  final String? roleKey;
  final int? roleSort;
  final String? dataScope;
  final String? status;
  final String? createBy;
  final String? createTime;
  final String? updateBy;
  final String? updateTime;
  final String? remark;

  SysRole({
    this.id,
    this.roleName,
    this.roleKey,
    this.roleSort,
    this.dataScope,
    this.status,
    this.createBy,
    this.createTime,
    this.updateBy,
    this.updateTime,
    this.remark,
  });

  factory SysRole.fromJson(Map<String, dynamic> json) {
    return SysRole(
      id: json['id'] as int?,
      roleName: json['roleName'] as String?,
      roleKey: json['roleKey'] as String?,
      roleSort: json['roleSort'] as int?,
      dataScope: json['dataScope'] as String?,
      status: json['status'] as String?,
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
      if (roleName != null) 'roleName': roleName,
      if (roleKey != null) 'roleKey': roleKey,
      if (roleSort != null) 'roleSort': roleSort,
      if (dataScope != null) 'dataScope': dataScope,
      if (status != null) 'status': status,
      if (createBy != null) 'createBy': createBy,
      if (createTime != null) 'createTime': createTime,
      if (updateBy != null) 'updateBy': updateBy,
      if (updateTime != null) 'updateTime': updateTime,
      if (remark != null) 'remark': remark,
    };
  }
}
