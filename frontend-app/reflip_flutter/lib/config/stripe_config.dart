/// Stripe配置类
class StripeConfig {
  // 开发环境密钥
  static const String _testPublishableKey =
      'pk_test_51RVwLEQ5plwmdabORL2Y8wjd8pSZqxkjBB4Bry3MLxsDaPdRmoAfzYrrg4lFWY2YpCqBEqNPIyWVSF3kgaEz6qgw00KkGql2kB';

  // 生产环境密钥
  static const String _livePublishableKey =
      'pk_live_your_stripe_publishable_key_here';

  /// 获取当前环境对应的Publishable Key
  static String get publishableKey {
    // 这里可以根据环境变量或配置来决定使用哪个密钥
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? _livePublishableKey : _testPublishableKey;
  }

  /// 是否为测试环境
  static bool get isTestMode => !bool.fromEnvironment('dart.vm.product');
}
