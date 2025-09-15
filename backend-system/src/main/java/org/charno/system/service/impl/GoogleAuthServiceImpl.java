package org.charno.system.service.impl;

import com.alibaba.fastjson2.JSON;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.charno.common.config.GoogleOAuth2Config;
import org.charno.common.dto.GoogleUserInfo;
import org.charno.common.entity.SysUser;
import org.charno.common.security.LoginUser;
import org.charno.common.utils.JwtUtils;
import org.charno.common.utils.RedisUtils;
import org.charno.common.utils.S3Utils;
import org.charno.system.mapper.SysUserMapper;
import org.charno.system.service.IGoogleAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;

import java.io.IOException;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalDateTime;
import java.util.Scanner;
import java.util.UUID;

@Service
public class GoogleAuthServiceImpl implements IGoogleAuthService {

    @Autowired
    private GoogleAuthorizationCodeFlow googleAuthFlow;

    @Autowired
    private GoogleOAuth2Config googleConfig;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private RedisUtils redisUtils;

    @Autowired
    private S3Utils s3Utils;

    @Override
    public GoogleUserInfo getGoogleUserInfo(String authCode) {
        try {
            // 1. 使用授权码获取访问令牌
            GoogleTokenResponse tokenResponse = googleAuthFlow
                    .newTokenRequest(authCode)
                    .setRedirectUri(googleConfig.getRedirectUri())
                    .execute();

            String accessToken = tokenResponse.getAccessToken();

            // 2. 使用访问令牌获取用户信息
            URL url = new URL("https://www.googleapis.com/oauth2/v2/userinfo?access_token=" + accessToken);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");

            Scanner scanner = new Scanner(connection.getInputStream());
            StringBuilder response = new StringBuilder();
            while (scanner.hasNextLine()) {
                response.append(scanner.nextLine());
            }
            scanner.close();

            // 3. 解析用户信息
            return JSON.parseObject(response.toString(), GoogleUserInfo.class);
            
        } catch (IOException e) {
            throw new RuntimeException("获取Google用户信息失败: " + e.getMessage(), e);
        }
    }

    @Override
    public LoginUser googleLogin(String authCode) {
        // 1. 获取Google用户信息
        GoogleUserInfo googleUserInfo = getGoogleUserInfo(authCode);
        
        if (googleUserInfo == null || googleUserInfo.getEmail() == null) {
            throw new RuntimeException("无法获取Google用户信息");
        }

        // 2. 查找用户
        SysUser user = findOrCreateUser(googleUserInfo);

        // 3. 生成token
        String token = jwtUtils.generateToken();

        // 4. 创建登录用户对象
        LoginUser loginUser = new LoginUser(user, token);

        // 5. 更新用户登录信息
        user.setLastLoginDate(LocalDateTime.now());
        userMapper.updateById(user);

        // 6. 存入Redis
        redisUtils.setLoginUser(token, loginUser);

        return loginUser;
    }

    @Override
    public LoginUser googleMobileLogin(String idToken, String clientType) {
        // 1. 验证ID Token并获取用户信息
        GoogleUserInfo googleUserInfo = verifyGoogleIdToken(idToken, clientType);
        
        if (googleUserInfo == null || googleUserInfo.getEmail() == null) {
            throw new RuntimeException("无法获取Google用户信息");
        }

        // 2. 查找用户
        SysUser user = findOrCreateUser(googleUserInfo);

        // 3. 生成token
        String token = jwtUtils.generateToken();

        // 4. 创建登录用户对象
        LoginUser loginUser = new LoginUser(user, token);

        // 5. 更新用户登录信息
        user.setLastLoginDate(LocalDateTime.now());
        userMapper.updateById(user);

        // 6. 存入Redis
        redisUtils.setLoginUser(token, loginUser);

        return loginUser;
    }

