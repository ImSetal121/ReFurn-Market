import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/buyer_api.dart';
import '../stores/auth_store.dart';
import '../pages/confirm_receipt_page.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({Key? key}) : super(key: key);

  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  List<Map<String, dynamic>> _userOrders = [];
  bool _isLoading = false;
  String _selectedTab = 'All';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserOrders({bool isRefresh = false}) async {
    if (!authStore.isAuthenticated || !mounted) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BuyerApi.getMyOrders(page: _currentPage, size: 10);

      if (result != null && mounted) {
        final records = result['records'] as List<dynamic>? ?? [];
        final newOrders = records.cast<Map<String, dynamic>>();

        setState(() {
          if (isRefresh) {
            _userOrders = newOrders;
          } else {
            _userOrders.addAll(newOrders);
          }
          _currentPage++;
          _hasMore = newOrders.length >= 10;
        });
      }
    } catch (e) {
      print('加载用户订单失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    return _userOrders.where((order) {
      final status = order['status']?.toString().toLowerCase() ?? '';
      switch (_selectedTab) {
        case 'All':
          return true;
        case 'Pending':
          return status == 'pending_receipt' ||
              status == 'pending' ||
              status == 'pending_shipment' ||
              status == 'return_initiated';
        case 'Completed':
          return status == 'completed' ||
              status == 'received' ||
              status == 'confirmed' ||
              status == 'delivered';
        case 'Cancelled':
          return status == 'cancelled';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildOrderList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                'My Orders',
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0x1E787880),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 17, color: Color(0x993C3C43)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Orders',
                hintStyle: TextStyle(
                  color: Color(0x993C3C43),
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildTabButton('All'),
              const SizedBox(width: 12),
              _buildTabButton('Pending'),
              const SizedBox(width: 12),
              _buildTabButton('Completed'),
              const SizedBox(width: 12),
              _buildTabButton('Cancelled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black : const Color(0xFF8A8A8F),
            fontSize: isSelected ? 14 : 12,
            fontFamily: 'SF Pro',
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    final filteredOrders = _filteredOrders;

    if (_isLoading && _userOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadUserOrders(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredOrders.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredOrders.length) {
            // 加载更多指示器
            if (!_isLoading) {
              // 使用addPostFrameCallback避免在build过程中调用setState
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadUserOrders();
              });
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildOrderCard(filteredOrders[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无${_selectedTab == 'All'
                ? ''
                : _selectedTab == 'Pending'
                ? '待处理'
                : _selectedTab == 'Completed'
                ? '已完成'
                : '已取消'}订单',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快去购买您喜欢的商品吧！',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String orderId = order['id']?.toString() ?? 'Unknown';
    final double price = (order['finalProductPrice'] ?? 0).toDouble();
    final String status = order['status'] ?? 'Unknown';
    final String createTime = order['createTime'] ?? '';
    final bool isAuction = order['isAuction'] ?? false;
    final bool isSelfPickup = order['isSelfPickup'] ?? false;

    // 获取商品信息
    final Map<String, dynamic>? product =
        order['product'] as Map<String, dynamic>?;
    final String productName = product?['name'] ?? 'Unknown Product';

    // 解析商品图片URL
    String imageUrl = '';
    try {
      final imageUrlJson = product?['imageUrlJson'] as String?;
      if (imageUrlJson != null && imageUrlJson.isNotEmpty) {
        final Map<String, dynamic> imageMap = json.decode(imageUrlJson);
        if (imageMap.containsKey('1')) {
          imageUrl = imageMap['1'] as String;
        } else if (imageMap.isNotEmpty) {
          imageUrl = imageMap.values.first as String;
        }
      }
    } catch (e) {
      print('解析商品图片URL失败: $e');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 订单头部信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #$orderId',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 8),

          // 订单详情
          Row(
            children: [
              // 商品图片
              Container(
                width: 80,
                height: 80,
                decoration: ShapeDecoration(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品名称
                    Text(
                      productName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 价格
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(
                            color: Color(0xFFFFA500),
                            fontSize: 14,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          price.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFFFFA500),
                            fontSize: 20,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 订单标签
                    Wrap(
                      spacing: 4,
                      children: [
                        if (isAuction) _buildTagChip('Consignment'),
                        if (isSelfPickup)
                          _buildTagChip('Self Pickup')
                        else
                          _buildTagChip('Shipping'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 创建时间
                    Text(
                      'Ordered: ${_formatDate(createTime)}',
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
            ],
          ),

          const SizedBox(height: 12),

          // 操作按钮区域
          Row(
            children: [
              // 主要操作按钮
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Wrap(
                        spacing: 4,
                        children: [
                          _buildActionButton('Details', () {
                            // 查看详情功能
                          }),

                          // 添加确认收货按钮（对于寄卖商品和所有非寄卖商品）
                          if ((status.toLowerCase() == 'pending_receipt') ||
                              (status.toLowerCase() == 'delivered' &&
                                  isAuction))
                            _buildActionButton('Confirm', () {
                              // 导航到确认收货页面
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ConfirmReceiptPage(orderId: orderId),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    // 更多操作菜单（包含退货选项和联系卖家）
                    if (_shouldShowMoreMenu(status))
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'refund':
                                Navigator.pushNamed(
                                  context,
                                  '/refund-application',
                                  arguments: {'orderId': orderId},
                                );
                                break;
                              case 'contact':
                                // 联系卖家功能
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            // 退货申请选项
                            if (_canApplyRefund(status))
                              const PopupMenuItem<String>(
                                value: 'refund',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.assignment_return,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Apply Refund',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // 联系卖家选项
                            if (status.toLowerCase() == 'pending_receipt')
                              const PopupMenuItem<String>(
                                value: 'contact',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chat,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Contact Seller',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending_receipt':
        backgroundColor = const Color(0x0AFCA600);
        textColor = const Color(0xFFFCA600);
        displayText = 'Pending';
        break;
      case 'pending_shipment':
        backgroundColor = const Color(0x0A267AFF);
        textColor = const Color(0xFF267AFF);
        displayText = 'Preparing';
        break;
      case 'delivered':
        backgroundColor = const Color(0x0A35B13F);
        textColor = const Color(0xFF35B13F);
        displayText = 'Delivered';
        break;
      case 'return_initiated':
        backgroundColor = const Color(0x0AFF8C00);
        textColor = const Color(0xFFFF8C00);
        displayText = 'Return Applied';
        break;
      case 'completed':
      case 'received':
      case 'confirmed':
        backgroundColor = const Color(0x0A35B13F);
        textColor = const Color(0xFF35B13F);
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = const Color(0x0AFF4444);
        textColor = const Color(0xFFFF4444);
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = const Color(0x0A8A8A8F);
        textColor = const Color(0xFF8A8A8F);
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: textColor),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    Color backgroundColor;
    Color textColor;

    switch (tag.toLowerCase()) {
      case 'consignment':
        backgroundColor = const Color(0x0A267AFF);
        textColor = const Color(0xFF267AFF);
        break;
      case 'self pickup':
        backgroundColor = const Color(0x0A35B13F);
        textColor = const Color(0xFF35B13F);
        break;
      case 'shipping':
        backgroundColor = const Color(0x0AFCA600);
        textColor = const Color(0xFFFCA600);
        break;
      default:
        backgroundColor = const Color(0x0A8A8A8F);
        textColor = const Color(0xFF8A8A8F);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.20, color: textColor),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: const ShapeDecoration(
          color: Color(0xFFFFA500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'Unknown';
      final DateTime date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 检查是否可以申请退货
  bool _canApplyRefund(String status) {
    final statusLower = status.toLowerCase();
    return statusLower == 'pending_shipment' ||
        statusLower == 'pending_receipt' ||
        statusLower == 'delivered';
  }

  /// 检查是否应该显示更多菜单
  bool _shouldShowMoreMenu(String status) {
    final statusLower = status.toLowerCase();
    // 如果可以申请退货或者可以联系卖家，则显示更多菜单
    return _canApplyRefund(status) || statusLower == 'pending_receipt';
  }
}
