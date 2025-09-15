import axios from 'axios';
import { post, del, get } from './request';

/**
 * 上传响应接口
 */
export interface UploadResponse {
    uploadUrl: string;
    fileUrl: string;
    fileKey: string;
    fileName: string;
    contentType: string;
    expiresAt: number;
}

/**
 * 上传进度回调函数类型
 */
export type UploadProgressCallback = (progress: number) => void;

/**
 * 上传错误类型
 */
export class UploadError extends Error {
    constructor(message: string, public readonly code?: string) {
        super(message);
        this.name = 'UploadError';
    }
}

/**
 * S3上传工具类
 */
export class S3UploadUtils {
    /**
     * 支持的图片类型
     */
    private static readonly SUPPORTED_IMAGE_TYPES = [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/gif',
        'image/webp'
    ];

    /**
     * 最大文件大小 (10MB)
     */
    private static readonly MAX_FILE_SIZE = 10 * 1024 * 1024;

    /**
     * 验证文件类型
     */
    private static isValidImageType(contentType: string): boolean {
        return this.SUPPORTED_IMAGE_TYPES.includes(contentType.toLowerCase());
    }

    /**
     * 验证文件大小
     */
    private static isValidFileSize(size: number): boolean {
        return size <= this.MAX_FILE_SIZE;
    }

    /**
     * 获取图片上传的预签名URL
     */
    static async getImageUploadUrl(fileName: string, contentType: string): Promise<UploadResponse> {
        try {
            // 验证文件类型
            if (!this.isValidImageType(contentType)) {
                throw new UploadError(`不支持的图片类型: ${contentType}`, 'INVALID_TYPE');
            }

            // 使用POST方法调用后端API，将参数作为表单数据
            const formData = new FormData();
            formData.append('fileName', fileName);
            formData.append('contentType', contentType);

            const response = await post<UploadResponse>('/api/upload/image/presigned-url', formData);

            return response;
        } catch (error) {
            if (error instanceof Error) {
                throw new UploadError(
                    error.message || '获取上传URL失败',
                    'API_ERROR'
                );
            }
            throw error;
        }
    }

    /**
     * 获取通用文件上传的预签名URL
     */
    static async getFileUploadUrl(
        fileName: string,
        contentType: string,
        folder?: string
    ): Promise<UploadResponse> {
        try {
            // 使用POST方法调用后端API，将参数作为表单数据
            const formData = new FormData();
            formData.append('fileName', fileName);
            formData.append('contentType', contentType);
            if (folder) {
                formData.append('folder', folder);
            }

            const response = await post<UploadResponse>('/api/upload/file/presigned-url', formData);

            return response;
        } catch (error) {
            if (error instanceof Error) {
                throw new UploadError(
                    error.message || '获取上传URL失败',
                    'API_ERROR'
                );
            }
            throw error;
        }
    }

    /**
     * 上传文件到S3
     * 注意：这个请求直接发送到S3，不经过后端，所以使用原生axios
     */
    static async uploadFileToS3(
        file: File,
        uploadUrl: string,
        onProgress?: UploadProgressCallback
    ): Promise<void> {
        try {
            await axios.put(uploadUrl, file, {
                headers: {
                    'Content-Type': file.type
                },
                onUploadProgress: (progressEvent) => {
                    if (onProgress && progressEvent.total) {
                        const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
                        onProgress(progress);
                    }
                }
            });
        } catch (error) {
            if (axios.isAxiosError(error)) {
                throw new UploadError('文件上传失败', error.response?.status?.toString());
            }
            throw error;
        }
    }

    /**
     * 完整的图片上传流程
     */
    static async uploadImage(
        file: File,
        onProgress?: UploadProgressCallback
    ): Promise<UploadResponse> {
        // 验证文件大小
        if (!this.isValidFileSize(file.size)) {
            throw new UploadError('文件大小超过限制（最大10MB）', 'FILE_TOO_LARGE');
        }

        // 验证文件类型
        if (!this.isValidImageType(file.type)) {
            throw new UploadError(`不支持的图片类型: ${file.type}`, 'INVALID_TYPE');
        }

        // 1. 获取预签名URL
        const uploadResponse = await this.getImageUploadUrl(file.name, file.type);

        // 2. 上传文件到S3
        await this.uploadFileToS3(file, uploadResponse.uploadUrl, onProgress);

        return uploadResponse;
    }

    /**
     * 完整的文件上传流程
     */
    static async uploadFile(
        file: File,
        folder?: string,
        onProgress?: UploadProgressCallback
    ): Promise<UploadResponse> {
        // 验证文件大小
        if (!this.isValidFileSize(file.size)) {
            throw new UploadError('文件大小超过限制（最大10MB）', 'FILE_TOO_LARGE');
        }

        // 1. 获取预签名URL
        const uploadResponse = await this.getFileUploadUrl(file.name, file.type, folder);

        // 2. 上传文件到S3
        await this.uploadFileToS3(file, uploadResponse.uploadUrl, onProgress);

        return uploadResponse;
    }

    /**
     * 删除文件
     */
    static async deleteFile(fileKey: string): Promise<boolean> {
        try {
            // 使用封装的del方法调用后端API
            await del<void>('/api/upload/file', { fileKey });
            return true;
        } catch (_error) {
            // 记录错误但不抛出，返回false表示删除失败
            return false;
        }
    }

    /**
     * 检查文件是否存在
     */
    static async fileExists(fileKey: string): Promise<boolean> {
        try {
            // 使用封装的get方法调用后端API
            const response = await get<boolean>('/api/upload/file/exists', { fileKey });
            return response;
        } catch (_error) {
            // 出错时默认返回false
            return false;
        }
    }

    /**
     * 格式化文件大小
     */
    static formatFileSize(bytes: number): string {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
    }

    /**
     * 获取文件扩展名
     */
    static getFileExtension(fileName: string): string {
        return fileName.slice((fileName.lastIndexOf('.') - 1 >>> 0) + 2);
    }
} 