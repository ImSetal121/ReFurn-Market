/// 统一响应结果封装类
class R<T> {
  /// 状态码
  final int code;
  
  /// 返回消息
  final String message;
  
  /// 返回数据
  final T? data;
  
  /// 是否成功
  final bool success;
  
  /// 时间戳
  final int timestamp;
  
  R({
    required this.code,
    required this.message,
    this.data,
    required this.success,
    required this.timestamp,
  });
  
  factory R.fromJson(Map<String, dynamic> json, T? Function(dynamic)? fromJson) {
    return R<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : null,
      success: json['success'] as bool,
      timestamp: json['timestamp'] as int,
    );
  }
  
  /// 判断是否成功
  bool isSuccess() => code == 200;
}

/// 结果码枚举
class ResultCode {
  static const int SUCCESS = 200;
  static const int FAILED = 500;
  static const int VALIDATE_FAILED = 404;
  static const int UNAUTHORIZED = 401;
  static const int FORBIDDEN = 403;
  
  // 用户相关：1000~1999
  static const int USER_NOT_EXIST = 1000;
  static const int USERNAME_OR_PASSWORD_ERROR = 1001;
  static const int USER_ACCOUNT_EXPIRED = 1002;
  static const int USER_CREDENTIALS_ERROR = 1003;
  static const int USER_CREDENTIALS_EXPIRED = 1004;
  static const int USER_ACCOUNT_DISABLE = 1005;
  static const int USER_ACCOUNT_LOCKED = 1006;
  static const int USER_ACCOUNT_NOT_EXIST = 1007;
  static const int USER_ACCOUNT_ALREADY_EXIST = 1008;
  static const int USER_ACCOUNT_USE_BY_OTHERS = 1009;
}
