import '../utils/request.dart';

/// 用户相关API
class UserApi {
  static const String _baseUrl = '/api/user';

  /// 获取用户账单列表
  ///
  /// [status] 账单状态 (可选: PENDING, PAID, OVERDUE)
  /// [page] 页码 (默认1)
  /// [size] 每页大小 (默认10)
  /// 返回分页账单数据
  static Future<Map<String, dynamic>?> getUserBills({
    String? status,
    int page = 1,
    int size = 10,
  }) async {
    try {
      // 构建查询参数
      Map<String, dynamic> queryParams = {'page': page, 'size': size};

      // 添加状态过滤参数
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final result = await HttpRequest.get<Map<String, dynamic>>(
        '$_baseUrl/bills',
        queryParameters: queryParams,
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return result;
    } catch (e) {
      print('获取账单列表失败: $e');
      return null;
    }
  }

  /// 获取账单统计信息
  ///
  /// 返回账单统计数据
  static Future<Map<String, dynamic>?> getBillsSummary() async {
    try {
      final result = await HttpRequest.get<Map<String, dynamic>>(
        '$_baseUrl/bills/summary',
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return result;
    } catch (e) {
      print('获取账单统计失败: $e');
      return null;
    }
  }

  /// 获取账单详情
  ///
  /// [billId] 账单ID
  /// 返回账单详情
  static Future<Map<String, dynamic>?> getBillDetail(int billId) async {
    try {
      final result = await HttpRequest.get<Map<String, dynamic>>(
        '$_baseUrl/bills/$billId',
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return result;
    } catch (e) {
      print('获取账单详情失败: $e');
      return null;
    }
  }

  /// 加载更多账单（分页）
  ///
  /// 这是getUserBills的便捷方法，用于加载下一页数据
  static Future<Map<String, dynamic>?> loadMoreBills({
    required String? status,
    required int nextPage,
    int size = 10,
  }) async {
    return await getUserBills(status: status, page: nextPage, size: size);
  }

  /// 处理账单支付成功
  ///
  /// [billId] 账单ID
  /// [paymentIntentId] Stripe支付意图ID
  /// 返回处理结果
  static Future<bool> handleBillPaymentSuccess(
    int billId,
    String paymentIntentId,
  ) async {
    try {
      final result = await HttpRequest.post<String>(
        '$_baseUrl/bills/$billId/payment-success',
        queryParameters: {'paymentIntentId': paymentIntentId},
        fromJson: (data) => data as String,
      );
      return result != null;
    } catch (e) {
      print('处理账单支付成功失败: $e');
      return false;
    }
  }

  /// 使用余额支付账单
  ///
  /// [billId] 账单ID
  /// 返回支付结果
  static Future<bool> handleBillBalancePayment(int billId) async {
    try {
      final result = await HttpRequest.post<String>(
        '$_baseUrl/bills/$billId/balance-payment',
        fromJson: (data) => data as String,
      );
      return result != null;
    } catch (e) {
      print('余额支付账单失败: $e');
      throw Exception('余额支付失败: ${e.toString()}');
    }
  }

  /// 收藏商品
  ///
  /// [productId] 商品ID
  /// 返回操作结果
  static Future<bool> addFavoriteProduct(int productId) async {
    try {
      final result = await HttpRequest.post<String>(
        '$_baseUrl/favorites/$productId',
        fromJson: (data) => data as String,
      );
      return result != null;
    } catch (e) {
      print('收藏商品失败: $e');
      return false;
    }
  }

  /// 取消收藏商品
  ///
  /// [productId] 商品ID
  /// 返回操作结果
  static Future<bool> removeFavoriteProduct(int productId) async {
    try {
      final result = await HttpRequest.delete<String>(
        '$_baseUrl/favorites/$productId',
        fromJson: (data) => data as String,
      );
      return result != null;
    } catch (e) {
      print('取消收藏商品失败: $e');
      return false;
    }
  }

  /// 查询某个商品是否被当前用户收藏
  ///
  /// [productId] 商品ID
  /// 返回收藏状态
  static Future<bool> isProductFavorited(int productId) async {
    try {
      final result = await HttpRequest.get<bool>(
        '$_baseUrl/favorites/$productId/status',
        fromJson: (data) => data as bool,
      );
      return result ?? false;
    } catch (e) {
      print('查询收藏状态失败: $e');
      return false;
    }
  }

  /// 获取当前用户的收藏商品列表
  ///
  /// [page] 页码 (默认1)
  /// [size] 每页大小 (默认10)
  /// 返回收藏商品分页数据
  static Future<Map<String, dynamic>?> getUserFavoriteProducts({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final result = await HttpRequest.get<Map<String, dynamic>>(
        '$_baseUrl/favorites',
        queryParameters: {'page': page, 'size': size},
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return result;
    } catch (e) {
      print('获取收藏商品列表失败: $e');
      return null;
    }
  }

  /// 加载更多收藏商品（分页）
  ///
  /// 这是getUserFavoriteProducts的便捷方法，用于加载下一页数据
  static Future<Map<String, dynamic>?> loadMoreFavoriteProducts({
    required int nextPage,
    int size = 10,
  }) async {
    return await getUserFavoriteProducts(page: nextPage, size: size);
  }

  /// 记录用户浏览商品历史
  ///
  /// [productId] 商品ID
  /// 返回操作结果
  static Future<bool> recordBrowseHistory(int productId) async {
    try {
      final result = await HttpRequest.post<String>(
        '$_baseUrl/browse-history/$productId',
        fromJson: (data) => data as String,
      );
      return result != null;
    } catch (e) {
      print('记录浏览历史失败: $e');
      return false;
    }
  }

  /// 获取当前用户的浏览历史记录
  ///
  /// [page] 页码 (默认1)
  /// [size] 每页大小 (默认10)
  /// 返回浏览历史分页数据
  static Future<Map<String, dynamic>?> getUserBrowseHistory({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final result = await HttpRequest.get<Map<String, dynamic>>(
        '$_baseUrl/browse-history',
        queryParameters: {'page': page, 'size': size},
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return result;
    } catch (e) {
      print('获取浏览历史失败: $e');
      return null;
    }
  }

  /// 加载更多浏览历史（分页）
  ///
  /// 这是getUserBrowseHistory的便捷方法，用于加载下一页数据
  static Future<Map<String, dynamic>?> loadMoreBrowseHistory({
    required int nextPage,
    int size = 10,
  }) async {
    return await getUserBrowseHistory(page: nextPage, size: size);
  }

  /// 获取某个商品的总浏览数
  ///
  /// [productId] 商品ID
  /// 返回浏览次数
  static Future<int> getProductBrowseCount(int productId) async {
    try {
      final result = await HttpRequest.get<int>(
        '$_baseUrl/browse-history/$productId/count',
        fromJson: (data) => data as int,
      );
      return result ?? 0;
    } catch (e) {
      print('获取商品浏览数失败: $e');
      return 0;
    }
  }
}
