package org.charno.system.service;

import com.alibaba.fastjson2.JSONObject;
import org.charno.common.dto.GoogleUserInfo;
import org.charno.common.security.LoginUser;

public interface IGoogleAuthService {
    
    /**
     * 通过授权码获取Google用户信息
     * @param authCode 授权码
     * @return Google用户信息
     */
    GoogleUserInfo getGoogleUserInfo(String authCode);
    
    /**
     * Google登录 (Web端授权码方式)
     * @param authCode 授权码
     * @return 登录用户信息
     */
    LoginUser googleLogin(String authCode);
    
    /**
     * Google移动端登录 (ID Token方式)
     * @param idToken Google ID Token
     * @param clientType 客户端类型 (ios/android)
     * @return 登录用户信息
     */
    LoginUser googleMobileLogin(String idToken, String clientType);
    
    /**
     * 验证Google ID Token并获取用户信息
     * @param idToken Google ID Token
     * @param clientType 客户端类型
     * @return Google用户信息
     */
    GoogleUserInfo verifyGoogleIdToken(String idToken, String clientType);
    
    /**
     * 生成Google授权URL
     * @return 授权URL
     */
    String getAuthorizationUrl();
}