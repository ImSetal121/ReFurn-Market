import 'package:flutter/material.dart';
import '../api/visitor_api.dart';
import '../widgets/product_card.dart';
import '../data/category_data.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryTitle;
  final String categoryImage;

  const CategoryProductsPage({
    Key? key,
    required this.categoryTitle,
    required this.categoryImage,
  }) : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final ScrollController _scrollController = ScrollController();

  // 商品数据
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  // 选中的子分类
  String _selectedSubCategory = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeData();
  }

  void _initializeData() {
    // 设置默认选中第一个子分类
    final subCats = CategoryData.getSubCategories(widget.categoryTitle);
    if (subCats.isNotEmpty) {
      _selectedSubCategory = subCats[0];
    }
    _searchProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  // 搜索商品
  Future<void> _searchProducts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final response = await VisitorApi.searchProducts(
        type: widget.categoryTitle,
        category: _selectedSubCategory.isNotEmpty ? _selectedSubCategory : null,
        sortBy: 'recommended',
        page: _currentPage,
        size: _pageSize,
      );

      if (response != null) {
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 加载更多商品
  Future<void> _loadMoreProducts() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await VisitorApi.loadMoreProducts(
        keyword: null,
        type: widget.categoryTitle,
        category: _selectedSubCategory.isNotEmpty ? _selectedSubCategory : null,
        minPrice: null,
        maxPrice: null,
        sortBy: 'recommended',
        nextPage: _currentPage + 1,
        size: _pageSize,
      );

      if (response != null) {
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
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // 解析后端商品数据
  List<Map<String, dynamic>> _parseProducts(List<dynamic> products) {
    return products.map((product) {
      return ProductCard.fromBackendData(product as Map<String, dynamic>);
    }).toList();
  }

  // 选择子分类
  void _onSubCategorySelected(String subCategory) {
    setState(() {
      _selectedSubCategory = subCategory;
    });
    _searchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部图片区域
          _buildHeaderSection(),
          // 商品内容区域
          _buildContentSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      height: 260,
      child: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: Image.asset(
              widget.categoryImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF3F3F3), Color(0xFFE0E0E0)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          // 遮罩层
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          // 返回按钮
          Positioned(
            left: 22,
            top: 60,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F7C7C7C),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // 分类标题
          Positioned(
            left: 22,
            bottom: 90,
            child: Text(
              widget.categoryTitle,
              style: const TextStyle(
                color: Color.fromARGB(184, 255, 255, 255),
                fontSize: 24,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // 子分类标签
          Positioned(
            left: 0,
            bottom: 20,
            right: 0,
            child: _buildSubCategoryTabs(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryTabs() {
    final subCats = CategoryData.getSubCategories(widget.categoryTitle);

    return Container(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subCats.length,
        itemBuilder: (context, index) {
          final subCategory = subCats[index];
          final isSelected = _selectedSubCategory == subCategory;

          return Container(
            margin: EdgeInsets.only(right: 16, left: index == 0 ? 16 : 0),
            child: GestureDetector(
              onTap: () => _onSubCategorySelected(subCategory),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: ShapeDecoration(
                  color: isSelected
                      ? const Color(0xFFFFA500)
                      : const Color.fromARGB(205, 243, 243, 243),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  subCategory,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color.fromARGB(187, 0, 0, 0),
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
        child: _isLoading && _products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
            ? const Center(
                child: Text(
                  'No products found',
                  style: TextStyle(color: Color(0xFF8A8A8F), fontSize: 16),
                ),
              )
            : Column(
                children: [
                  // 给顶部添加少量间距
                  // const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(top: 24), // 移除GridView默认的padding
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: _products[index]);
                      },
                    ),
                  ),
                  // 加载更多指示器
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
      ),
    );
  }
}
