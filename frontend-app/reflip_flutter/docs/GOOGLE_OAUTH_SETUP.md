# Google OAuth 配置指南

## 📋 概述

本文档说明如何为ReFlip Flutter应用配置Google OAuth登录功能，支持Web端和移动端（iOS）的完整登录流程。

## 🔧 后端配置

### 1. 环境变量设置

在后端的 `application.yaml` 文件中，配置多平台OAuth客户端：

```yaml
google:
  oauth2:
    # Web客户端配置
    web:
      client-id: ${GOOGLE_OAUTH2_WEB_CLIENT_ID}
      client-secret: ${GOOGLE_OAUTH2_WEB_CLIENT_SECRET}
      redirect-uri: ${GOOGLE_OAUTH2_WEB_REDIRECT_URI}
    # iOS客户端配置
    ios:
      client-id: ${GOOGLE_OAUTH2_IOS_CLIENT_ID}
    # 通用配置 - 使用逗号分隔的字符串格式
    scopes: ${GOOGLE_OAUTH2_SCOPES}
```

### 2. 环境变量说明

- `GOOGLE_OAUTH2_WEB_CLIENT_ID`: Web应用的Google OAuth客户端ID（例如：`your-web-client-id.apps.googleusercontent.com`）
- `GOOGLE_OAUTH2_WEB_CLIENT_SECRET`: Web应用的Google OAuth客户端密钥（例如：`your-web-client-secret`）
- `GOOGLE_OAUTH2_WEB_REDIRECT_URI`: Web应用的重定向URI
- `GOOGLE_OAUTH2_IOS_CLIENT_ID`: iOS应用的Google OAuth客户端ID（例如：`your-ios-client-id.apps.googleusercontent.com`）
- `GOOGLE_OAUTH2_SCOPES`: OAuth作用域，逗号分隔（例如：`openid,email,profile`）

### 3. 安全配置

确保在 `WebSecurityConfig.java` 中放行移动端登录API：

```java
.authorizeHttpRequests(auth -> auth
    .requestMatchers("/auth/login", "/auth/register", 
                   "/auth/google/authorization-url", "/auth/google/login",
                   "/auth/google/mobile-login").permitAll()
    .anyRequest().authenticated())
```

## 📱 Flutter前端配置

### 1. 依赖管理

在 `pubspec.yaml` 中添加Google Sign In依赖：

```yaml
dependencies:
  google_sign_in: ^6.2.1
```

运行 `flutter pub get` 安装依赖。

### 2. 服务层实现

项目已实现以下核心组件：

- `GoogleAuthService`: Google认证服务，处理登录、登出逻辑
- `GoogleSignInButton`: 可复用的Google登录按钮组件
- 集成到 `AuthPortalPage` 和 `SignInEmailPage`

### 3. 退出登录集成

在设置页面中，退出登录会同时清除：
- 后端session (调用 `/auth/logout`)
- Google登录凭证 (调用 `GoogleAuthService.signOut()`)
- 本地认证状态 (清除本地token)

## 🍎 iOS配置

### 1. 获取iOS客户端ID

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 选择您的项目
3. 转到 "APIs & Services" > "Credentials"
4. 创建新的OAuth 2.0客户端ID
5. 选择 "iOS" 作为应用类型
6. 输入您的Bundle ID（例如：`com.example.reflipFlutter`）
7. 下载配置文件或复制客户端ID

### 2. 创建GoogleService-Info.plist

在 `ios/Runner/` 目录下创建 `GoogleService-Info.plist` 文件：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>your-ios-client-id.apps.googleusercontent.com</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>com.googleusercontent.apps.your-ios-client-id</string>
    <key>API_KEY</key>
    <string>your-ios-api-key</string>
    <key>GCM_SENDER_ID</key>
    <string>your-gcm-sender-id</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.example.reflipFlutter</string>
    <key>PROJECT_ID</key>
    <string>reflip-project</string>
    <key>STORAGE_BUCKET</key>
    <string>reflip-project.appspot.com</string>
    <key>IS_ADS_ENABLED</key>
    <false/>
    <key>IS_ANALYTICS_ENABLED</key>
    <false/>
    <key>IS_APPINVITE_ENABLED</key>
    <true/>
    <key>IS_GCM_ENABLED</key>
    <true/>
    <key>IS_SIGNIN_ENABLED</key>
    <true/>
    <key>GOOGLE_APP_ID</key>
    <string>1:your-project-id:ios:dummy</string>
