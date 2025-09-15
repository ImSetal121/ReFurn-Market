import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import '../api/payment_api.dart';
import '../api/buyer_api.dart';
import '../api/user_api.dart';
import '../api/balance_api.dart';
import '../models/payment_models.dart';
import '../config/stripe_config.dart';

class StripeService {
  /// 初始化Stripe
  static Future<void> init() async {
    Stripe.publishableKey = StripeConfig.publishableKey;
  }

  /// 处理支付
  static Future<bool> processPayment({
    required int productId,
    required double amount,
    required String productName,
    required BuildContext context,
    bool isConsignment = false,
    String? deliveryAddress,
    String? deliveryPhone,
    String? deliveryName,
  }) async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFA500)),
        ),
      );

      // 1. 创建支付请求
      final paymentRequest = PaymentRequest(
        productId: productId,
        amount: amount,
        description: 'Purchase: $productName',
      );

      // 2. 调用後端創建PaymentIntent
      final paymentResponse = await PaymentApi.createPaymentIntent(
        paymentRequest,
      );

      if (paymentResponse == null) {
        Navigator.pop(context); // 关闭加载指示器
        _showErrorSnackBar(context, '创建支付失败，请重试');
        return false;
      }

      // 3. 初始化支付界面
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentResponse.clientSecret,
          merchantDisplayName: 'ReFlip',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFFFA500),
                  text: Colors.white,
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFFFA500),
                  text: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );

      Navigator.pop(context); // 关闭加载指示器

      // 4. 显示支付界面
      await Stripe.instance.presentPaymentSheet();

      // 5. 支付成功
      _showSuccessSnackBar(context, '支付成功！');

      // 6. 根据商品类型调用相应的购买成功处理
      bool purchaseSuccess;
      if (isConsignment) {
        // 寄卖商品处理
        if (deliveryAddress == null ||
            deliveryPhone == null ||
            deliveryName == null) {
          _showErrorSnackBar(context, '寄卖商品缺少必要的收货信息');
          return false;
        }
        purchaseSuccess = await BuyerApi.handleConsignmentPurchaseSuccess(
          productId,
          paymentResponse.paymentIntentId,
          deliveryAddress,
          deliveryPhone,
          deliveryName,
        );
      } else {
        // 普通商品处理
        purchaseSuccess = await BuyerApi.handlePurchaseSuccess(
          productId,
          paymentResponse.paymentIntentId,
        );
      }

      if (!purchaseSuccess) {
        _showErrorSnackBar(context, '支付成功但订单处理失败，请联系客服');
      }

      return true;
    } on StripeException catch (e) {
      Navigator.pop(context); // 确保关闭加载指示器

      // 处理不同的Stripe错误
      String errorMessage = '支付失败';
      switch (e.error.code) {
        case FailureCode.Canceled:
          errorMessage = '支付已取消';
          break;
        case FailureCode.Failed:
          errorMessage = '支付失败，请检查支付信息';
          break;
        case FailureCode.Timeout:
          errorMessage = '支付超时，请重试';
          break;
        default:
          errorMessage = e.error.localizedMessage ?? '支付出现未知错误';
      }

      _showErrorSnackBar(context, errorMessage);
      return false;
    } catch (e) {
      Navigator.pop(context); // 确保关闭加载指示器
      _showErrorSnackBar(context, '支付过程中发生错误：${e.toString()}');
      return false;
    }
  }

  /// 处理账单支付
  static Future<bool> processBillPayment({
    required int billId,
    required double amount,
    required String billDescription,
    required BuildContext context,
  }) async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFA500)),
        ),
      );

      // 1. 创建支付请求
      final paymentRequest = PaymentRequest(
        productId: billId, // 使用billId作为productId
        amount: amount,
        description: 'Bill Payment: $billDescription',
      );

      // 2. 调用後端創建PaymentIntent
      final paymentResponse = await PaymentApi.createPaymentIntent(
        paymentRequest,
      );

      if (paymentResponse == null) {
        Navigator.pop(context); // 关闭加载指示器
        _showErrorSnackBar(context, '创建支付失败，请重试');
        return false;
      }

      // 3. 初始化支付界面
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentResponse.clientSecret,
          merchantDisplayName: 'ReFlip',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFFFA500),
                  text: Colors.white,
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFFFA500),
                  text: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );

      Navigator.pop(context); // 关闭加载指示器

      // 4. 显示支付界面
      await Stripe.instance.presentPaymentSheet();

      // 5. 支付成功
      _showSuccessSnackBar(context, '支付成功！');

      // 6. 调用账单支付成功接口
      bool paymentSuccess = await UserApi.handleBillPaymentSuccess(
        billId,
        paymentResponse.paymentIntentId,
      );

      if (!paymentSuccess) {
        _showErrorSnackBar(context, '支付成功但账单状态更新失败，请联系客服');
      }

      return true;
    } on StripeException catch (e) {
      Navigator.pop(context); // 确保关闭加载指示器

      // 处理不同的Stripe错误
      String errorMessage = '支付失败';
      switch (e.error.code) {
        case FailureCode.Canceled:
          errorMessage = '支付已取消';
          break;
        case FailureCode.Failed:
          errorMessage = '支付失败，请检查支付信息';
          break;
        case FailureCode.Timeout:
          errorMessage = '支付超时，请重试';
          break;
        default:
          errorMessage = e.error.localizedMessage ?? '支付出现未知错误';
      }

      _showErrorSnackBar(context, errorMessage);
      return false;
    } catch (e) {
      Navigator.pop(context); // 确保关闭加载指示器
      _showErrorSnackBar(context, '支付过程中发生错误：${e.toString()}');
      return false;
    }
  }

  /// 显示成功提示
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 处理充值支付
  static Future<bool> processRecharge({
    required double amount,
    required BuildContext context,
  }) async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFA500)),
        ),
      );

      // 1. 创建充值支付请求
      final paymentRequest = PaymentRequest(
        productId: 0, // 充值不关联商品，使用0作为标识
        amount: amount,
        description: 'Wallet Recharge: \$${amount.toStringAsFixed(2)}',
      );

      // 2. 调用後端創建PaymentIntent
      final paymentResponse = await PaymentApi.createPaymentIntent(
        paymentRequest,
      );

      if (paymentResponse == null) {
        Navigator.pop(context); // 关闭加载指示器
        _showErrorSnackBar(context, '创建支付失败，请重试');
        return false;
      }

      // 3. 初始化支付界面
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentResponse.clientSecret,
          merchantDisplayName: 'ReFlip',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFFFA500),
                  text: Colors.white,
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFFFA500),
                  text: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );

      Navigator.pop(context); // 关闭加载指示器

      // 4. 显示支付界面
      await Stripe.instance.presentPaymentSheet();

      // 5. 支付成功
      _showSuccessSnackBar(context, '充值成功！');

      // 6. 调用充值成功接口
      bool rechargeSuccess = await BalanceApi.handleRechargeSuccess(
        amount,
        paymentResponse.paymentIntentId,
      );

      if (!rechargeSuccess) {
        _showErrorSnackBar(context, '支付成功但余额更新失败，请联系客服');
      }

      return true;
    } on StripeException catch (e) {
      Navigator.pop(context); // 确保关闭加载指示器

      // 处理不同的Stripe错误
      String errorMessage = '充值失败';
      switch (e.error.code) {
        case FailureCode.Canceled:
          errorMessage = '充值已取消';
          break;
        case FailureCode.Failed:
          errorMessage = '支付失败，请检查支付信息';
          break;
        case FailureCode.Timeout:
          errorMessage = '支付超时，请重试';
          break;
        default:
          errorMessage = e.error.localizedMessage ?? '支付出现未知错误';
      }

      _showErrorSnackBar(context, errorMessage);
      return false;
    } catch (e) {
      Navigator.pop(context); // 确保关闭加载指示器
      _showErrorSnackBar(context, '充值过程中发生错误：${e.toString()}');
      return false;
    }
  }

  /// 显示错误提示
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
