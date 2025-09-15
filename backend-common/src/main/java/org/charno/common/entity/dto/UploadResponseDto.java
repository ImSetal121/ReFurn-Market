package org.charno.common.entity.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 文件上传响应DTO
 * @author charno
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UploadResponseDto {
    
    /**
     * 预签名上传URL
     */
    private String uploadUrl;
    
    /**
     * 文件访问URL
     */
    private String fileUrl;
    
    /**
     * 文件在S3中的键名
     */
    private String fileKey;
    
    /**
     * 文件名
     */
    private String fileName;
    
    /**
     * 文件类型
     */
    private String contentType;
    
    /**
     * 上传URL过期时间戳
     */
    private Long expiresAt;
} 