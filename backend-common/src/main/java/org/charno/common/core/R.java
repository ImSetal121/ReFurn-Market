package org.charno.common.core;

import java.io.Serializable;

/**
 * 统一响应结果封装类
 *
 * @param <T> 响应数据的类型
 */
public class R<T> implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 状态码 */
    private Integer code;

    /** 返回消息 */
    private String message;

    /** 返回数据 */
    private T data;

    /** 是否成功 */
    private boolean success;

    /** 时间戳 */
    private long timestamp;

    private R() {
        this.timestamp = System.currentTimeMillis();
    }

    /**
     * 成功返回结果
     */
    public static <T> R<T> ok() {
        return ok(null);
    }

    /**
     * 成功返回结果
     *
     * @param data 返回的数据
     */
    public static <T> R<T> ok(T data) {
        R<T> r = new R<>();
        r.setSuccess(true);
        r.setCode(ResultCode.SUCCESS.getCode());
        r.setMessage(ResultCode.SUCCESS.getMessage());
        r.setData(data);
        return r;
    }

    /**
     * 成功返回结果
     *
     * @param data    返回的数据
     * @param message 返回的消息
     */
    public static <T> R<T> ok(T data, String message) {
        R<T> r = new R<>();
        r.setSuccess(true);
        r.setCode(ResultCode.SUCCESS.getCode());
        r.setMessage(message);
        r.setData(data);
        return r;
    }

    /**
     * 失败返回结果
     */
    public static <T> R<T> fail() {
        return fail(ResultCode.FAILED);
    }

    /**
     * 失败返回结果
     *
     * @param message 错误信息
     */
    public static <T> R<T> fail(String message) {
        R<T> r = new R<>();
        r.setSuccess(false);
        r.setCode(ResultCode.FAILED.getCode());
        r.setMessage(message);
        return r;
    }

    /**
     * 失败返回结果
     *
     * @param errorCode 错误码
     */
    public static <T> R<T> fail(IResultCode errorCode) {
        R<T> r = new R<>();
        r.setSuccess(false);
        r.setCode(errorCode.getCode());
        r.setMessage(errorCode.getMessage());
        return r;
    }

    /**
     * 失败返回结果
     *
     * @param errorCode 错误码
     * @param message   错误信息
     */
    public static <T> R<T> fail(IResultCode errorCode, String message) {
        R<T> r = new R<>();
        r.setSuccess(false);
        r.setCode(errorCode.getCode());
        r.setMessage(message);
        return r;
    }

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }
}
