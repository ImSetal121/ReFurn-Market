import 'dart:io';
import 'package:flutter/foundation.dart';

/// API配置类 - 集中管理不同环境的API地址
class ApiConfig {
  // 生产环境API地址
  static const String _productionBaseUrl = 'https://api.reflip.com';

  // 测试环境API地址
  static const String _stagingBaseUrl = 'https://test-api.reflip.com';

  // 本地开发服务器地址（模拟器用）
  static const String _localBaseUrl = 'http://localhost:8080';

  // 局域网开发服务器地址（真机调试用）
  // 请根据您的实际开发环境修改这个IP地址
  static const String _deviceDebugBaseUrl = 'http://192.168.0.100:8080';

  /// 获取当前环境对应的API基础URL
  static String get baseUrl {
    // 1. 优先使用环境变量设置的地址
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // 2. 根据运行模式自动选择
    if (kReleaseMode) {
      // 发布模式：使用生产环境
      return _productionBaseUrl;
    } else if (kDebugMode) {
      // 调试模式：区分模拟器和真机
      if (_isRunningOnEmulator()) {
        return _localBaseUrl;
      } else {
        return _deviceDebugBaseUrl;
      }
    } else {
      // Profile模式：使用测试环境
      return _stagingBaseUrl;
    }
  }

  /// 获取当前环境名称（用于日志输出）
  static String get environmentName {
    if (kReleaseMode) return 'Production';
    if (kDebugMode) {
      return _isRunningOnEmulator() ? 'Debug (Simulator)' : 'Debug (Device)';
    }
    return 'Profile/Staging';
  }

  /// 检测是否运行在模拟器/仿真器上
  static bool _isRunningOnEmulator() {
    if (Platform.isAndroid) {
      // Android模拟器检测
      return Platform.environment.containsKey(
            'ANDROID_EMU_CONSOLE_AUTH_TOKEN',
          ) ||
          Platform.environment['HOSTNAME']?.contains('localhost') == true ||
          Platform.environment['ANDROID_ROOT']?.contains('system') == true;
    } else if (Platform.isIOS) {
      // iOS模拟器检测
      return Platform.environment['SIMULATOR_DEVICE_NAME'] != null ||
          Platform.environment['HOME']?.contains('CoreSimulator') == true;
    }
    return false;
  }

  /// 是否为调试环境
  static bool get isDebugEnvironment => kDebugMode;

  /// 是否为生产环境
  static bool get isProductionEnvironment => kReleaseMode;

  /// 是否运行在模拟器上
  static bool get isEmulator => _isRunningOnEmulator();

  /// 打印当前环境信息
  static void printEnvironmentInfo() {
    print('🌐 API Base URL: $baseUrl');
    print('📱 Environment: $environmentName');
    print(
      '🔧 Device Type: ${isEmulator ? 'Simulator/Emulator' : 'Physical Device'}',
    );
    print('🐛 Debug Mode: ${kDebugMode ? 'Enabled' : 'Disabled'}');
    print('🚀 Release Mode: ${kReleaseMode ? 'Enabled' : 'Disabled'}');
  }
}
