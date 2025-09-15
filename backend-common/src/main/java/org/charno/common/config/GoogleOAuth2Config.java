package org.charno.common.config;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;
import java.util.List;

@Configuration
public class GoogleOAuth2Config {

    // Web客户端配置
    @Value("${google.oauth2.web.client-id}")
    private String webClientId;

    @Value("${google.oauth2.web.client-secret}")
    private String webClientSecret;

    @Value("${google.oauth2.web.redirect-uri}")
    private String webRedirectUri;

    // iOS客户端配置
    @Value("${google.oauth2.ios.client-id}")
    private String iosClientId;

    // 通用作用域配置 - 使用字符串接收，然后转换为List
    @Value("${google.oauth2.scopes}")
    private String scopesString;

    @Bean
    public GoogleClientSecrets googleClientSecrets() {
        GoogleClientSecrets.Details details = new GoogleClientSecrets.Details();
        details.setClientId(webClientId);
        details.setClientSecret(webClientSecret);

        GoogleClientSecrets clientSecrets = new GoogleClientSecrets();
        clientSecrets.setInstalled(details);
        return clientSecrets;
    }

    @Bean
    public GoogleAuthorizationCodeFlow googleAuthorizationCodeFlow(GoogleClientSecrets clientSecrets) {
        return new GoogleAuthorizationCodeFlow.Builder(
                new NetHttpTransport(),
                GsonFactory.getDefaultInstance(),
                clientSecrets,
                getScopes())
                .setAccessType("offline")
                .setApprovalPrompt("force")
                .build();
    }

    // Web客户端相关的getter方法
    public String getWebClientId() {
        return webClientId;
    }

    public String getWebClientSecret() {
        return webClientSecret;
    }

    public String getWebRedirectUri() {
        return webRedirectUri;
    }

    // iOS客户端相关的getter方法
    public String getIosClientId() {
        return iosClientId;
    }

    public List<String> getScopes() {
        if (scopesString != null && !scopesString.trim().isEmpty()) {
            return Arrays.asList(scopesString.split(","));
        }
        // 默认作用域
        return Arrays.asList("openid", "email", "profile");
    }

    // 兼容性方法（保持现有代码可用）
    public String getRedirectUri() {
        return webRedirectUri;
    }
} 