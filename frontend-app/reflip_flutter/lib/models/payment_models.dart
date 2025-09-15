/// 支付请求模型
class PaymentRequest {
  final int productId;
  final double amount;
  final String currency;
  final String description;

  PaymentRequest({
    required this.productId,
    required this.amount,
    this.currency = 'usd',
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'amount': amount,
      'currency': currency,
      'description': description,
    };
  }
}

/// 支付响应模型
class PaymentResponse {
  final String paymentIntentId;
  final String clientSecret;
  final String status;

  PaymentResponse({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentIntentId: json['paymentIntentId'] as String,
      clientSecret: json['clientSecret'] as String,
      status: json['status'] as String,
    );
  }
}
