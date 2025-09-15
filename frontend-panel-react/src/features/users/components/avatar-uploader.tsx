import React, { useState, useRef } from 'react';
import { S3UploadUtils, UploadError, type UploadResponse } from '@/utils/s3-upload';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Upload, X, User, Loader2 } from 'lucide-react';
import { toast } from 'sonner';

interface AvatarUploaderProps {
    value?: string;
    onChange?: (url: string) => void;
    disabled?: boolean;
    className?: string;
}

export const AvatarUploader: React.FC<AvatarUploaderProps> = ({
    value,
    onChange,
    disabled = false,
    className = ''
}) => {
    const [uploading, setUploading] = useState(false);
    const [progress, setProgress] = useState(0);
    const [pendingUrl, setPendingUrl] = useState<string | null>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);

    // 当前显示的头像URL（优先显示待确认的URL）
    const currentAvatarUrl = pendingUrl || value;

    const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (!file) return;

        // 验证文件类型
        if (!file.type.startsWith('image/')) {
            toast.error('请选择图片文件');
            return;
        }

        // 验证文件大小（5MB）
        const maxSize = 5 * 1024 * 1024;
        if (file.size > maxSize) {
            toast.error('图片大小不能超过5MB');
            return;
        }

        try {
            setUploading(true);
            setProgress(0);

            const response: UploadResponse = await S3UploadUtils.uploadImage(file, (progress) => {
                setProgress(progress);
            });

            // 上传成功后，设置为待确认状态
            setPendingUrl(response.fileUrl);
            toast.success('图片上传成功，请点击"确认使用"保存头像');

        } catch (error) {
            if (error instanceof UploadError) {
                toast.error(`上传失败: ${error.message}`);
            } else {
                toast.error('上传失败，请重试');
            }
        } finally {
            setUploading(false);
            setProgress(0);
            // 清空文件输入，允许重复选择同一文件
            if (fileInputRef.current) {
                fileInputRef.current.value = '';
            }
        }
    };

    const handleUploadClick = () => {
        if (disabled || uploading) return;
        fileInputRef.current?.click();
    };

    const handleConfirm = () => {
        if (pendingUrl && onChange) {
            onChange(pendingUrl);
            setPendingUrl(null);
            toast.success('头像已更新');
        }
    };

    const handleCancel = () => {
        setPendingUrl(null);
        toast.info('已取消头像更改');
    };

    const handleRemove = () => {
        if (onChange) {
            onChange('');
            setPendingUrl(null);
            toast.success('头像已移除');
        }
    };

    return (
        <div className={`space-y-4 ${className}`}>
            <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleFileSelect}
                className="hidden"
                disabled={disabled}
            />

            <div className="flex items-center space-x-4">
                {/* 头像预览 */}
                <div className="relative">
                    <Avatar className="h-20 w-20">
                        <AvatarImage
                            src={currentAvatarUrl}
                            alt="用户头像"
                            className="object-cover"
                        />
                        <AvatarFallback className="bg-muted">
                            <User className="h-8 w-8 text-muted-foreground" />
                        </AvatarFallback>
                    </Avatar>

                    {/* 上传进度覆盖层 */}
                    {uploading && (
                        <div className="absolute inset-0 bg-black bg-opacity-50 rounded-full flex items-center justify-center">
                            <div className="text-center">
                                <Loader2 className="h-6 w-6 text-white animate-spin mx-auto mb-1" />
                                <div className="text-xs text-white">{progress}%</div>
                            </div>
                        </div>
                    )}

                    {/* 待确认标识 */}
                    {pendingUrl && !uploading && (
                        <div className="absolute -top-1 -right-1 bg-orange-500 text-white rounded-full p-1">
                            <Upload className="h-3 w-3" />
                        </div>
                    )}
                </div>

                {/* 操作按钮 */}
                <div className="flex flex-col space-y-2">
                    <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={handleUploadClick}
                        disabled={disabled || uploading}
                        className="w-24"
                    >
                        {uploading ? (
                            <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                            <Upload className="h-4 w-4 mr-1" />
                        )}
                        上传
                    </Button>

                    {currentAvatarUrl && !uploading && (
                        <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            onClick={handleRemove}
                            disabled={disabled}
                            className="w-24 text-red-600 hover:text-red-700"
                        >
                            <X className="h-4 w-4 mr-1" />
                            移除
                        </Button>
                    )}
                </div>
            </div>

            {/* 待确认状态的操作按钮 */}
            {pendingUrl && !uploading && (
                <div className="flex items-center space-x-2 p-3 bg-orange-50 border border-orange-200 rounded-lg">
                    <div className="flex-1">
                        <p className="text-sm text-orange-800">
                            头像已上传，是否确认使用？
                        </p>
                    </div>
                    <div className="flex space-x-2">
                        <Button
                            type="button"
                            size="sm"
                            onClick={handleConfirm}
                            disabled={disabled}
                        >
                            确认使用
                        </Button>
                        <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            onClick={handleCancel}
                            disabled={disabled}
                        >
                            取消
                        </Button>
                    </div>
                </div>
            )}

            {/* 上传提示 */}
            <p className="text-xs text-muted-foreground">
                支持 JPEG、PNG、GIF、WebP 格式，最大 5MB
            </p>
        </div>
    );
}; 