package org.charno.common.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;

/**
 * S3配置类
 * @author charno
 */
@Configuration
@ConfigurationProperties(prefix = "aws.s3")
@Data
public class S3Config {
    
    /**
     * AWS访问密钥ID
     */
    private String accessKeyId;
    
    /**
     * AWS秘密访问密钥
     */
    private String secretAccessKey;
    
    /**
     * AWS区域
     */
    private String region = "us-east-1";
    
    /**
     * S3存储桶名称
     */
    private String bucketName;
    
    /**
     * 预签名URL过期时间（分钟）
     */
    private Long presignedUrlExpiration = 15L;
    
    /**
     * 上传文件的基础路径
     */
    private String basePath = "uploads/";
    
    /**
     * 创建S3客户端
     */
    @Bean
    public S3Client s3Client() {
        return S3Client.builder()
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKeyId, secretAccessKey)))
                .build();
    }
    
    /**
     * 创建S3预签名器
     */
    @Bean
    public S3Presigner s3Presigner() {
        return S3Presigner.builder()
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKeyId, secretAccessKey)))
                .build();
    }
} 