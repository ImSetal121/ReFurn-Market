import 'package:flutter/material.dart';
import '../api/user_api.dart';
import '../api/balance_api.dart';
import '../models/bill_item.dart';
import '../services/stripe_service.dart';

class BillDetailPage extends StatefulWidget {
  final int billId;

  const BillDetailPage({Key? key, required this.billId}) : super(key: key);

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  BillItem? _billItem;
  bool _isLoading = true;

  // 余额支付相关
  double _currentBalance = 0.0;
  bool _isLoadingBalance = false;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadBillDetail();
    _loadUserBalance();
  }

  /// 加载账单详情
  Future<void> _loadBillDetail() async {
    try {
      final billData = await UserApi.getBillDetail(widget.billId);
      if (billData != null && mounted) {
        setState(() {
          _billItem = BillItem.fromJson(billData);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载账单详情失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 加载用户余额
  Future<void> _loadUserBalance() async {
    setState(() {
      _isLoadingBalance = true;
    });

    try {
      final balance = await BalanceApi.getCurrentBalance();
      if (mounted) {
        setState(() {
          _currentBalance = balance ?? 0.0;
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      print('加载余额失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    }
  }

  /// 显示支付方式选择
  Future<void> _handlePayment() async {
    if (_isProcessingPayment) return;

    // 检查必要信息
    if (_billItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill information is loading, please try again later'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 检查账单状态
    if (_billItem!.status != 'PENDING') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This bill cannot be paid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 显示支付方式选择器
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPaymentMethodSelection(),
    );
  }

  /// 处理余额支付
  Future<void> _handleBalancePayment() async {
    Navigator.pop(context); // 关闭支付方式选择器

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final billAmount = _billItem!.cost;

      // 先检查余额购买条件
      final checkResult = await BalanceApi.checkBalancePurchaseEligibility(
        billAmount,
      );

      if (checkResult == null || !checkResult.eligible) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              checkResult?.errorMessage ??
                  'Unable to check balance payment eligibility',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 调用账单余额支付API
      final success = await UserApi.handleBillBalancePayment(_billItem!.id);

      if (success) {
        // 支付成功，重新加载账单详情和余额
        await Future.wait([_loadBillDetail(), _loadUserBalance()]);

        // 显示支付成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Bill paid with balance successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Balance payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('余额支付失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Balance payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  /// 处理直接支付
  Future<void> _handleDirectPayment() async {
    Navigator.pop(context); // 关闭支付方式选择器

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // 使用原有的Stripe支付逻辑
      final success = await StripeService.processBillPayment(
        billId: _billItem!.id,
        amount: _billItem!.cost,
        billDescription: _billItem!.costDescription,
        context: context,
      );

      if (success) {
        // 支付成功后重新加载账单详情
        await _loadBillDetail();

        // 显示支付成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Bill payment successful!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('直接支付失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildAppBar(),

            // 内容区域
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _billItem == null
                  ? _buildErrorState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Bill Detail',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24), // 平衡布局
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 账单状态卡片
          _buildStatusCard(),

          const SizedBox(height: 16),

          // 账单基本信息
          _buildBasicInfoCard(),

          const SizedBox(height: 16),

          // 费用详情
          _buildCostDetailCard(),

          const SizedBox(height: 16),

          // 支付信息（如果已支付）
          if (_billItem!.status == 'PAID') _buildPaymentInfoCard(),

          const SizedBox(height: 32),

          // 支付按钮（如果未支付）
          if (_billItem!.status == 'PENDING') _buildPaymentButton(),
        ],
      ),
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3FA8A8A8),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 状态图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(_billItem!.statusColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              _getStatusIcon(_billItem!.status),
              color: Color(_billItem!.statusColor),
              size: 30,
            ),
          ),

          const SizedBox(height: 12),

          // 状态文本
          Text(
            _billItem!.statusText,
            style: TextStyle(
              color: Color(_billItem!.statusColor),
              fontSize: 18,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // 金额
          Text(
            _billItem!.formattedCost,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildBasicInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3FA8A8A8),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoRow('Bill ID', '#${_billItem!.id}'),
          _buildInfoRow('Description', _billItem!.costDescription),
          _buildInfoRow('Cost Type', _billItem!.costType),
          _buildInfoRow('Pay Subject', _billItem!.paySubject),
          _buildInfoRow('Create Time', _billItem!.formattedCreateTime),
          if (_billItem!.productId != null)
            _buildInfoRow('Product ID', '#${_billItem!.productId}'),
          if (_billItem!.productSellRecordId != null)
            _buildInfoRow('Order ID', '#${_billItem!.productSellRecordId}'),
        ],
      ),
    );
  }

  /// 构建费用详情卡片
  Widget _buildCostDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3FA8A8A8),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Details',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _billItem!.costDescription,
                style: const TextStyle(
                  color: Color(0xFF8A8A8F),
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _billItem!.formattedCost,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _billItem!.formattedCost,
                style: const TextStyle(
                  color: Color(0xFFFFA500),
                  fontSize: 18,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建支付信息卡片
  Widget _buildPaymentInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3FA8A8A8),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          if (_billItem!.payTime != null)
            _buildInfoRow('Payment Time', _billItem!.formattedPayTime!),
          if (_billItem!.paymentRecordId != null)
            _buildInfoRow(
              'Payment Record ID',
              '#${_billItem!.paymentRecordId}',
            ),
          _buildInfoRow(
            'Payment Method',
            _billItem!.isPlatformPay ? 'Platform Pay' : 'External Pay',
          ),
        ],
      ),
    );
  }

  /// 构建支付按钮
  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isProcessingPayment
              ? Colors.grey[400]
              : const Color(0xFFFFA500),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessingPayment
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Processing...',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Pay Now ${_billItem!.formattedCost}',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8A8A8F),
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取状态图标
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'PAID':
        return Icons.check_circle;
      case 'OVERDUE':
        return Icons.error;
      default:
        return Icons.receipt;
    }
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Failed to Load Bill',
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 18,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unable to load bill details.\nPlease try again later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBillDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// 构建支付方式选择弹窗
  Widget _buildPaymentMethodSelection() {
    final billAmount = _billItem?.cost ?? 0.0;
    final hasInsufficientBalance = _currentBalance < billAmount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          // 点击遮罩关闭
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),

          // 支付方式选择容器
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部标题
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Payment Method',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Transform.rotate(
                          angle: 0.785398, // 45度
                          child: const Icon(
                            Icons.add,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 账单摘要
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA500),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.receipt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _billItem?.costDescription ??
                                        'Bill Payment',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _billItem?.formattedCost ?? '\$0.00',
                                    style: const TextStyle(
                                      color: Color(0xFFFFA500),
                                      fontSize: 16,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 余额支付选项
                  GestureDetector(
                    onTap: hasInsufficientBalance
                        ? null
                        : _handleBalancePayment,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: hasInsufficientBalance
                            ? Colors.grey[100]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasInsufficientBalance
                              ? Colors.grey[300]!
                              : const Color(0xFFFFA500),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: hasInsufficientBalance
                                ? Colors.grey[400]
                                : const Color(0xFFFFA500),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Balance Payment',
                                  style: TextStyle(
                                    color: hasInsufficientBalance
                                        ? Colors.grey[600]
                                        : Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isLoadingBalance
                                      ? 'Loading balance...'
                                      : 'Current Balance: \$${_currentBalance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: hasInsufficientBalance
                                        ? Colors.red
                                        : Colors.grey[600],
                                    fontSize: 12,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (hasInsufficientBalance)
                                  const Text(
                                    'Insufficient balance',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (hasInsufficientBalance)
                            Icon(
                              Icons.block,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 直接支付选项
                  GestureDetector(
                    onTap: _handleDirectPayment,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.credit_card,
                            color: Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Direct Payment',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Pay with credit/debit card',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
