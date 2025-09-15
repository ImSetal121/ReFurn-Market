package org.charno.common.utils;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.charno.common.config.S3Config;
import org.charno.common.entity.dto.UploadResponseDto;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;
import software.amazon.awssdk.core.sync.RequestBody;

import java.io.InputStream;
import java.time.Duration;
import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * S3文件上传工具类
 * @author charno
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class S3Utils {
    
    private final S3Client s3Client;
    private final S3Presigner s3Presigner;
    private final S3Config s3Config;
    
    /**
     * 支持的图片类型
     */
    private static final List<String> SUPPORTED_IMAGE_TYPES = Arrays.asList(
            "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"
    );
    
    /**
     * 生成图片上传的预签名URL
     * 
     * @param fileName 文件名
     * @param contentType 文件类型
     * @return 上传响应DTO
     */
    public UploadResponseDto generateImageUploadUrl(String fileName, String contentType) {
        // 验证文件类型
        if (!isValidImageType(contentType)) {
            throw new IllegalArgumentException("不支持的图片类型: " + contentType);
        }
        
        return generateUploadUrl(fileName, contentType, "images/");
    }
    
    /**
     * 生成文件上传的预签名URL
     * 
     * @param fileName 文件名
     * @param contentType 文件类型
     * @param folder 文件夹路径（可选）
     * @return 上传响应DTO
     */
    public UploadResponseDto generateUploadUrl(String fileName, String contentType, String folder) {
        try {
            // 生成唯一的文件键名
            String fileKey = generateFileKey(fileName, folder);
            
            // 创建PUT对象请求
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(s3Config.getBucketName())
                    .key(fileKey)
                    .contentType(contentType)
                    // .acl("public-read")  // 设置文件为公开读取
                    .build();
            
            // 创建预签名请求
            PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                    .signatureDuration(Duration.ofMinutes(s3Config.getPresignedUrlExpiration()))
                    .putObjectRequest(putObjectRequest)
                    .build();
            
            // 生成预签名URL
            PresignedPutObjectRequest presignedRequest = s3Presigner.presignPutObject(presignRequest);
            String uploadUrl = presignedRequest.url().toString();
            
            // 生成文件访问URL
            String fileUrl = generateFileAccessUrl(fileKey);
            
            // 计算过期时间
            long expiresAt = Instant.now().plus(Duration.ofMinutes(s3Config.getPresignedUrlExpiration())).getEpochSecond();
            
            log.info("生成预签名上传URL成功: fileKey={}, uploadUrl={}", fileKey, uploadUrl);
            
            return UploadResponseDto.builder()
                    .uploadUrl(uploadUrl)
                    .fileUrl(fileUrl)
                    .fileKey(fileKey)
                    .fileName(fileName)
                    .contentType(contentType)
                    .expiresAt(expiresAt)
                    .build();
                    
        } catch (Exception e) {
            log.error("生成预签名上传URL失败: fileName={}, contentType={}", fileName, contentType, e);
            throw new RuntimeException("生成上传URL失败", e);
        }
    }
    
    /**
     * 从InputStream直接上传图片到S3
     * 
     * @param inputStream 输入流
     * @param fileName 文件名
     * @param contentType 文件类型
     * @return 文件访问URL
     */
    public String uploadImageFromStream(InputStream inputStream, String fileName, String contentType) {
        try {
            // 验证文件类型
            if (!isValidImageType(contentType)) {
                throw new IllegalArgumentException("不支持的图片类型: " + contentType);
            }
            
            // 生成文件键名
            String fileKey = s3Config.getBasePath() + fileName;
            
            // 创建PUT对象请求
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(s3Config.getBucketName())
                    .key(fileKey)
                    .contentType(contentType)
                    .build();
            
            // 上传文件
            s3Client.putObject(putObjectRequest, RequestBody.fromInputStream(inputStream, inputStream.available()));
            
            // 生成并返回文件访问URL
            String fileUrl = generateFileAccessUrl(fileKey);
            log.info("从InputStream上传图片成功: fileKey={}, fileUrl={}", fileKey, fileUrl);
            
            return fileUrl;
            
        } catch (Exception e) {
            log.error("从InputStream上传图片失败: fileName={}, contentType={}", fileName, contentType, e);
            throw new RuntimeException("上传图片失败", e);
        }
    }
    
    /**
     * 从字节数组上传图片到S3
     * 
     * @param imageData 图片字节数组
     * @param fileName 文件名
     * @param contentType 文件类型
     * @return 文件访问URL
     */
    public String uploadImageFromBytes(byte[] imageData, String fileName, String contentType) {
        try {
            // 验证文件类型
            if (!isValidImageType(contentType)) {
                throw new IllegalArgumentException("不支持的图片类型: " + contentType);
            }
            
            // 验证数据
            if (imageData == null || imageData.length == 0) {
                throw new IllegalArgumentException("图片数据不能为空");
            }
            
            // 生成文件键名
            String fileKey = s3Config.getBasePath() + fileName;
            
            // 创建PUT对象请求
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(s3Config.getBucketName())
                    .key(fileKey)
                    .contentType(contentType)
                    .contentLength((long) imageData.length)
                    .build();
            
            // 上传文件
            s3Client.putObject(putObjectRequest, RequestBody.fromBytes(imageData));
            
            // 生成并返回文件访问URL
            String fileUrl = generateFileAccessUrl(fileKey);
            log.info("从字节数组上传图片成功: fileKey={}, fileUrl={}, 大小={} 字节", fileKey, fileUrl, imageData.length);
            
            return fileUrl;
            
        } catch (Exception e) {
            log.error("从字节数组上传图片失败: fileName={}, contentType={}, 大小={} 字节", fileName, contentType, imageData != null ? imageData.length : 0, e);
            throw new RuntimeException("上传图片失败", e);
        }
    }
    
    /**
     * 删除S3中的文件
     * 
     * @param fileKey 文件键名
     * @return 是否删除成功
     */
    public boolean deleteFile(String fileKey) {
        try {
            DeleteObjectRequest deleteRequest = DeleteObjectRequest.builder()
                    .bucket(s3Config.getBucketName())
                    .key(fileKey)
                    .build();
                    
            s3Client.deleteObject(deleteRequest);
            log.info("删除S3文件成功: fileKey={}", fileKey);
            return true;
            
        } catch (Exception e) {
            log.error("删除S3文件失败: fileKey={}", fileKey, e);
            return false;
        }
    }
    
    /**
     * 检查文件是否存在
     * 
     * @param fileKey 文件键名
     * @return 是否存在
     */
    public boolean fileExists(String fileKey) {
        try {
            HeadObjectRequest headRequest = HeadObjectRequest.builder()
                    .bucket(s3Config.getBucketName())
                    .key(fileKey)
                    .build();
                    
            s3Client.headObject(headRequest);
            return true;
            
        } catch (NoSuchKeyException e) {
            return false;
        } catch (Exception e) {
            log.error("检查文件是否存在失败: fileKey={}", fileKey, e);
            return false;
        }
    }
    
    /**
     * 获取文件信息
     * 
     * @param fileKey 文件键名
     * @return 文件信息
     */
    public HeadObjectResponse getFileInfo(String fileKey) {
        try {
            HeadObjectRequest headRequest = HeadObjectRequest.builder()
                    .bucket(s3Config.getBucketName())
                    .key(fileKey)
                    .build();
                    
            return s3Client.headObject(headRequest);
            
        } catch (Exception e) {
            log.error("获取文件信息失败: fileKey={}", fileKey, e);
            throw new RuntimeException("获取文件信息失败", e);
        }
    }
    
    /**
     * 生成文件键名
     * 
     * @param fileName 原文件名
     * @param folder 文件夹路径
     * @return 唯一的文件键名
     */
    private String generateFileKey(String fileName, String folder) {
        String uuid = UUID.randomUUID().toString().replace("-", "");
        String extension = getFileExtension(fileName);
        String uniqueFileName = uuid + (extension.isEmpty() ? "" : "." + extension);
        
        String folderPath = folder != null ? folder : "";
        if (!folderPath.isEmpty() && !folderPath.endsWith("/")) {
            folderPath += "/";
        }
        
        return s3Config.getBasePath() + folderPath + uniqueFileName;
    }
    
    /**
     * 获取文件扩展名
     * 
     * @param fileName 文件名
     * @return 文件扩展名
     */
    private String getFileExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return "";
        }
        int lastDotIndex = fileName.lastIndexOf('.');
        return lastDotIndex > 0 ? fileName.substring(lastDotIndex + 1).toLowerCase() : "";
    }
    
    /**
     * 验证是否为支持的图片类型
     * 
     * @param contentType 文件类型
     * @return 是否支持
     */
    private boolean isValidImageType(String contentType) {
        return contentType != null && SUPPORTED_IMAGE_TYPES.contains(contentType.toLowerCase());
    }
    
    /**
     * 生成文件访问URL
     * 
     * @param fileKey 文件键名
     * @return 文件访问URL
     */
    private String generateFileAccessUrl(String fileKey) {
        return String.format("https://%s.s3.%s.amazonaws.com/%s", 
                s3Config.getBucketName(), s3Config.getRegion(), fileKey);
    }
} 