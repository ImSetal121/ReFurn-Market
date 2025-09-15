import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../api/seller_api.dart';
import '../stores/auth_store.dart';

class MySalesPage extends StatefulWidget {
  const MySalesPage({Key? key}) : super(key: key);

  @override
  State<MySalesPage> createState() => _MySalesPageState();
}

class _MySalesPageState extends State<MySalesPage> {
  List<Map<String, dynamic>> _userSales = [];
  bool _isLoading = false;
  String _selectedTab = 'All';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUserSales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSales({bool isRefresh = false}) async {
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
      final result = await SellerApi.getMySales(page: _currentPage, size: 10);

      if (result != null && mounted) {
        setState(() {
          if (isRefresh) {
            _userSales = result;
          } else {
            _userSales.addAll(result);
          }
          _currentPage++;
          _hasMore = result.length >= 10;
        });
      }
    } catch (e) {
      print('加载销售记录失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredSales {
    return _userSales.where((sale) {
      final status = sale['status']?.toString().toLowerCase() ?? '';
      switch (_selectedTab) {
        case 'All':
          return true;
        case 'Pending':
          return status == 'pending_receipt' ||
              status == 'pending' ||
              status == 'return_initiated' ||
              status == 'returned_to_seller';
        case 'Completed':
          return status == 'completed' ||
              status == 'received' ||
              status == 'return_completed' ||
              status == 'returned_to_warehouse_confirmed';
        case 'Cancelled':
          return status == 'cancelled' || status == 'return_negotiation_failed';
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
            Expanded(child: _buildSalesList()),
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
                'My Sales',
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
                hintText: 'Search Sales',
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

  Widget _buildSalesList() {
    final filteredSales = _filteredSales;

    if (_isLoading && _userSales.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredSales.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadUserSales(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredSales.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredSales.length) {
            if (!_isLoading) {
              // 使用 WidgetsBinding.instance.addPostFrameCallback 延迟调用
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadUserSales();
              });
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildSalesCard(filteredSales[index]);
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
                : '已取消'}销售记录',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快去发布您的商品吧！',
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

  Widget _buildSalesCard(Map<String, dynamic> sale) {
    final String saleId = sale['id']?.toString() ?? 'Unknown';
    final double price = (sale['finalProductPrice'] ?? 0).toDouble();
    final String status = sale['status'] ?? 'Unknown';
    final String createTime = sale['createTime'] ?? '';
    final bool isAuction = sale['isAuction'] ?? false;
    final bool isSelfPickup = sale['isSelfPickup'] ?? false;

    // 获取商品信息
    final Map<String, dynamic>? product =
        sale['product'] as Map<String, dynamic>?;
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
          // 销售记录头部信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sale #$saleId',
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

          // 销售记录详情
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

                    // 销售记录标签
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
                      'Sold: ${_formatDate(createTime)}',
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

          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton('View Details', () {
                // 查看详情功能
              }),
              const SizedBox(width: 8),
              if (status.toLowerCase() == 'pending_receipt')
                _buildActionButton('Contact Buyer', () {
                  // 联系买家功能
                })
              else if (status.toLowerCase() == 'return_initiated')
                _buildActionButton('View Return Request', () {
                  _viewReturnRequest(saleId);
                })
              else if (status.toLowerCase() == 'returned_to_seller')
                _buildActionButton('Confirm Received', () {
                  _confirmReturnReceived(saleId);
                }),
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
      case 'return_initiated':
        backgroundColor = const Color(0x0AFF9500);
        textColor = const Color(0xFFFF9500);
        displayText = 'Return Requested';
        break;
      case 'return_negotiation_failed':
        backgroundColor = const Color(0x0AFF4444);
        textColor = const Color(0xFFFF4444);
        displayText = 'Return Rejected';
        break;
      case 'returned_to_seller':
        backgroundColor = const Color(0x0A267AFF);
        textColor = const Color(0xFF267AFF);
        displayText = 'Returned to Seller';
        break;
      case 'returned_to_warehouse_confirmed':
        backgroundColor = const Color(0x0A35B13F);
        textColor = const Color(0xFF35B13F);
        displayText = 'Returned';
        break;
      case 'return_completed':
        backgroundColor = const Color(0x0A35B13F);
        textColor = const Color(0xFF35B13F);
        displayText = 'Return Completed';
        break;
      case 'completed':
      case 'received':
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const ShapeDecoration(
          color: Color(0xFFFFA500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
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

  // 查看退货申请
  void _viewReturnRequest(String sellRecordId) async {
    final result = await Navigator.pushNamed(
      context,
      '/return-request-detail',
      arguments: {'sellRecordId': sellRecordId},
    );

    // 如果处理了退货申请，刷新列表
    if (result == true) {
      _loadUserSales(isRefresh: true);
    }
  }

  // 确认收到退货
  void _confirmReturnReceived(String sellRecordId) async {
    try {
      // 显示确认对话框
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('确认收到退货'),
            content: const Text('您确认已经收到退回的商品吗？确认后将完成退货流程。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('确认'),
              ),
            ],
          );
        },
      );

      // 如果用户确认了
      if (confirmed == true) {
        // 显示加载指示器
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('正在处理...'),
                ],
              ),
            );
          },
        );

        // 调用API确认收到退货
        final success = await SellerApi.confirmReturnReceived(sellRecordId);

        // 关闭加载对话框
        Navigator.of(context).pop();

        if (success) {
          // 显示成功消息
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已确认收到退货，退货流程完成'),
              backgroundColor: Colors.green,
            ),
          );

          // 刷新销售记录列表
          _loadUserSales(isRefresh: true);
        } else {
          // 显示错误消息
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('确认失败，请稍后重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 关闭加载对话框（如果存在）
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('确认收到退货失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('确认失败: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
