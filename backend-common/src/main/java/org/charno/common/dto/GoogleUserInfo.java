package org.charno.common.dto;

import lombok.Data;

@Data
public class GoogleUserInfo {
    private String id;           // Google用户ID (sub)
    private String email;        // 邮箱
    private String name;         // 用户名
    private String givenName;    // 名
    private String familyName;   // 姓
    private String picture;      // 头像URL
    private Boolean emailVerified; // 邮箱是否验证
} 