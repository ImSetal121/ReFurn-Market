import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/seller_api.dart';
import '../stores/auth_store.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({Key? key}) : super(key: key);

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  List<Map<String, dynamic>> _userProducts = [];
  bool _isLoading = false;
  String _selectedTab = 'For Sale';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProducts() async {
    if (!authStore.isAuthenticated) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final products = await SellerApi.getMyProducts();
      if (products != null) {
        setState(() {
          _userProducts = products;
        });
      }
    } catch (e) {
      print('加载用户商品失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _userProducts.where((product) {
      final status = product['status']?.toString().toLowerCase() ?? '';
      switch (_selectedTab) {
        case 'For Sale':
          return status == 'listed' || status == 'for_sale';
        case 'Returned':
          return status == 'returned_to_seller';
        case 'Unlisted':
          return status == 'unlisted' || status == 'inactive';
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProductGrid(),
            ),
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
                'My Post',
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
                hintText: 'Search',
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
              _buildTabButton('For Sale'),
              const SizedBox(width: 12),
              _buildTabButton('Returned'),
              const SizedBox(width: 12),
              _buildTabButton('Unlisted'),
            ],
          ),
          Container(
            width: 24,
            height: 24,
            child: const Icon(Icons.tune, size: 20, color: Colors.black54),
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

  Widget _buildProductGrid() {
    final filteredProducts = _filteredProducts;

    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 160 / 220, // 更新宽高比
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          return _buildProductCard(filteredProducts[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无${_selectedTab == 'For Sale'
                ? '在售'
                : _selectedTab == 'Returned'
                ? '已退回'
                : '下架'}商品',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTab == 'Returned' ? '暂时没有退回的商品' : '开始发布您的第一个商品吧！',
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    final String name = product['name'] ?? 'Unknown Product';
    final double price = (product['price'] ?? 0).toDouble();

    // 解析图片URL JSON，参考profile_page.dart的方式
    String imageUrl = '';
    try {
      final imageUrlJson = product['imageUrlJson'] as String?;
      if (imageUrlJson != null && imageUrlJson.isNotEmpty) {
        // 解析JSON字符串，获取键值为"1"的图片URL作为封面
        final Map<String, dynamic> imageMap = json.decode(imageUrlJson);
        if (imageMap.containsKey('1')) {
          imageUrl = imageMap['1'] as String;
        } else if (imageMap.isNotEmpty) {
          // 如果没有键值"1"，取第一个可用的图片
          imageUrl = imageMap.values.first as String;
        }
      }
    } catch (e) {
      print('解析图片URL失败: $e');
    }

    final int views = product['views'] ?? 47;
    final int saves = product['saves'] ?? 12;

    return Container(
      width: 160,
      height: 220, // 进一步增加高度以防止溢出
      decoration: const ShapeDecoration(
        color: Color(0xFFFBFBFB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片
          Container(
            width: 160,
            height: 120,
            decoration: const ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, 0.00),
                end: Alignment(0.73, 1.00),
                colors: [Color(0xFFFFFAF1), Color(0xFFF6F6F6)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 160,
                      height: 120,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                  ),
          ),
          // 商品信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6), // 减少padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名称
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 11,
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w400,
                      height: 1.2, // 减少行高
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // 减少间距
                  // 商品状态标签（仅在已退回时显示）
                  if (product['status']?.toString().toLowerCase() ==
                      'returned_to_seller') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1A666666),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF666666),
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        'Returned',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 8,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  // 价格和统计信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 价格
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            '\$',
                            style: TextStyle(
                              color: Color(0xFFFFA500),
                              fontSize: 10,
                              fontFamily: 'PingFang SC',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            price.toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xFFFFA500),
                              fontSize: 16,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      // 统计信息
                      Text(
                        'Views $views Saves $saves',
                        style: const TextStyle(
                          color: Color(0xFF8A8A8F),
                          fontSize: 6,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 底部操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_buildMenuButton(product)],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: const ShapeDecoration(
          color: Color(0xFFEBEBEB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x3F8E8E8E),
              blurRadius: 1,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 构建菜单按钮
  Widget _buildMenuButton(Map<String, dynamic> product) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        switch (value) {
          case 'return':
            _handleReturnProduct(product);
            break;
          case 'lower_price':
            // TODO: 实现降价功能
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('降价功能开发中')));
            break;
          case 'edit':
            // TODO: 实现编辑功能
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('编辑功能开发中')));
            break;
          case 'view_details':
            // TODO: 实现查看详情功能
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('查看退回详情功能开发中')));
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        final List<PopupMenuEntry<String>> items = [];

        // 检查是否为上架的寄卖商品，如果是则显示退回选项
        if (product['status']?.toString().toLowerCase() == 'listed' &&
            product['isAuction'] == true) {
          items.add(
            const PopupMenuItem<String>(
              value: 'return',
              child: Row(
                children: [
                  Icon(Icons.undo, size: 16, color: Color(0xFFFFA500)),
                  SizedBox(width: 8),
                  Text(
                    'Return to Seller',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 添加其他通用选项
        items.addAll([
          // 只有非退回状态的商品才显示降价选项
          if (product['status']?.toString().toLowerCase() !=
              'returned_to_seller')
            const PopupMenuItem<String>(
              value: 'lower_price',
              child: Row(
                children: [
                  Icon(Icons.trending_down, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Lower Price',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          // 只有非退回状态的商品才显示编辑选项
          if (product['status']?.toString().toLowerCase() !=
              'returned_to_seller')
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          // 为已退回的商品显示查看详情选项
          if (product['status']?.toString().toLowerCase() ==
              'returned_to_seller')
            const PopupMenuItem<String>(
              value: 'view_details',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF666666)),
                  SizedBox(width: 8),
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ]);

        return items;
      },
      icon: Container(
        width: 24,
        height: 24,
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Color(0xFFEBEBEB),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, size: 12, color: Colors.grey),
      ),
      padding: EdgeInsets.zero,
      tooltip: '',
      iconSize: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      color: Colors.white,
    );
  }

  /// 处理商品退回
  void _handleReturnProduct(Map<String, dynamic> product) async {
    final result = await Navigator.pushNamed(
      context,
      '/confirm-return-to-seller',
      arguments: {'product': product},
    );

    // 如果退回成功，刷新商品列表
    if (result != null &&
        result is Map<String, dynamic> &&
        result['success'] == true) {
      _loadUserProducts();
    }
  }
}