    @Override
    public GoogleUserInfo verifyGoogleIdToken(String idToken, String clientType) {
        try {
            // 使用Google API验证ID Token
            NetHttpTransport transport = new NetHttpTransport();
            GsonFactory jsonFactory = GsonFactory.getDefaultInstance();

            com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier verifier = 
                new com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier.Builder(transport, jsonFactory)
                    .setAudience(java.util.Collections.singletonList(getClientIdForType(clientType)))
                    .build();

            com.google.api.client.googleapis.auth.oauth2.GoogleIdToken googleIdToken = verifier.verify(idToken);
            
            if (googleIdToken != null) {
                com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload payload = googleIdToken.getPayload();
                
                // 创建GoogleUserInfo对象
                GoogleUserInfo userInfo = new GoogleUserInfo();
                userInfo.setId(payload.getSubject());
                userInfo.setEmail(payload.getEmail());
                userInfo.setName((String) payload.get("name"));
                userInfo.setGivenName((String) payload.get("given_name"));
                userInfo.setFamilyName((String) payload.get("family_name"));
                userInfo.setPicture((String) payload.get("picture"));
                userInfo.setEmailVerified(payload.getEmailVerified());
                
                return userInfo;
            } else {
                throw new RuntimeException("Invalid ID token");
            }
        } catch (Exception e) {
            throw new RuntimeException("验证Google ID Token失败: " + e.getMessage(), e);
        }
    }

    /**
     * 根据客户端类型获取对应的Client ID
     */
    private String getClientIdForType(String clientType) {
        switch (clientType.toLowerCase()) {
            case "ios":
                return googleConfig.getIosClientId();
            case "web":
            default:
                return googleConfig.getWebClientId();
        }
    }

    @Override
    public String getAuthorizationUrl() {
        return googleAuthFlow.newAuthorizationUrl()
                .setRedirectUri(googleConfig.getRedirectUri())
                .build();
    }

    private SysUser findOrCreateUser(GoogleUserInfo googleUserInfo) {
        // 1. 先通过googleSub查找
        QueryWrapper<SysUser> googleQuery = new QueryWrapper<>();
        googleQuery.eq("google_sub", googleUserInfo.getId())
                .eq("is_delete", false);
        SysUser existingUser = userMapper.selectOne(googleQuery);
        
        if (existingUser != null) {
            // 更新用户信息（包括头像）
            updateUserFromGoogle(existingUser, googleUserInfo);
            return existingUser;
        }

        // 2. 通过邮箱查找
        QueryWrapper<SysUser> emailQuery = new QueryWrapper<>();
        emailQuery.eq("email", googleUserInfo.getEmail())
                .eq("is_delete", false);
        existingUser = userMapper.selectOne(emailQuery);
        
        if (existingUser != null) {
            // 邮箱已存在但没有绑定Google，绑定Google账号
            existingUser.setGoogleSub(googleUserInfo.getId());
            updateUserFromGoogle(existingUser, googleUserInfo);
            return existingUser;
        }

        // 3. 创建新用户
        return createNewUserFromGoogle(googleUserInfo);
    }

    private void updateUserFromGoogle(SysUser user, GoogleUserInfo googleUserInfo) {
        // 更新用户信息
        if (googleUserInfo.getName() != null && (user.getNickname() == null || user.getNickname().isEmpty())) {
            user.setNickname(googleUserInfo.getName());
        }
        
        // 对于已存在的用户，不重新上传头像，保持用户当前的头像设置
        // 只绑定Google账号ID
        user.setGoogleSub(googleUserInfo.getId());
        userMapper.updateById(user);
        
        System.out.println("更新已存在用户的Google绑定信息，用户: " + user.getUsername());
    }

    private SysUser createNewUserFromGoogle(GoogleUserInfo googleUserInfo) {
        SysUser newUser = new SysUser();
        
        // 生成用户名（使用邮箱前缀）
        String username = generateUniqueUsername(googleUserInfo.getEmail());
        
        newUser.setUsername(username);
        newUser.setNickname(googleUserInfo.getName() != null ? googleUserInfo.getName() : username);
        newUser.setEmail(googleUserInfo.getEmail());
        newUser.setGoogleSub(googleUserInfo.getId());
        
        // 只在创建新用户时下载并上传Google头像到S3
        if (googleUserInfo.getPicture() != null && !googleUserInfo.getPicture().isEmpty()) {
            System.out.println("正在为新用户下载并上传Google头像: " + username);
            String s3AvatarUrl = downloadAndUploadAvatar(googleUserInfo.getPicture(), username);
            if (s3AvatarUrl != null) {
                newUser.setAvatar(s3AvatarUrl);
                System.out.println("新用户头像上传成功: " + username);
            } else {
                System.out.println("新用户头像上传失败，将使用默认头像: " + username);
            }
        }
        
        newUser.setCreateTime(LocalDateTime.now());
        newUser.setIsDelete(false);
        newUser.setRoleId(1); // 默认角色

        userMapper.insert(newUser);
        System.out.println("创建新的Google用户: " + username);
        return newUser;
    }

