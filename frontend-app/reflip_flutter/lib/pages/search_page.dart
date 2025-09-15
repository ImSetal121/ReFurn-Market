import 'package:flutter/material.dart';
import 'dart:convert';
import '../api/visitor_api.dart';
import '../widgets/product_card.dart';
import '../widgets/ios_keyboard_toolbar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String _selectedFilter = 'Recommended';

  // 商品数据
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  // 搜索参数
  String? _searchType;
  String? _searchCategory;
  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _searchController.text = _searchQuery;
    _scrollController.addListener(_onScroll);
    _searchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 监听滚动，实现分页加载
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreProducts();
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    // 只更新搜索词，不触发搜索
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      _searchQuery = query;
    });
    // 只有在用户点击搜索按钮时才触发搜索
    _searchProducts();
  }

  // 搜索商品
  Future<void> _searchProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final response = await VisitorApi.searchProducts(
        keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
        type: _searchType,
        category: _searchCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _getSortByValue(_selectedFilter),
        page: _currentPage,
        size: _pageSize,
      );

      if (response != null && mounted) {
        setState(() {
          _products = _parseProducts(response['records'] ?? []);
          // 使用MyBatis Plus的分页信息来判断是否还有更多数据
          // 当前页数小于总页数时，说明还有更多数据
          final currentPage = response['current'] ?? 1;
          final pages = response['pages'] ?? 1;
          _hasMoreData = currentPage < pages;
        });
      }
    } catch (e) {
      print('搜索商品失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 加载更多商品
  Future<void> _loadMoreProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await VisitorApi.loadMoreProducts(
        keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
        type: _searchType,
        category: _searchCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _getSortByValue(_selectedFilter),
        nextPage: _currentPage + 1,
        size: _pageSize,
      );

      if (response != null && mounted) {
        final newProducts = _parseProducts(response['records'] ?? []);
        setState(() {
          _products.addAll(newProducts);
          _currentPage++;
          // 使用MyBatis Plus的分页信息来判断是否还有更多数据
          final currentPage = response['current'] ?? _currentPage;
          final pages = response['pages'] ?? 1;
          _hasMoreData = currentPage < pages;
        });
      }
    } catch (e) {
      print('加载更多商品失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  // 解析后端商品数据为ProductCard格式
  List<Map<String, dynamic>> _parseProducts(List<dynamic> products) {
    return products.map((product) {
      return ProductCard.fromBackendData(product as Map<String, dynamic>);
    }).toList();
  }

  // 获取排序参数
  String _getSortByValue(String filterName) {
    switch (filterName.toLowerCase()) {
      case 'price':
        return 'price_asc';
      case 'distance':
        return 'distance';
      case 'condition':
        return 'condition';
      case 'recommended':
      default:
        return 'recommended';
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
      body: GestureDetector(
        // 点击空白处取消焦点，收起键盘
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        // 确保空白区域也能接收到点击事件
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            // 搜索框区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 50,
                left: 12,
                right: 12,
                bottom: 10,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: const Color(0x1E787880),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Color(0x993C3C43),
                            size: 17,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: KeyboardToolbarBuilder.buildSingle(
                              textField: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: _onSearchChanged,
                                onSubmitted: _onSearchSubmitted,
                                textInputAction: TextInputAction.search,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                              focusNode: _searchFocusNode,
                              doneButtonText: 'Done',
                            ),
                          ),
                          GestureDetector(
                            onTap: _showFeatureUnderDevelopment,
                            child: const Icon(
                              Icons.mic,
                              color: Color(0x993C3C43),
                              size: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFeatureUnderDevelopment,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                      ),
                      child: const Icon(Icons.camera_alt, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFeatureUnderDevelopment,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                      ),
                      child: const Icon(Icons.notifications, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // 筛选标签
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterTab(
                    'Recommended',
                    _selectedFilter == 'Recommended',
                  ),
                  _buildFilterTab('Price', _selectedFilter == 'Price'),
                  _buildFilterTab('Distance', _selectedFilter == 'Distance'),
                  _buildFilterTab('Condition', _selectedFilter == 'Condition'),
                ],
              ),
            ),

            // 商品网格
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: _isLoading && _products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _products.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(
                            color: Color(0xFF8A8A8F),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(top: 24),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return ProductCard(
                                  product: _products[index],
                                  // 不提供onTap，使用ProductCard默认的跳转逻辑
                                );
                              }, childCount: _products.length),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // 每行显示2个商品
                                    childAspectRatio: 0.8, // 宽高比
                                    crossAxisSpacing: 16, // 水平间距
                                    mainAxisSpacing: 16, // 垂直间距
                                  ),
                            ),
                          ),
                          // 加载更多指示器
                          if (_isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          // 底部安全区域，避免被底部导航栏遮挡
                          SliverPadding(
                            padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 100,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() {
          _selectedFilter = title;
        });
        _searchProducts(); // 重新搜索
      },
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF8A8A8F),
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 12,
            color: isSelected ? Colors.black : const Color(0xFF8A8A8F),
          ),
        ],
      ),
    );
  }
}
