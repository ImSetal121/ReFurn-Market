/// 账单项模型
class BillItem {
  final int id;
  final int? productId;
  final int? productSellRecordId;
  final String costType;
  final String costDescription;
  final double cost;
  final String paySubject;
  final bool isPlatformPay;
  final int payUserId;
  final String status;
  final DateTime? payTime;
  final int? paymentRecordId;
  final DateTime createTime;
  final DateTime updateTime;

  BillItem({
    required this.id,
    this.productId,
    this.productSellRecordId,
    required this.costType,
    required this.costDescription,
    required this.cost,
    required this.paySubject,
    required this.isPlatformPay,
    required this.payUserId,
    required this.status,
    this.payTime,
    this.paymentRecordId,
    required this.createTime,
    required this.updateTime,
  });

  /// 从后端数据创建BillItem对象
  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      id: json['id'] ?? 0,
      productId: json['productId'],
      productSellRecordId: json['productSellRecordId'],
      costType: json['costType'] ?? '',
      costDescription: json['costDescription'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      paySubject: json['paySubject'] ?? '',
      isPlatformPay: json['isPlatformPay'] ?? false,
      payUserId: json['payUserId'] ?? 0,
      status: json['status'] ?? 'PENDING',
      payTime: json['payTime'] != null ? DateTime.parse(json['payTime']) : null,
      paymentRecordId: json['paymentRecordId'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
    );
  }

  /// 获取状态显示文本
  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'PAID':
        return 'Paid';
      case 'OVERDUE':
        return 'Overdue';
      default:
        return status;
    }
  }

  /// 获取状态颜色
  int get statusColor {
    switch (status) {
      case 'PENDING':
        return 0xFFFFA500; // 橙色
      case 'PAID':
        return 0xFF4CAF50; // 绿色
      case 'OVERDUE':
        return 0xFFFF5722; // 红色
      default:
        return 0xFF8A8A8F; // 灰色
    }
  }

  /// 格式化费用显示
  String get formattedCost {
    return '\$${cost.toStringAsFixed(2)}';
  }

  /// 格式化日期显示
  String get formattedCreateTime {
    return '${createTime.year}-${createTime.month.toString().padLeft(2, '0')}-${createTime.day.toString().padLeft(2, '0')}';
  }

  /// 格式化支付时间显示
  String? get formattedPayTime {
    if (payTime == null) return null;
    return '${payTime!.year}-${payTime!.month.toString().padLeft(2, '0')}-${payTime!.day.toString().padLeft(2, '0')}';
  }
}

/// 账单统计模型
class BillSummary {
  final int totalBills;
  final int pendingBills;
  final int paidBills;
  final int overdueBills;

  BillSummary({
    required this.totalBills,
    required this.pendingBills,
    required this.paidBills,
    required this.overdueBills,
  });

  /// 从后端数据创建BillSummary对象
  factory BillSummary.fromJson(Map<String, dynamic> json) {
    return BillSummary(
      totalBills: json['totalBills'] ?? 0,
      pendingBills: json['pendingBills'] ?? 0,
      paidBills: json['paidBills'] ?? 0,
      overdueBills: json['overdueBills'] ?? 0,
    );
  }
}
