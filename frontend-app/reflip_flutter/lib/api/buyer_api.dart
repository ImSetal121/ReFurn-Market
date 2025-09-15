import '../utils/request.dart';

/// 买家相关API
/// 处理需要用户登录的买家业务
class BuyerApi {
  static const String _baseUrl = '/api/buyer';

  /// 锁定商品
  ///
  /// [productId] 商品ID
  /// 返回锁定是否成功
  static Future<bool> lockProduct(int productId) async {
    try {
      final result = await HttpRequest.post<bool>(
        '$_baseUrl/product/$productId/lock',
        fromJson: (data) => data as bool,
      );
      return result ?? false;
    } catch (e) {
      print('锁定商品失败: $e');
      return false;
    }
  }

  /// 检查商品锁定状态
  ///
  /// [productId] 商品ID
  /// 返回商品是否被锁定
  static Future<bool> checkProductLockStatus(int productId) async {
    try {
      final result = await HttpRequest.get<bool>(
        '$_baseUrl/product/$productId/lock-status',
        fromJson: (data) => data as bool,
      );
      return result ?? false;
    } catch (e) {
      print('检查商品锁定状态失败: $e');
      return false;
    }
  }

  /// 解锁商品
  ///
  /// [productId] 商品ID
  /// 返回解锁是否成功
  static Future<bool> unlockProduct(int productId) async {
    try {
      final result = await HttpRequest.delete<bool>(
        '$_baseUrl/product/$productId/lock',
        fromJson: (data) => data as bool,
      );
      return result ?? false;
    } catch (e) {
      print('解锁商品失败: $e');
      return false;
    }
  }

  /// 获取商品锁的剩余时间
  ///
  /// [productId] 商品ID
  /// 返回剩余时间（秒），失败返回-1
  static Future<int> getLockRemainingTime(int productId) async {
    try {
      final result = await HttpRequest.get<int>(
        '$_baseUrl/product/$productId/lock-remaining-time',
        fromJson: (data) => (data as num).toInt(),
      );
      return result ?? -1;
    } catch (e) {
      print('获取锁剩余时间失败: $e');
      return -1;
    }
  }

  /// 检查当前用户是否为商品拥有者
  ///
  /// [productId] 商品ID
  /// 返回是否为商品拥有者
  static Future<bool> isProductOwner(int productId) async {
    try {
      final result = await HttpRequest.get<bool>(
        '$_baseUrl/product/$productId/is-owner',
        fromJson: (data) => data as bool,
      );
      return result ?? false;
    } catch (e) {
      print('检查商品所有权失败: $e');
      return false;
    }
  }

  /// 处理购买成功
  ///
  /// [productId] 商品ID
  /// [paymentIntentId] 支付意图ID
  /// 返回处理是否成功
  static Future<bool> handlePurchaseSuccess(
    int productId,
    String paymentIntentId,
  ) async {
    try {
      final result = await HttpRequest.post<bool>(
        '$_baseUrl/purchase/success',
        data: {'productId': productId, 'paymentIntentId': paymentIntentId},
        fromJson: (data) => data as bool,
      );
      return result ?? false;
    } catch (e) {
      print('处理购买成功失败: $e');
      return false;
    }
  }

  /// 处理寄卖商品购买成功
  ///
  /// [productId] 商品ID
  /// [paymentIntentId] 支付意图ID
  /// [deliveryAddress] 收货地址
  /// [deliveryPhone] 收货电话
  /// [deliveryName] 收货人姓名
  /// 返回处理是否成功
  static Future<bool> handleConsignmentPurchaseSuccess(
    int productId,
    String paymentIntentId,
    String deliveryAddress,
    String deliveryPhone,
    String deliveryName,
  ) async {
    try {
      final result = await HttpRequest.post<bool>(
        '$_baseUrl/consignment/purchase/success',
        data: {
          'productId': productId,
          'paymentIntentId': paymentIntentId,
          'deliveryAddress': deliveryAddress,
          'deliveryPhone': deliveryPhone,
          'deliveryName': deliveryName,
        },
        fromJson: (data) => data as bool,
      );
      return result ?? false;
    } catch (e) {
      print('处理寄卖商品购买成功失败: $e');
      return false;
    }
  }

  /// 获取用户购买记录
  ///
  /// [page] 页码（从1开始）
  /// [size] 每页大小
  /// 返回购买记录分页数据
  static Future<Map<String, dynamic>?> getMyOrders({
    required int page,
    required int size,
  }) async {
    try {
      final response = await HttpRequest.get<Map<String, dynamic>>(
        '$_baseUrl/my-orders',
        queryParameters: {'page': page.toString(), 'size': size.toString()},
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return response;
    } catch (e) {
      print('获取订单失败: $e');
      return null;
    }
  }

  /// 确认收货API
  static Future<bool> confirmReceipt({
    required String orderId,
    String? comment,
    List<String>? receiptImages,
  }) async {
    try {
      // 准备图片数据
      Map<String, dynamic> data = {'orderId': orderId};

      // 如果有评论，添加到数据中
      if (comment != null && comment.isNotEmpty) {
        data['comment'] = comment;
      }

      // 如果有收货凭证图片，处理图片数据
      if (receiptImages != null && receiptImages.isNotEmpty) {
        // TODO: 实现图片处理逻辑，这里先用JSON字符串模拟
        data['receiptImages'] = receiptImages;
      }

      // 发送确认收货请求
      final result = await HttpRequest.post<bool>(
        '$_baseUrl/confirm-receipt',
        data: data,
        fromJson: (data) => data as bool,
      );

      return result ?? false;
    } catch (e) {
      print('确认收货失败: $e');
      throw e;
    }
  }

  /// 申请退货API
  static Future<bool> applyRefund({
    required String orderId,
    required String reason,
    String? description,
    String? pickupAddress,
  }) async {
    try {
      Map<String, dynamic> data = {'orderId': orderId, 'reason': reason};

      // 如果有详细说明，添加到数据中
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }

      // 如果有取货地址，添加到数据中
      if (pickupAddress != null && pickupAddress.isNotEmpty) {
        data['pickupAddress'] = pickupAddress;
      }

      // 发送退货申请请求
      final result = await HttpRequest.post<bool>(
        '$_baseUrl/apply-refund',
        data: data,
        fromJson: (data) => data as bool,
      );

      return result ?? false;
    } catch (e) {
      print('申请退货失败: $e');
      throw e;
    }
  }
}
