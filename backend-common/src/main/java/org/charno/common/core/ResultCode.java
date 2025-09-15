package org.charno.common.core;

/**
 * 常用API返回码枚举
 */
public enum ResultCode implements IResultCode {
    SUCCESS(200, "操作成功"),
    FAILED(500, "操作失败"),
    VALIDATE_FAILED(404, "参数检验失败"),
    UNAUTHORIZED(401, "暂未登录或token已经过期"),
    FORBIDDEN(403, "没有相关权限"),

    // 用户相关：1000~1999
    USER_NOT_EXIST(1000, "用户不存在"),
    USERNAME_OR_PASSWORD_ERROR(1001, "用户名或密码错误"),
    USER_ACCOUNT_EXPIRED(1002, "账号已过期"),
    USER_CREDENTIALS_ERROR(1003, "用户凭证错误"),
    USER_CREDENTIALS_EXPIRED(1004, "用户凭证已过期"),
    USER_ACCOUNT_DISABLE(1005, "账号不可用"),
    USER_ACCOUNT_LOCKED(1006, "账号被锁定"),
    USER_ACCOUNT_NOT_EXIST(1007, "账号不存在"),
    USER_ACCOUNT_ALREADY_EXIST(1008, "账号已存在"),
    USER_ACCOUNT_USE_BY_OTHERS(1009, "账号下线"),

    // 业务异常：2000~2999
    NO_PERMISSION(2001, "没有相关权限"),

    // 系统异常：3000~3999
    SYSTEM_INNER_ERROR(3000, "系统繁忙，请稍后重试"),

    // 数据异常：4000~4999
    DATA_NOT_FOUND(4000, "数据不存在"),
    DATA_IS_WRONG(4001, "数据有误"),
    DATA_ALREADY_EXISTED(4002, "数据已存在"),

    // 接口异常：5000~5999
    INTERFACE_INNER_INVOKE_ERROR(5000, "内部系统接口调用异常"),
    INTERFACE_OUTER_INVOKE_ERROR(5001, "外部系统接口调用异常"),
    INTERFACE_FORBID_VISIT(5002, "该接口禁止访问"),
    INTERFACE_ADDRESS_INVALID(5003, "接口地址无效"),
    INTERFACE_REQUEST_TIMEOUT(5004, "接口请求超时"),
    INTERFACE_EXCEED_LOAD(5005, "接口负载过高");

    private final Integer code;
    private final String message;

    ResultCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }

    @Override
    public Integer getCode() {
        return code;
    }

    @Override
    public String getMessage() {
        return message;
    }
}
