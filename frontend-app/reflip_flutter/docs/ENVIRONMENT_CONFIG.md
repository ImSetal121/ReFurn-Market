# 环境配置说明

本项目支持根据不同的运行环境自动切换API地址，无需手动修改代码。

## 🌐 环境分类

### 1. 模拟器调试 (Debug - Simulator)
- **API地址**: `http://localhost:8080`
- **适用场景**: 在Android模拟器或iOS模拟器上运行
- **检测方式**: 自动检测模拟器环境变量

### 2. 真机调试 (Debug - Physical Device)
- **API地址**: `http://192.168.1.100:8080` 
- **适用场景**: 在真实设备上进行调试
- **注意**: 请在 `lib/config/api_config.dart` 中修改 `_deviceDebugBaseUrl` 为您的开发服务器实际IP地址

### 3. 发布模式 (Release - Production)
- **API地址**: `https://api.reflip.com`
- **适用场景**: 正式发布的应用
- **注意**: 请确保生产环境API地址正确

### 4. Profile模式 (Profile - Staging)
- **API地址**: `https://test-api.reflip.com`
- **适用场景**: 性能测试或预发布环境

## 🔧 使用方法

### 方法一：自动检测（推荐）
直接运行Flutter应用，系统会自动检测当前环境并选择对应的API地址：

```bash
# 调试模式运行
flutter run

# 发布模式运行
flutter run --release

# Profile模式运行
flutter run --profile
```

### 方法二：环境变量覆盖
如果需要临时使用特定的API地址，可以通过环境变量覆盖：

```bash
# 使用自定义API地址运行
flutter run --dart-define=API_BASE_URL=https://custom-api.example.com
```

## ⚙️ 配置修改

如需修改各环境的API地址，请编辑 `lib/config/api_config.dart` 文件：

```dart
class ApiConfig {
  // 生产环境API地址
  static const String _productionBaseUrl = 'https://api.reflip.com';
  
  // 测试环境API地址  
  static const String _stagingBaseUrl = 'https://test-api.reflip.com';
  
  // 本地开发服务器地址（模拟器用）
  static const String _localBaseUrl = 'http://localhost:8080';
  
  // 局域网开发服务器地址（真机调试用）
  // ⚠️ 请修改为您的开发服务器实际IP地址
  static const String _deviceDebugBaseUrl = 'http://192.168.1.100:8080';
}
```

## 📝 调试信息

应用启动时会在控制台输出当前环境信息：

```
🌐 API Base URL: http://localhost:8080
📱 Environment: Debug (Simulator)
🔧 Device Type: Simulator/Emulator
🐛 Debug Mode: Enabled
🚀 Release Mode: Disabled
```

## 🚨 注意事项

1. **真机调试**: 请确保开发服务器的IP地址配置正确，且设备与服务器在同一网络
2. **网络安全**: 在生产环境中请使用HTTPS协议
3. **防火墙**: 确保开发服务器端口没有被防火墙阻止
4. **跨域问题**: 如果遇到CORS问题，请在后端服务器配置允许跨域请求

## 🔍 故障排除

如果遇到网络连接问题：

1. 检查API地址是否正确
2. 确认设备网络连接正常
3. 查看控制台输出的环境信息
4. 尝试在浏览器中直接访问API地址 