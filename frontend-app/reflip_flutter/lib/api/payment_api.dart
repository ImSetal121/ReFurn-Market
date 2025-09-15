import '../models/payment_models.dart';
import '../utils/request.dart';

/// 支付相关API
class PaymentApi {
  /// 创建支付意图
  static Future<PaymentResponse?> createPaymentIntent(
    PaymentRequest paymentRequest,
  ) async {
    final data = await HttpRequest.post<Map<String, dynamic>>(
      '/payment/create-intent',
      data: paymentRequest.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return data != null ? PaymentResponse.fromJson(data) : null;
  }

  /// 获取支付状态
  static Future<String?> getPaymentStatus(String paymentIntentId) async {
    final data = await HttpRequest.get<String>(
      '/payment/status/$paymentIntentId',
      fromJson: (json) => json as String,
    );

    return data;
  }
}
