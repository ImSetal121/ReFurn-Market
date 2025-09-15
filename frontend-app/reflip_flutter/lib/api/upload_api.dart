import 'dart:io';
import 'package:dio/dio.dart';
import '../models/upload_response.dart';
import '../utils/request.dart';

/// 上传相关API
class UploadApi {
  /// 获取图片上传的预签名URL
  static Future<UploadResponse?> getImageUploadUrl(
    String fileName,
    String contentType,
  ) async {
    final data = await HttpRequest.post<Map<String, dynamic>>(
      '/api/upload/image/presigned-url',
      queryParameters: {'fileName': fileName, 'contentType': contentType},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (data != null) {
      return UploadResponse.fromJson(data);
    }

    return null;
  }

  /// 直接上传文件到S3
  static Future<bool> uploadFileToS3(
    String uploadUrl,
    File file,
    String contentType,
  ) async {
    try {
      final dio = Dio();

      // 读取文件内容
      final fileBytes = await file.readAsBytes();

      // 使用PUT请求上传到S3
      final response = await dio.put(
        uploadUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': fileBytes.length,
          },
          // 不要添加额外的请求头
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      // S3返回200或204表示成功
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('上传文件到S3失败: $e');
      return false;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile(String fileKey) async {
    try {
      await HttpRequest.delete<void>(
        '/api/upload/file',
        queryParameters: {'fileKey': fileKey},
      );
      return true;
    } catch (e) {
      print('删除文件失败: $e');
      return false;
    }
  }

  /// 检查文件是否存在
  static Future<bool> fileExists(String fileKey) async {
    final exists = await HttpRequest.get<bool>(
      '/api/upload/file/exists',
      queryParameters: {'fileKey': fileKey},
      fromJson: (json) => json as bool,
    );

    return exists ?? false;
  }
}
 