    /**
     * 下载Google头像并上传到S3
     * @param googleAvatarUrl Google头像URL
     * @param username 用户名
     * @return S3头像URL，如果失败返回null
     */
    private String downloadAndUploadAvatar(String googleAvatarUrl, String username) {
        try {
            // 1. 下载Google头像
            URL url = new URL(googleAvatarUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(10000); // 10秒超时
            connection.setReadTimeout(10000);
            
            // 设置User-Agent避免被拒绝
            connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36");
            
            if (connection.getResponseCode() != 200) {
                System.err.println("下载Google头像失败，响应码: " + connection.getResponseCode());
                return null;
            }

            // 2. 完整读取图片数据到字节数组
            InputStream inputStream = connection.getInputStream();
            byte[] imageData = readAllBytes(inputStream);
            inputStream.close();
            connection.disconnect();
            
            if (imageData.length == 0) {
                System.err.println("下载的图片数据为空");
                return null;
            }
            
            System.out.println("成功下载Google头像，大小: " + imageData.length + " 字节");
            
            // 3. 生成文件名
            String fileExtension = getFileExtension(googleAvatarUrl);
            String fileName = "avatars/google/" + username + "_" + UUID.randomUUID().toString().substring(0, 8) + fileExtension;
            
            // 4. 上传到S3
            String s3Url = s3Utils.uploadImageFromBytes(imageData, fileName, getContentType(fileExtension));
            
            System.out.println("成功上传Google头像到S3: " + s3Url);
            return s3Url;
            
        } catch (Exception e) {
            System.err.println("下载并上传Google头像失败: " + e.getMessage());
            e.printStackTrace();
            // 发生错误时返回null，用户将使用默认头像
            return null;
        }
    }

    /**
     * 读取InputStream中的所有字节
     */
    private byte[] readAllBytes(InputStream inputStream) throws IOException {
        byte[] buffer = new byte[8192];
        int bytesRead;
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        
        while ((bytesRead = inputStream.read(buffer)) != -1) {
            outputStream.write(buffer, 0, bytesRead);
        }
        
        return outputStream.toByteArray();
    }

    /**
     * 根据URL获取文件扩展名
     */
    private String getFileExtension(String url) {
        try {
            // Google头像URL通常没有明确的扩展名，默认使用.jpg
            if (url.contains(".png")) {
                return ".png";
            } else if (url.contains(".gif")) {
                return ".gif";
            } else if (url.contains(".webp")) {
                return ".webp";
            } else {
                return ".jpg"; // 默认
            }
        } catch (Exception e) {
            return ".jpg";
        }
    }

    /**
     * 根据文件扩展名获取Content-Type
     */
    private String getContentType(String extension) {
        switch (extension.toLowerCase()) {
            case ".png":
                return "image/png";
            case ".gif":
                return "image/gif";
            case ".webp":
                return "image/webp";
            case ".jpg":
            case ".jpeg":
            default:
                return "image/jpeg";
        }
    }

    private String generateUniqueUsername(String email) {
        String baseUsername = email.split("@")[0];
        String username = baseUsername;
        int counter = 1;

        // 检查用户名是否已存在，如果存在则添加数字后缀
        while (isUsernameExists(username)) {
            username = baseUsername + counter;
            counter++;
        }

        return username;
    }

    private boolean isUsernameExists(String username) {
        QueryWrapper<SysUser> query = new QueryWrapper<>();
        query.eq("username", username).eq("is_delete", false);
        return userMapper.exists(query);
    }
}