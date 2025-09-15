package org.charno.system.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.charno.common.core.R;
import org.charno.common.core.ResultCode;
import org.charno.common.entity.dto.UploadResponseDto;
import org.charno.common.utils.S3Utils;
import org.springframework.web.bind.annotation.*;

/**
 * 文件上传控制器
 * @author charno
 */
@Slf4j
@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FileUploadController {
    
    private final S3Utils s3Utils;
    
    /**
     * 生成图片上传的预签名URL
     * 
     * @param fileName 文件名
     * @param contentType 文件类型
     * @return 预签名URL信息
     */
    @PostMapping("/image/presigned-url")
    public R<UploadResponseDto> generateImageUploadUrl(
            @RequestParam String fileName,
            @RequestParam String contentType) {
        
        try {
            log.info("生成图片上传预签名URL请求: fileName={}, contentType={}", fileName, contentType);
            
            UploadResponseDto response = s3Utils.generateImageUploadUrl(fileName, contentType);
            
            return R.ok(response, "预签名URL生成成功");
            
        } catch (IllegalArgumentException e) {
            log.warn("图片上传URL生成失败，参数无效: {}", e.getMessage());
            return R.fail(ResultCode.VALIDATE_FAILED, e.getMessage());
            
        } catch (Exception e) {
            log.error("生成图片上传预签名URL失败", e);
            return R.fail(ResultCode.SYSTEM_INNER_ERROR, "生成上传URL失败，请稍后重试");
        }
    }
    
    /**
     * 生成通用文件上传的预签名URL
     * 
     * @param fileName 文件名
     * @param contentType 文件类型
     * @param folder 文件夹路径（可选）
     * @return 预签名URL信息
     */
    @PostMapping("/file/presigned-url")
    public R<UploadResponseDto> generateFileUploadUrl(
            @RequestParam String fileName,
            @RequestParam String contentType,
            @RequestParam(required = false) String folder) {
        
        try {
            log.info("生成文件上传预签名URL请求: fileName={}, contentType={}, folder={}", 
                    fileName, contentType, folder);
            
            UploadResponseDto response = s3Utils.generateUploadUrl(fileName, contentType, folder);
            
            return R.ok(response, "预签名URL生成成功");
            
        } catch (Exception e) {
            log.error("生成文件上传预签名URL失败", e);
            return R.fail(ResultCode.SYSTEM_INNER_ERROR, "生成上传URL失败，请稍后重试");
        }
    }
    
    /**
     * 删除文件
     * 
     * @param fileKey 文件键名
     * @return 删除结果
     */
    @DeleteMapping("/file")
    public R<Void> deleteFile(@RequestParam String fileKey) {
        try {
            log.info("删除文件请求: fileKey={}", fileKey);
            
            boolean success = s3Utils.deleteFile(fileKey);
            
            if (success) {
                return R.ok(null, "文件删除成功");
            } else {
                return R.fail(ResultCode.DATA_NOT_FOUND, "文件不存在或删除失败");
            }
            
        } catch (Exception e) {
            log.error("删除文件失败: fileKey={}", fileKey, e);
            return R.fail(ResultCode.SYSTEM_INNER_ERROR, "删除文件失败，请稍后重试");
        }
    }
    
    /**
     * 检查文件是否存在
     * 
     * @param fileKey 文件键名
     * @return 文件是否存在
     */
    @GetMapping("/file/exists")
    public R<Boolean> fileExists(@RequestParam String fileKey) {
        try {
            boolean exists = s3Utils.fileExists(fileKey);
            return R.ok(exists, "查询成功");
            
        } catch (Exception e) {
            log.error("检查文件是否存在失败: fileKey={}", fileKey, e);
            return R.fail(ResultCode.SYSTEM_INNER_ERROR, "查询文件状态失败，请稍后重试");
        }
    }
} 