</dict>
</plist>
```

### 3. 更新Info.plist配置

在 `ios/Runner/Info.plist` 中添加：

```xml
<!-- Google Sign In配置 -->
<key>GIDClientID</key>
<string>your-ios-client-id.apps.googleusercontent.com</string>

<!-- Google Sign In URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.your-ios-client-id</string>
        </array>
    </dict>
</array>
```

### 4. URL Scheme说明

URL Scheme必须使用 `REVERSED_CLIENT_ID` 的值：
- 如果客户端ID是：`your-ios-client-id.apps.googleusercontent.com`
- 则URL scheme应该是：`com.googleusercontent.apps.your-ios-client-id`

## 🔄 API端点

### Web端Google登录 (现有)

```
GET /auth/google/authorization-url
POST /auth/google/login
```

### 移动端Google登录 (新增)

```
POST /auth/google/mobile-login
Content-Type: application/json

{
  "idToken": "google_id_token_here",
  "clientType": "ios"
}
```

### 响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": 1,
      "username": "user@example.com",
      "email": "user@example.com",
      "nickname": "User Name",
      "avatar": "https://s3-url/avatar.jpg",
      "googleSub": "google_user_id"
    },
    "isNewUser": false
  }
}
```

## 🧪 测试步骤

### 1. 后端测试

1. 启动后端服务
2. 确保以下端点可访问：
   - `GET /auth/google/authorization-url` (Web端)
   - `POST /auth/google/mobile-login` (移动端)

### 2. Flutter测试

1. **清理并重新构建**：
   ```bash
   flutter clean
   flutter pub get
   ```

2. **运行应用**：
   ```bash
   flutter run
   ```

3. **测试流程**：
   - 点击Google登录按钮
   - 完成Google授权
   - 验证登录成功
   - 测试退出登录功能

## 🚨 常见问题和解决方案

### 1. 后端启动错误

**问题**: `Could not resolve placeholder 'google.oauth2.scopes'`

**解决方案**: 确保使用逗号分隔的字符串格式：
```yaml
scopes: ${GOOGLE_OAUTH2_SCOPES}
```

### 2. iOS模拟器闪退

**问题**: 点击Google登录直接闪退

**解决方案**:
- 确保创建了 `GoogleService-Info.plist` 文件
- 检查 `Info.plist` 中的配置是否正确
- 建议在真机上测试（iOS模拟器对认证有限制）

### 3. 安全配置错误

**问题**: 移动端登录请求被拦截（401错误）

**解决方案**: 确保在 `WebSecurityConfig.java` 中添加了 `/auth/google/mobile-login` 到 `permitAll()` 列表

### 4. Google登录失败

**常见原因**:
- 网络连接问题
- 客户端ID配置错误
- URL scheme配置错误
- 后端ID Token验证失败

**调试步骤**:
1. 查看Flutter控制台日志（现在有详细的调试信息）
2. 检查后端服务日志
3. 验证Google Cloud Console配置
4. 确认网络连接和API可达性

## 🔍 调试信息

### Flutter端日志

Google登录过程中会输出详细日志：
```
GoogleAuthService: 开始Google登录流程
GoogleAuthService: 运行在iOS平台
GoogleAuthService: 调用googleSignIn.signIn()
GoogleAuthService: 用户选择了账户: user@example.com
GoogleAuthService: 获取认证详情
GoogleAuthService: 成功获取ID Token
GoogleAuthService: 调用后端API登录
GoogleAuthService: 登录成功
```

### 退出登录日志

```
Backend logout failed: [错误信息] (如果后端登出失败)
Google登录凭证已清除
本地认证状态已清除
```

## 🎯 最佳实践

1. **测试环境**: 优先在真机上测试Google登录功能
2. **错误处理**: 已实现完整的错误处理和用户反馈
3. **安全性**: 登录状态在后端、Google服务和本地都有对应的管理
4. **用户体验**: 提供加载状态和成功/失败提示
5. **调试**: 详细的日志输出便于问题排查

## 📝 注意事项

1. **Bundle ID一致性**: 确保Google Console、Xcode项目和配置文件中的Bundle ID一致
2. **客户端ID匹配**: 前端配置的客户端ID必须与后端配置的一致
3. **网络权限**: 确保应用有网络访问权限
4. **版本兼容**: 使用的google_sign_in版本与Flutter版本兼容
5. **生产环境**: 生产环境需要使用真实的API Key和配置（请不要将任何真实密钥提交到仓库）

通过以上配置，您的ReFlip Flutter应用就具备了完整的Google OAuth登录功能！ 