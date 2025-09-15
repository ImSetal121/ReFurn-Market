import 'dart:io';

/// 上传状态枚举
enum UploadStatus {
  /// 等待上传
  pending,

  /// 正在上传
  uploading,

  /// 上传成功
  success,

  /// 上传失败
  failed,
}

/// 已上传图片的数据模型
class UploadedImage {
  /// 本地文件
  final File file;

  /// 上传状态
  UploadStatus status;

  /// 上传进度 (0-100)
  double progress;

  /// 错误信息
  String? errorMessage;

  /// 文件访问URL（上传成功后）
  String? fileUrl;

  /// 文件键名（用于删除）
  String? fileKey;

  /// 原始文件名
  String? fileName;

  UploadedImage({
    required this.file,
    this.status = UploadStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    this.fileUrl,
    this.fileKey,
    this.fileName,
  });

  /// 是否正在上传
  bool get isUploading => status == UploadStatus.uploading;

  /// 是否上传成功
  bool get isSuccess => status == UploadStatus.success;

  /// 是否上传失败
  bool get isFailed => status == UploadStatus.failed;

  /// 是否可以删除
  bool get canDelete =>
      status == UploadStatus.success || status == UploadStatus.failed;

  /// 复制并更新状态
  UploadedImage copyWith({
    UploadStatus? status,
    double? progress,
    String? errorMessage,
    String? fileUrl,
    String? fileKey,
    String? fileName,
  }) {
    return UploadedImage(
      file: file,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      fileUrl: fileUrl ?? this.fileUrl,
      fileKey: fileKey ?? this.fileKey,
      fileName: fileName ?? this.fileName,
    );
  }
}
