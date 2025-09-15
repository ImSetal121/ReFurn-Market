import 'package:flutter/material.dart';
import '../api/user_api.dart';
import '../widgets/product_card.dart';
import '../utils/auth_utils.dart';
import '../stores/auth_store.dart';

class MyFavoriteProductsPage extends StatefulWidget {
  const MyFavoriteProductsPage({Key? key}) : super(key: key);

  @override
  State<MyFavoriteProductsPage> createState() => _MyFavoriteProductsPageState();
}

class _MyFavoriteProductsPageState extends State<MyFavoriteProductsPage> {
  final ScrollController _scrollController = ScrollController();

  // 商品数据
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkLoginAndLoadFavorites();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 检查登录状态并加载收藏商品
  Future<void> _checkLoginAndLoadFavorites() async {
    if (!mounted) return;

    // 检查登录状态
    final isLoggedIn = authStore.isAuthenticated;
    if (!isLoggedIn) {
      if (mounted) {
        // 如果未登录，跳转到登录页面
        final success = await AuthUtils.requireLogin(
          context,
          message: 'Please login to view your favorite products',
        );
        if (success) {
          _loadFavoriteProducts();
        } else {
          // 如果用户取消登录，返回上一页
          Navigator.of(context).pop();
        }
      }
      return;
    }

    // 已登录，加载收藏商品
    _loadFavoriteProducts();
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

  // 加载收藏商品
  Future<void> _loadFavoriteProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final response = await UserApi.getUserFavoriteProducts(
        page: _currentPage,
        size: _pageSize,
      );

      if (response != null && mounted) {
        setState(() {
          _products = _parseProducts(response['records'] ?? []);
          // 使用MyBatis Plus的分页信息来判断是否还有更多数据
          final currentPage = response['current'] ?? 1;
          final pages = response['pages'] ?? 1;
          _hasMoreData = currentPage < pages;
        });
      }
    } catch (e) {
      print('Failed to load favorite products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load favorite products: $e')),
        );
      }
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
      final response = await UserApi.loadMoreFavoriteProducts(
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
      print('Failed to load more favorite products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more favorite products: $e')),
        );
      }
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

  // 下拉刷新
  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _loadFavoriteProducts();
      // 刷新成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refresh successful'),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFFFFA500),
          ),
        );
      }
    } catch (e) {
      // 刷新失败提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isRefreshing ? null : _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFFFFA500),
        child: _isLoading && _products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
            ? _buildEmptyState()
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 24),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    // 底部安全区域，避免被底部导航栏遮挡
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 100,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // 空状态组件
  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No favorite products yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse products and add your favorites',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // 跳转到搜索页面
                    Navigator.of(context).pushReplacementNamed('/search');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Browse Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
