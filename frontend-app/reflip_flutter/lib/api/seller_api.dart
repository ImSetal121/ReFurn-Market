import '../utils/request.dart';

class SellerApi {
  static const String _baseUrl = '/api/seller';

  /// 商品上架
  ///
  /// [productData] 商品数据
  /// 返回上架后的商品信息
  static Future<Map<String, dynamic>?> listProduct(
    Map<String, dynamic> productData,
  ) async {
    return await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/list-product',
      data: productData,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 寄卖上架
  ///
  /// [consignmentData] 寄卖商品数据
  /// 返回上架后的商品信息
  static Future<Map<String, dynamic>?> consignmentListing(
    Map<String, dynamic> consignmentData,
  ) async {
    return await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/consignment-listing',
      data: consignmentData,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 自提上架
  ///
  /// [productData] 自提商品数据
  /// 返回上架后的商品信息
  static Future<Map<String, dynamic>?> selfPickupListing(
    Map<String, dynamic> productData,
  ) async {
    return await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/self-pickup-listing',
      data: productData,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 获取当前用户的商品列表
  ///
  /// 返回用户的所有商品列表
  static Future<List<Map<String, dynamic>>?> getMyProducts() async {
    return await HttpRequest.get<List<Map<String, dynamic>>>(
      '$_baseUrl/my-products',
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return null;
      },
    );
  }

  /// 获取当前用户的销售记录
  ///
  /// [page] 页码
  /// [size] 每页大小
  /// 返回用户的销售记录列表
  static Future<List<Map<String, dynamic>>?> getMySales({
    int page = 1,
    int size = 10,
  }) async {
    return await HttpRequest.get<List<Map<String, dynamic>>>(
      '$_baseUrl/my-sales',
      queryParameters: {'page': page, 'size': size},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return null;
      },
    );
  }

  /// 获取Stripe账户信息
  ///
  /// 返回当前用户的Stripe账户信息
  static Future<Map<String, dynamic>?> getStripeAccountInfo() async {
    return await HttpRequest.get<Map<String, dynamic>>(
      '$_baseUrl/stripe-account/info',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 创建Stripe账户
  ///
  /// 为当前用户创建新的Stripe Express账户
  /// 返回包含账户设置链接的信息
  static Future<Map<String, dynamic>?> createStripeAccount() async {
    return await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/stripe-account/create',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 刷新Stripe账户链接
  ///
  /// 为已存在的Stripe账户刷新设置链接
  /// 返回包含新账户设置链接的信息
  static Future<Map<String, dynamic>?> refreshStripeAccountLink() async {
    return await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/stripe-account/refresh-link',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 同步Stripe账户状态
  ///
  /// 从Stripe获取最新的账户状态并更新到数据库
  static Future<Map<String, dynamic>?> syncStripeAccountStatus() async {
    return await HttpRequest.post<Map<String, dynamic>>(
      '$_baseUrl/stripe-account/sync-status',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 获取退货申请详情
  ///
  /// [sellRecordId] 销售记录ID
  /// 返回退货申请详情
  static Future<Map<String, dynamic>?> getReturnRequestDetail(
    String sellRecordId,
  ) async {
    return await HttpRequest.get<Map<String, dynamic>>(
      '$_baseUrl/return-request/$sellRecordId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 处理退货申请
  ///
  /// [sellRecordId] 销售记录ID
  /// [accept] 是否同意退货
  /// [sellerOpinion] 卖家意见
  /// 返回处理结果
  static Future<bool> handleReturnRequest({
    required String sellRecordId,
    required bool accept,
    required String sellerOpinion,
  }) async {
    try {
      final result = await HttpRequest.post<String>(
        '$_baseUrl/return-request/$sellRecordId/handle',
        data: {'accept': accept, 'sellerOpinion': sellerOpinion},
        fromJson: (data) => data as String,
      );
      // 后端返回 "success" 字符串表示成功
      return result == "success";
    } catch (e) {
      print('处理退货申请失败: $e');
      throw e;
    }
  }

  /// 确认收到退货商品
  ///
  /// [sellRecordId] 销售记录ID
  /// 返回确认结果
  static Future<bool> confirmReturnReceived(String sellRecordId) async {
    try {
      final result = await HttpRequest.post<String>(
        '$_baseUrl/return-confirm/$sellRecordId',
        fromJson: (data) => data as String,
      );
      // 后端返回 "success" 字符串表示成功
      return result == "success";
    } catch (e) {
      print('确认收到退货失败: $e');
      throw e;
    }
  }

  /// 请求退回卖家
  ///
  /// [productId] 商品ID
  /// [returnAddress] 退回地址
  /// 返回请求结果
  static Future<bool> requestReturnToSeller({
    required String productId,
    required String returnAddress,
  }) async {
    try {
      final result = await HttpRequest.post<String>(
        '$_baseUrl/request-return-to-seller',
        data: {'productId': productId, 'returnAddress': returnAddress},
        fromJson: (data) => data as String,
      );
      // 后端返回 "success" 字符串表示成功
      return result == "success";
    } catch (e) {
      print('请求退回卖家失败: $e');
      throw e;
    }
  }
}
