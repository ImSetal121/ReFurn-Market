import 'package:flutter/material.dart';
import '../pages/sign_in_email_page.dart';
import '../pages/main_layout_page.dart';
import '../pages/settings_page.dart';
import '../pages/auth_portal_page.dart';
import '../pages/list_item_page.dart';
import '../pages/list_item_details_page.dart';
import '../pages/pickup_scheduling_page.dart';
import '../pages/add_address_page.dart';
import '../pages/listing_success_page.dart';
import '../pages/my_post_page.dart';
import '../pages/my_order_page.dart';
import '../pages/product_detail_page.dart';
import '../pages/order_confirmation_consignment_page.dart';
import '../pages/order_confirmation_shipping_page.dart';
import '../pages/my_sales_page.dart';
import '../pages/refund_application_page.dart';
import '../pages/return_request_detail_page.dart';
import '../pages/confirm_return_to_seller_page.dart';
import '../pages/chat_conversation_page.dart';
import '../pages/my_bill_page.dart';
import '../pages/bill_detail_page.dart';
import '../pages/profile_page.dart';
import '../pages/my_wallet_page.dart';
import '../pages/withdrawal_page.dart';
import '../pages/recharge_page.dart';
import '../pages/my_favorite_products_page.dart';
import '../pages/my_browse_history_page.dart';
import '../models/user_address.dart';
import 'route_guard.dart';

/// 应用程序路由管理类
class AppRoutes {
  /// 是否需要认证的路由列表
  static final List<String> _authenticatedRoutes = [
    listItem, // 发布商品页面需要用户登录
    listItemDetails, // 发布商品详情页面需要用户登录
    pickupScheduling, // 预约取货页面需要用户登录
    addAddress, // 添加地址页面需要用户登录
    refundApplication, // 退货申请页面需要用户登录
    returnRequestDetail, // 退货申请详情页面需要用户登录
    confirmReturnToSeller, // 确认退回卖家页面需要用户登录
    // 移动应用采用按需登录策略，其他页面不在路由级别强制登录
    // 具体的登录检查在组件内部进行
  ];

  /// 路由名称常量
  static const String authPortal = '/auth-portal';
  static const String signInEmail = '/sign-in-email';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String listItem = '/list-item';
  static const String listItemDetails = '/list-item-details';
  static const String pickupScheduling = '/pickup-scheduling';
  static const String addAddress = '/add-address';
  static const String listingSuccess = '/listing-success';
  static const String myPost = '/my-post';
  static const String myOrders = '/my-orders';
  static const String mySales = '/my-sales';
  static const String myBill = '/my-bill';
  static const String myWallet = '/my-wallet';
  static const String withdrawal = '/withdrawal';
  static const String recharge = '/recharge';
  static const String myFavoriteProducts = '/my-favorite-products';
  static const String myBrowseHistory = '/my-browse-history';
  static const String productDetail = '/product-detail';
  static const String consignmentOrderConfirmation =
      '/consignment-order-confirmation';
  static const String shippingOrderConfirmation =
      '/shipping-order-confirmation';
  static const String refundApplication = '/refund-application';
  static const String returnRequestDetail = '/return-request-detail';
  static const String confirmReturnToSeller = '/confirm-return-to-seller';
  static const String chatConversation = '/chat-conversation';
  static const String billDetail = '/bill-detail';
  static const String sellerProfile = '/seller-profile';

  /// 初始路由 - 移动应用默认进入首页
  static String initialRoute(bool isLoggedIn) {
    return home; // 始终进入首页，不管是否登录
  }

