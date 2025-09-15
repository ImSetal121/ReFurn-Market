import 'package:flutter/material.dart';
import '../api/balance_api.dart';
import '../api/seller_api.dart';
import '../stores/auth_store.dart';
import '../utils/auth_utils.dart';
import '../routes/app_routes.dart';

class MyWalletPage extends StatefulWidget {
  const MyWalletPage({Key? key}) : super(key: key);

  @override
  State<MyWalletPage> createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  // 真实数据
  double _accountBalance = 0.0;
  List<RfBalanceDetail> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  bool _isCheckingStripeAccount = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLoading &&
        _hasMoreData) {
      _loadMoreTransactions();
    }
  }

  // 加载初始数据
  Future<void> _loadInitialData() async {
    await Future.wait([_loadBalance(), _loadTransactions(isRefresh: true)]);
  }

  // 加载余额
  Future<void> _loadBalance() async {
    try {
      final balance = await BalanceApi.getCurrentBalance();
      if (mounted) {
        setState(() {
          _accountBalance = balance ?? 0.0;
        });
      }
    } catch (e) {
      print('加载余额失败: $e');
    }
  }

  // 加载交易记录
  Future<void> _loadTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      // 如果是刷新，不再重复设置状态（因为_refreshData已经设置了）
      // 只在非刷新调用时设置状态
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
          _currentPage = 1;
          _hasMoreData = true;
        });
      }
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final result = await BalanceApi.getBalanceDetailsPage(
        current: _currentPage,
        size: _pageSize,
      );

      if (mounted && result != null) {
        setState(() {
          if (isRefresh) {
            _transactions = result.records;
            _isLoading = false;
          } else {
            _transactions.addAll(result.records);
            _isLoadingMore = false;
          }

          _hasMoreData = result.records.length == _pageSize;
          if (_hasMoreData) {
            _currentPage++;
          }
        });
      }
    } catch (e) {
      print('加载交易记录失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  // 加载更多交易记录
  Future<void> _loadMoreTransactions() async {
    await _loadTransactions();
  }

  // 刷新数据
  Future<void> _refreshData() async {
    // 立即清空交易列表，避免显示旧数据
    setState(() {
      _transactions.clear();
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    await _loadInitialData();
  }

  // 检查Stripe账户状态并处理提现逻辑
  Future<void> _handleWithdrawalTap() async {
    // 防止重复点击
    if (_isCheckingStripeAccount) return;

    setState(() {
      _isCheckingStripeAccount = true;
    });

    try {
      // 1. 首先检查用户是否已登录
      if (!authStore.isAuthenticated) {
        final success = await AuthUtils.requireLogin(
          context,
          message: 'Please login to access withdrawal',
        );

        if (!success) {
          return;
        }
      }

      // 2. 检查Stripe账户状态
      final accountInfo = await SellerApi.getStripeAccountInfo();

      if (accountInfo == null) {
        // 用户没有Stripe账户，需要设置
        await _redirectToStripeSetup(
          'You need to set up a payment account before withdrawing funds',
        );
        return;
      }

      final canReceivePayments =
          accountInfo['canReceivePayments'] as bool? ?? false;
      final accountStatus =
          accountInfo['accountStatus'] as String? ?? 'pending';
      final verificationStatus =
          accountInfo['verificationStatus'] as String? ?? 'unverified';

      // 3. 检查账户状态是否满足提现的条件
      if (!canReceivePayments || accountStatus != 'active') {
        String message =
            'Your payment account status is abnormal, please complete the setup before withdrawing funds';
        if (accountStatus == 'pending') {
          message =
              'Your payment account setup is incomplete, please complete account verification first';
        } else if (accountStatus == 'restricted') {
          message =
              'Your payment account is restricted, please contact support or re-setup your account';
        }

        await _redirectToStripeSetup(message);
        return;
      }

      // 4. 账户状态正常，可以提现
      if (mounted) {
        final shouldRefresh = await Navigator.pushNamed(
          context,
          AppRoutes.withdrawal,
        );
        if (shouldRefresh == true) {
          _refreshData();
        }
      }
    } catch (e) {
      print('Failed to check Stripe account status: $e');

      // 网络错误或其他异常，提示用户检查网络后重试
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to verify account status, please check your network connection and try again',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleWithdrawalTap,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStripeAccount = false;
        });
      }
    }
  }

  // 引导用户到设置页面设置Stripe账户
  Future<void> _redirectToStripeSetup(String message) async {
    if (!mounted) return;

    // 显示提示信息
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Account Setup Required'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Setup Now',
                style: TextStyle(color: Color(0xFFFFA500)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldContinue == true && mounted) {
      // 跳转到设置页面
      await Navigator.pushNamed(context, '/settings');

      // 从设置页面返回后，可能需要重新检查账户状态
      // 这里可以选择自动重新检查，或者让用户重新点击
    }
  }

  // 显示功能开发中提示
  void _showFeatureUnderDevelopment() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature under development'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // 顶部导航栏
          _buildHeader(),
          // 固定的钱包余额卡片
          _buildWalletCard(),
          // 固定的交易记录列表标题
          _buildTransactionsHeader(),
          // 可滚动的交易记录列表区域（支持下拉刷新）
          Expanded(child: _buildScrollableTransactionsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
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
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    'Wallet',
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
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      width: double.infinity,
      height: 185,
      child: Stack(
        children: [
          // 背景渐变
          Container(
            width: double.infinity,
            height: 185,
            decoration: const ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.26, -0.20),
                end: Alignment(1.73, 1.70),
                colors: [Color(0xFF282828), Color(0xFF0B0B0B)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          // 白色透明覆盖层
          Container(
            width: double.infinity,
            height: 185,
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          // 内容
          Positioned(
            left: 24,
            top: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 余额信息
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.90,
                      child: Text(
                        'Account Balance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          height: 1.71,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '\$${_accountBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        height: 0.67,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 29),
                // 操作按钮
                Row(
                  children: [
                    // 提现按钮
                    Expanded(
                      child: GestureDetector(
                        onTap: _isCheckingStripeAccount
                            ? null
                            : _handleWithdrawalTap,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 23,
                            vertical: 8,
                          ),
                          decoration: ShapeDecoration(
                            color: _isCheckingStripeAccount
                                ? Colors.grey[300]
                                : Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          child: Center(
                            child: _isCheckingStripeAccount
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Text(
                                    'Withdrawal',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w600,
                                      height: 1.50,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // 充值按钮
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final shouldRefresh = await Navigator.pushNamed(
                            context,
                            AppRoutes.recharge,
                          );
                          if (shouldRefresh == true) {
                            _refreshData();
                          }
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 8,
                          ),
                          decoration: const ShapeDecoration(
                            color: Color(0xFFFFA500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Recharge',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x198A8A8F),
            blurRadius: 4,
            offset: Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Balance Change Details',
              style: TextStyle(
                color: Color(0xFF252525),
                fontSize: 16,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: _showFeatureUnderDevelopment,
              child: Row(
                children: [
                  const Text(
                    'All',
                    style: TextStyle(
                      color: Color(0xFFC7C7CC),
                      fontSize: 14,
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.rotate(
                    angle: -1.5708, // -90度
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 12,
                      color: Color(0xFFC7C7CC),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableTransactionsList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x198A8A8F),
              blurRadius: 4,
              offset: Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _transactions.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'No transaction records',
                    style: TextStyle(
                      color: Color(0xFFC7C7CC),
                      fontSize: 14,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              )
            : ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) {
                  if (index >= _transactions.length) return const SizedBox();
                  return Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: const Color(0xFFF0F0F0),
                  );
                },
                itemBuilder: (context, index) {
                  if (index >= _transactions.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final transaction = _transactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
      ),
    );
  }

  Widget _buildTransactionItem(RfBalanceDetail transaction) {
    final bool isPositive = transaction.amount >= 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: const ShapeDecoration(
              color: Color(0xFFE8E8E8),
              shape: OvalBorder(),
            ),
            child: Icon(
              _getTransactionIcon(transaction.transactionType),
              size: 20,
              color: const Color(0xFF8A8A8F),
            ),
          ),
          const SizedBox(width: 16),
          // 交易信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和金额
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        transaction.description ??
                            transaction.transactionTypeName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      transaction.formattedAmount,
                      style: TextStyle(
                        color: isPositive
                            ? const Color(0xFF34C759)
                            : Colors.black,
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 日期时间和余额
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          transaction.formattedTransactionTime,
                          style: const TextStyle(
                            color: Color(0xFFC7C7C7),
                            fontSize: 10,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          transaction.formattedTransactionTimeDetail,
                          style: const TextStyle(
                            color: Color(0xFFC7C7C7),
                            fontSize: 10,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Balance',
                          style: TextStyle(
                            color: Color(0xFFC7C7C7),
                            fontSize: 10,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.formattedBalance,
                          style: const TextStyle(
                            color: Color(0xFFC7C7C7),
                            fontSize: 10,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 根据交易类型获取图标
  IconData _getTransactionIcon(String transactionType) {
    switch (transactionType) {
      case 'DEPOSIT':
        return Icons.add_circle_outline;
      case 'WITHDRAW':
        return Icons.remove_circle_outline;
      case 'PURCHASE':
        return Icons.shopping_cart_outlined;
      case 'REFUND':
        return Icons.refresh;
      case 'COMMISSION':
        return Icons.monetization_on_outlined;
      case 'TRANSFER_IN':
        return Icons.arrow_downward;
      case 'TRANSFER_OUT':
        return Icons.arrow_upward;
      case 'ADJUSTMENT':
        return Icons.settings;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
