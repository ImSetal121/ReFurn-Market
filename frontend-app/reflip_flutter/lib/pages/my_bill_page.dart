import 'package:flutter/material.dart';
import '../api/user_api.dart';
import '../models/bill_item.dart';

class MyBillPage extends StatefulWidget {
  const MyBillPage({Key? key}) : super(key: key);

  @override
  State<MyBillPage> createState() => _MyBillPageState();
}

class _MyBillPageState extends State<MyBillPage> {
  String _selectedTab = 'All';
  BillSummary? _billSummary;
  List<BillItem> _bills = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    await Future.wait([_loadBillSummary(), _loadBills()]);
  }

  /// 加载账单统计
  Future<void> _loadBillSummary() async {
    try {
      final summaryData = await UserApi.getBillsSummary();
      if (summaryData != null && mounted) {
        setState(() {
          _billSummary = BillSummary.fromJson(summaryData);
        });
      }
    } catch (e) {
      print('加载账单统计失败: $e');
    }
  }

  /// 加载账单列表
  Future<void> _loadBills() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final response = await UserApi.getUserBills(
        status: _getStatusParam(),
        page: _currentPage,
        size: _pageSize,
      );

      if (response != null && mounted) {
        final records = response['records'] as List?;
        setState(() {
          _bills =
              records?.map((item) => BillItem.fromJson(item)).toList() ?? [];
          // 使用MyBatis Plus的分页信息来判断是否还有更多数据
          final currentPage = response['current'] ?? 1;
          final pages = response['pages'] ?? 1;
          _hasMoreData = currentPage < pages;
        });
      }
    } catch (e) {
      print('加载账单列表失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 加载更多账单
  Future<void> _loadMoreBills() async {
    if (!mounted || _isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await UserApi.loadMoreBills(
        status: _getStatusParam(),
        nextPage: nextPage,
        size: _pageSize,
      );

      if (response != null && mounted) {
        final records = response['records'] as List?;
        final newBills =
            records?.map((item) => BillItem.fromJson(item)).toList() ?? [];

        setState(() {
          _bills.addAll(newBills);
          _currentPage = nextPage;
          // 更新是否还有更多数据的标志
          final currentPage = response['current'] ?? 1;
          final pages = response['pages'] ?? 1;
          _hasMoreData = currentPage < pages;
        });
      }
    } catch (e) {
      print('加载更多账单失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// 获取状态参数
  String? _getStatusParam() {
    switch (_selectedTab) {
      case 'Pending':
        return 'PENDING';
      case 'Paid':
        return 'PAID';
      case 'Overdue':
        return 'OVERDUE';
      default:
        return null; // All - 不过滤状态
    }
  }

  /// 切换标签
  void _onTabChanged(String tab) {
    if (_selectedTab != tab) {
      setState(() {
        _selectedTab = tab;
      });
      _loadBills(); // 重新加载数据
    }
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    // 重新加载统计数据和账单列表
    await Future.wait([_loadBillSummary(), _loadBills()]);
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

            // 标签栏
            _buildTabBar(),

            // 账单列表内容 - 添加下拉刷新
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFFFFA500),
                backgroundColor: Colors.white,
                child: _buildBillContent(),
              ),
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
                'My Bill',
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

  /// 构建标签栏
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem('All'),
          _buildTabItem('Pending'),
          _buildTabItem('Paid'),
          _buildTabItem('Overdue'),
        ],
      ),
    );
  }

  /// 构建标签项
  Widget _buildTabItem(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => _onTabChanged(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFA500) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8A8A8F),
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 构建账单内容
  Widget _buildBillContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // 监听滚动事件，实现加载更多
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (!_isLoadingMore && _hasMoreData) {
            _loadMoreBills();
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // 确保即使内容不足也能下拉刷新
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 账单统计卡片
              _buildBillSummaryCard(),

              const SizedBox(height: 16),

              // 账单列表
              _buildBillList(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建账单统计卡片
  Widget _buildBillSummaryCard() {
    if (_billSummary == null) {
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
        child: const Center(child: CircularProgressIndicator()),
      );
    }

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
            'Bill Summary',
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
              _buildSummaryItem(
                'Total Bills',
                _billSummary!.totalBills.toString(),
                Colors.blue,
              ),
              _buildSummaryItem(
                'Pending',
                _billSummary!.pendingBills.toString(),
                Colors.orange,
              ),
              _buildSummaryItem(
                'Paid',
                _billSummary!.paidBills.toString(),
                Colors.green,
              ),
              _buildSummaryItem(
                'Overdue',
                _billSummary!.overdueBills.toString(),
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildSummaryItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8A8F),
            fontSize: 12,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// 构建账单列表
  Widget _buildBillList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // 设置固定高度
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
          // 列表标题
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Recent Bills',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_bills.length} items',
                  style: const TextStyle(
                    color: Color(0xFFFFA500),
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 账单内容
          Expanded(
            child: _isLoading && _bills.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _bills.isEmpty
                ? _buildEmptyState()
                : _buildBillListView(),
          ),
        ],
      ),
    );
  }

  /// 构建账单列表视图
  Widget _buildBillListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _bills.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _bills.length) {
          // 加载更多指示器
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final bill = _bills[index];
        return _buildBillItem(bill);
      },
    );
  }

  /// 构建账单项
  Widget _buildBillItem(BillItem bill) {
    return GestureDetector(
      onTap: () {
        // 跳转到账单详情页面
        Navigator.pushNamed(
          context,
          '/bill-detail',
          arguments: {'billId': bill.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 费用类型图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(bill.statusColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getBillIcon(bill.costType),
                color: Color(bill.statusColor),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // 账单信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.costDescription,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bill.formattedCreateTime,
                    style: const TextStyle(
                      color: Color(0xFF8A8A8F),
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // 状态和金额
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bill.formattedCost,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(bill.statusColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bill.statusText,
                    style: TextStyle(
                      color: Color(bill.statusColor),
                      fontSize: 10,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            // 添加箭头图标表示可点击
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF8A8A8F),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取账单类型图标
  IconData _getBillIcon(String costType) {
    switch (costType.toLowerCase()) {
      case 'shipping':
        return Icons.local_shipping;
      case 'commission':
        return Icons.account_balance_wallet;
      case 'service':
        return Icons.build;
      case 'storage':
        return Icons.warehouse;
      default:
        return Icons.receipt;
    }
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Bills Yet',
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 18,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your bills will appear here when\nyou make purchases or transactions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