  /// 路由表
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const MainLayoutPage(), // 根路由
    authPortal: (context) => const AuthPortalPage(),
    signInEmail: (context) => const SignInEmailPage(),
    home: (context) => const MainLayoutPage(),
    settings: (context) => const SettingsPage(),
    listingSuccess: (context) => const ListingSuccessPage(),
    myPost: (context) => const MyPostPage(),
    myOrders: (context) => const MyOrderPage(),
    mySales: (context) => const MySalesPage(),
    myBill: (context) => const MyBillPage(),
    myWallet: (context) => const MyWalletPage(),
    withdrawal: (context) => const WithdrawalPage(),
    recharge: (context) => const RechargePage(),
    myFavoriteProducts: (context) => const MyFavoriteProductsPage(),
    myBrowseHistory: (context) => const MyBrowseHistoryPage(),
    productDetail: (context) => const ProductDetailPage(),
    consignmentOrderConfirmation: (context) =>
        const OrderConfirmationConsignmentPage(),
    shippingOrderConfirmation: (context) =>
        const OrderConfirmationShippingPage(),
    // listItem 路由移除，通过 onGenerateRoute 处理以进行认证检查
  };

  /// 路由生成器，用于处理未在路由表中定义的路由
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    print('路由生成器处理: $routeName');

    // 如果路由名称为空，返回未知路由
    if (routeName == null) {
      return onUnknownRoute(settings);
    }

    // 获取路由构建器（首先从常规路由表中查找）
    WidgetBuilder? builder = routes[routeName];

    // 如果在常规路由表中没有找到，检查是否是需要认证的路由
    if (builder == null && _authenticatedRoutes.contains(routeName)) {
      print('找到需要认证的路由: $routeName');
      // 为需要认证的路由提供构建器
      switch (routeName) {
        case listItem:
          builder = (context) => const ListItemPage();
          break;
        case listItemDetails:
          builder = (context) => const ListItemDetailsPage();
          break;
        case pickupScheduling:
          builder = (context) => const PickupSchedulingPage();
          break;
        case addAddress:
          final args = settings.arguments as Map<String, dynamic>?;
          final existingAddress = args?['existingAddress'] as UserAddress?;
          builder = (context) =>
              AddAddressPage(existingAddress: existingAddress);
          break;
        case refundApplication:
          final args = settings.arguments as Map<String, dynamic>?;
          final orderId = args?['orderId'] as String?;
          if (orderId != null) {
            builder = (context) => RefundApplicationPage(orderId: orderId);
          }
          break;
        case returnRequestDetail:
          final args = settings.arguments as Map<String, dynamic>?;
          final sellRecordId = args?['sellRecordId'] as String?;
          if (sellRecordId != null) {
            builder = (context) =>
                ReturnRequestDetailPage(sellRecordId: sellRecordId);
          }
          break;
        case confirmReturnToSeller:
          builder = (context) => const ConfirmReturnToSellerPage();
          break;
      }
    }

    // 处理聊天对话页面路由
    if (builder == null && routeName == chatConversation) {
      final args = settings.arguments as Map<String, dynamic>?;
      final userId = args?['userId'] as int?;
      final userName = args?['userName'] as String? ?? 'Unknown User';
      final userAvatar = args?['userAvatar'] as String?;
      final productId = args?['productId'] as int?;
      final productInfo = args?['productInfo'] as Map<String, dynamic>?;
      builder = (context) => ChatConversationPage(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        productId: productId,
        productInfo: productInfo,
      );
    }

    // 处理账单详情页面路由
    if (builder == null && routeName == billDetail) {
      final args = settings.arguments as Map<String, dynamic>?;
      final billId = args?['billId'] as int?;
      if (billId != null) {
        builder = (context) => BillDetailPage(billId: billId);
      }
    }

    // 处理卖家个人主页路由
    if (builder == null && routeName == sellerProfile) {
      final args = settings.arguments as Map<String, dynamic>?;
      final sellerId = args?['sellerId'] as int?;
      final isSellerProfile = args?['isSellerProfile'] as bool? ?? false;
      if (sellerId != null) {
        builder = (context) =>
            ProfilePage(sellerId: sellerId, isSellerProfile: isSellerProfile);
      }
    }

    // 如果路由不存在，返回未知路由
    if (builder == null) {
      print('路由不存在: $routeName');
      return onUnknownRoute(settings);
    }

    // 检查是否是需要认证的路由
    if (_authenticatedRoutes.contains(routeName)) {
      print('使用路由守卫保护路由: $routeName');
      // 使用路由守卫处理需要认证的路由
      return RouteGuard.guardRoute(builder, settings);
    }

    print('直接返回普通路由: $routeName');
    // 对于不需要认证的路由，直接返回
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  /// 未知路由处理
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('页面不存在')),
        body: const Center(child: Text('找不到请求的页面')),
      ),
    );
  }
}
