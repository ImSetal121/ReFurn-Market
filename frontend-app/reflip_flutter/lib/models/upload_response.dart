/// 文件上传响应模型
class UploadResponse {
  /// 预签名上传URL
  final String uploadUrl;

  /// 文件访问URL
  final String fileUrl;

  /// 文件键名
  final String fileKey;

  /// 文件名
  final String fileName;

  /// 文件类型
  final String contentType;

  /// 过期时间戳
  final int expiresAt;

  UploadResponse({
    required this.uploadUrl,
    required this.fileUrl,
    required this.fileKey,
    required this.fileName,
    required this.contentType,
    required this.expiresAt,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      uploadUrl: json['uploadUrl'] as String,
      fileUrl: json['fileUrl'] as String,
      fileKey: json['fileKey'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      expiresAt: json['expiresAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadUrl': uploadUrl,
      'fileUrl': fileUrl,
      'fileKey': fileKey,
      'fileName': fileName,
      'contentType': contentType,
      'expiresAt': expiresAt,
    };
  }
}
