import '../utils/request.dart';

/// 余额明细实体类
class RfBalanceDetail {
  final int? id;
  final int userId;
  final int? prevDetailId;
  final int? nextDetailId;
  final String transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? description;
  final String? transactionTime;
  final String? createTime;
  final String? updateTime;
  final bool? isDelete;

  RfBalanceDetail({
    this.id,
    required this.userId,
    this.prevDetailId,
    this.nextDetailId,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    this.transactionTime,
    this.createTime,
    this.updateTime,
    this.isDelete,
  });

  factory RfBalanceDetail.fromJson(Map<String, dynamic> json) {
    return RfBalanceDetail(
      id: json['id']?.toInt(),
      userId: json['userId']?.toInt() ?? 0,
      prevDetailId: json['prevDetailId']?.toInt(),
      nextDetailId: json['nextDetailId']?.toInt(),
      transactionType: json['transactionType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      description: json['description'],
      transactionTime: json['transactionTime'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      isDelete: json['isDelete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'prevDetailId': prevDetailId,
      'nextDetailId': nextDetailId,
      'transactionType': transactionType,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'description': description,
      'transactionTime': transactionTime,
      'createTime': createTime,
      'updateTime': updateTime,
      'isDelete': isDelete,
    };
  }

  /// 获取交易类型的中文名称
  String get transactionTypeName {
    switch (transactionType) {
      case 'DEPOSIT':
        return '充值';
      case 'WITHDRAWAL':
        return '提现';
      case 'WITHDRAW':
        return '提现';
      case 'PURCHASE':
        return '购买';
      case 'REFUND':
        return '退款';
      case 'COMMISSION':
        return '佣金';
      case 'TRANSFER_IN':
        return '转入';
      case 'TRANSFER_OUT':
        return '转出';
      case 'ADJUSTMENT':
        return '调整';
      default:
        return transactionType;
    }
  }

  /// 格式化金额显示
  String get formattedAmount {
    final sign = amount >= 0 ? '+' : '';
    return '$sign\$${amount.toStringAsFixed(2)}';
  }

  /// 格式化余额显示
  String get formattedBalance {
    return '\$${balanceAfter.toStringAsFixed(2)}';
  }

  /// 格式化时间显示
  String get formattedTransactionTime {
    if (transactionTime == null) return '';
    try {
      final dateTime = DateTime.parse(transactionTime!);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return transactionTime!;
    }
  }

  /// 格式化时间显示（时分秒）
  String get formattedTransactionTimeDetail {
    if (transactionTime == null) return '';
    try {
      final dateTime = DateTime.parse(transactionTime!);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

/// 分页响应类
class PageResponse<T> {
  final List<T> records;
  final int total;
  final int size;
  final int current;
  final int pages;

  PageResponse({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    required this.pages,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResponse(
      records:
          (json['records'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total']?.toInt() ?? 0,
      size: json['size']?.toInt() ?? 0,
      current: json['current']?.toInt() ?? 0,
      pages: json['pages']?.toInt() ?? 0,
    );
  }
}

/// 余额API接口类
class BalanceApi {
  /// 获取当前用户余额
  static Future<double?> getCurrentBalance() async {
    final result = await HttpRequest.get<double>(
      '/api/user/balance/current',
      fromJson: (data) => (data as num).toDouble(),
    );
    return result;
  }

  /// 分页查询当前用户的余额明细
  static Future<PageResponse<RfBalanceDetail>?> getBalanceDetailsPage({
    int current = 1,
    int size = 20,
    String? transactionType,
    String? startTime,
    String? endTime,
  }) async {
    final queryParameters = <String, dynamic>{'current': current, 'size': size};

    if (transactionType != null && transactionType.isNotEmpty) {
      queryParameters['transactionType'] = transactionType;
    }
    if (startTime != null && startTime.isNotEmpty) {
      queryParameters['startTime'] = startTime;
    }
    if (endTime != null && endTime.isNotEmpty) {
      queryParameters['endTime'] = endTime;
    }

    final result = await HttpRequest.get<PageResponse<RfBalanceDetail>>(
      '/api/user/balance/details',
      queryParameters: queryParameters,
      fromJson: (data) => PageResponse.fromJson(
        data as Map<String, dynamic>,
        (json) => RfBalanceDetail.fromJson(json),
      ),
    );
    return result;
  }

  /// 获取当前用户指定交易类型的总金额
  static Future<double?> getAmountByType(String transactionType) async {
    final result = await HttpRequest.get<double>(
      '/api/user/balance/amount/$transactionType',
      fromJson: (data) => (data as num).toDouble(),
    );
    return result;
  }

  /// 获取当前用户最新的余额明细记录
  static Future<RfBalanceDetail?> getLatestBalanceDetail() async {
    final result = await HttpRequest.get<RfBalanceDetail>(
      '/api/user/balance/latest',
      fromJson: (data) =>
          RfBalanceDetail.fromJson(data as Map<String, dynamic>),
    );
    return result;
  }

  /// 检查用户登录状态
  static Future<bool?> checkLoginStatus() async {
    final result = await HttpRequest.get<bool>(
      '/api/user/balance/status',
      fromJson: (data) => data as bool,
    );
    return result;
  }

  /// 获取当前用户ID（调试用）
  static Future<int?> getCurrentUserId() async {
    final result = await HttpRequest.get<int>(
      '/api/user/balance/user-id',
      fromJson: (data) => (data as num).toInt(),
    );
    return result;
  }

  /// 检查提现条件
  static Future<WithdrawCheckResult?> checkWithdrawEligibility(
    double amount,
  ) async {
    final result = await HttpRequest.post<WithdrawCheckResult>(
      '/api/user/balance/withdraw/check',
      data: {'amount': amount},
      fromJson: (data) =>
          WithdrawCheckResult.fromJson(data as Map<String, dynamic>),
    );
    return result;
  }

  /// 提现到Stripe账户
  static Future<bool?> withdrawToStripe(double amount) async {
    final result = await HttpRequest.post<bool>(
      '/api/user/balance/withdraw',
      data: {'amount': amount},
      fromJson: (data) => data as bool,
    );
    return result;
  }

  /// 处理充值成功
  static Future<bool> handleRechargeSuccess(
    double amount,
    String paymentIntentId,
  ) async {
    try {
      final result = await HttpRequest.post<bool>(
        '/api/user/balance/recharge/success',
        data: {'amount': amount, 'paymentIntentId': paymentIntentId},
        fromJson: (data) => data as bool,
      );
      return result ?? false;
    } catch (e) {
      print('充值成功处理失败: $e');
      return false;
    }
  }

  /// 使用余额购买商品
  static Future<PurchaseResult?> purchaseWithBalance({
    required int productId,
    required double amount,
    required String productName,
  }) async {
    final result = await HttpRequest.post<PurchaseResult>(
      '/api/user/balance/purchase',
      data: {
        'productId': productId,
        'amount': amount,
        'productName': productName,
      },
      fromJson: (data) => PurchaseResult.fromJson(data as Map<String, dynamic>),
    );
    return result;
  }

  /// 使用余额购买寄卖商品
  static Future<PurchaseResult?> purchaseWithBalanceForConsignment({
    required int productId,
    required double amount,
    required String productName,
    required String deliveryAddress,
    required String deliveryPhone,
    required String deliveryName,
  }) async {
    final result = await HttpRequest.post<PurchaseResult>(
      '/api/user/balance/purchase/consignment',
      data: {
        'productId': productId,
        'amount': amount,
        'productName': productName,
        'deliveryAddress': deliveryAddress,
        'deliveryPhone': deliveryPhone,
        'deliveryName': deliveryName,
      },
      fromJson: (data) => PurchaseResult.fromJson(data as Map<String, dynamic>),
    );
    return result;
  }

  /// 检查余额购买条件
  static Future<PurchaseCheckResult?> checkBalancePurchaseEligibility(
    double amount,
  ) async {
    final result = await HttpRequest.post<PurchaseCheckResult>(
      '/api/user/balance/purchase/check',
      data: {'amount': amount},
      fromJson: (data) =>
          PurchaseCheckResult.fromJson(data as Map<String, dynamic>),
    );
    return result;
  }
}

/// 提现检查结果类
class WithdrawCheckResult {
  final bool eligible;
  final String? errorMessage;

  WithdrawCheckResult({required this.eligible, this.errorMessage});

  factory WithdrawCheckResult.fromJson(Map<String, dynamic> json) {
    return WithdrawCheckResult(
      eligible: json['eligible'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'eligible': eligible, 'errorMessage': errorMessage};
  }
}

/// 购买结果类
class PurchaseResult {
  final bool success;
  final String? message;
  final String? orderId;

  PurchaseResult({required this.success, this.message, this.orderId});

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    return PurchaseResult(
      success: json['success'] ?? false,
      message: json['message'],
      orderId: json['orderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'orderId': orderId};
  }
}

/// 购买条件检查结果类
class PurchaseCheckResult {
  final bool eligible;
  final String? errorMessage;
  final double currentBalance;

  PurchaseCheckResult({
    required this.eligible,
    this.errorMessage,
    required this.currentBalance,
  });

  factory PurchaseCheckResult.fromJson(Map<String, dynamic> json) {
    return PurchaseCheckResult(
      eligible: json['eligible'] ?? false,
      errorMessage: json['errorMessage'],
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'errorMessage': errorMessage,
      'currentBalance': currentBalance,
    };
  }
}
