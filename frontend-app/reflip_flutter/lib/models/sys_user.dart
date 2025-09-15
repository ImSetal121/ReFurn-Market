/// 系统用户实体
class SysUser {
  final int? id;
  final String? username;
  final String? password;
  final int? roleId;
  final String? clientRole;
  final String? wechatOpenId;
  final String? avatar;
  final String? nickname;
  final String? email;
  final String? phoneNumber;
  final String? sex;
  final String? lastLoginIp;
  final String? lastLoginDate;
  final String? createBy;
  final String? createTime;
  final String? updateBy;
  final String? updateTime;
  final bool? isDelete;
  final String? googleSub;
  final String? googleLinkedTime;
  final String? appleSub;
  final String? appleLinkedTime;

  SysUser({
    this.id,
    this.username,
    this.password,
    this.roleId,
    this.clientRole,
    this.wechatOpenId,
    this.avatar,
    this.nickname,
    this.email,
    this.phoneNumber,
    this.sex,
    this.lastLoginIp,
    this.lastLoginDate,
    this.createBy,
    this.createTime,
    this.updateBy,
    this.updateTime,
    this.isDelete,
    this.googleSub,
    this.googleLinkedTime,
    this.appleSub,
    this.appleLinkedTime,
  });

  factory SysUser.fromJson(Map<String, dynamic> json) {
    return SysUser(
      id: json['id'] as int?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      roleId: json['roleId'] as int?,
      clientRole: json['clientRole'] as String?,
      wechatOpenId: json['wechatOpenId'] as String?,
      avatar: json['avatar'] as String?,
      nickname: json['nickname'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      sex: json['sex'] as String?,
      lastLoginIp: json['lastLoginIp'] as String?,
      lastLoginDate: json['lastLoginDate'] as String?,
      createBy: json['createBy'] as String?,
      createTime: json['createTime'] as String?,
      updateBy: json['updateBy'] as String?,
      updateTime: json['updateTime'] as String?,
      isDelete: json['isDelete'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (roleId != null) 'roleId': roleId,
      if (clientRole != null) 'clientRole': clientRole,
      if (wechatOpenId != null) 'wechatOpenId': wechatOpenId,
      if (avatar != null) 'avatar': avatar,
      if (nickname != null) 'nickname': nickname,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (sex != null) 'sex': sex,
      if (lastLoginIp != null) 'lastLoginIp': lastLoginIp,
      if (lastLoginDate != null) 'lastLoginDate': lastLoginDate,
      if (createBy != null) 'createBy': createBy,
      if (createTime != null) 'createTime': createTime,
      if (updateBy != null) 'updateBy': updateBy,
      if (updateTime != null) 'updateTime': updateTime,
      if (isDelete != null) 'isDelete': isDelete,
    };
  }
}
