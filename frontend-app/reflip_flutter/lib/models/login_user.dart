import 'sys_user.dart';

/// 登录用户实体
class LoginUser {
  final String? token;
  final SysUser? user;
  final bool? isNewUser;

  LoginUser({this.token, this.user, this.isNewUser});

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      token: json['token'] as String?,
      user: json['user'] != null
          ? SysUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      isNewUser: json['isNewUser'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'token': token,
      if (user != null) 'user': user!.toJson(),
      if (isNewUser != null) 'isNewUser': isNewUser,
    };
  }
}
