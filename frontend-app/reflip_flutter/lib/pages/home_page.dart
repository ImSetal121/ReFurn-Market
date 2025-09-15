import 'package:flutter/material.dart';
import 'category_products_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _selectedTabIndex = 0; // 0: Local, 1: U.S., 2: Community

  // 家具分类数据
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Living Room',
      'image': 'assets/images/living_room.png',
      'hasImage': true,
    },
    {
      'title': 'Bedroom',
      'image': 'assets/images/bedroom.png',
      'hasImage': true,
    },
    {
      'title': 'Office & Study',
      'image': 'assets/images/office_study.png',
      'hasImage': true,
    },
    {
      'title': 'Dining Room',
      'image': 'assets/images/dining_room.png',
      'hasImage': true,
    },
    {
      'title': 'Hallway',
      'image': 'assets/images/hallway.png',
      'hasImage': true,
    },
    {
      'title': 'Accessories',
      'image': 'assets/images/accessories.png',
      'hasImage': true,
    },
    {
      'title': 'Outdoor',
      'image': 'assets/images/outdoor.jpg',
      'hasImage': true,
    },
    {
      'title': 'Appliances',
      'image': 'assets/images/appliances.jpg',
      'hasImage': true,
    },
    {
      'title': 'Lighting',
      'image': 'assets/images/lighting.jpg',
      'hasImage': true,
    },
    {'title': 'Others', 'image': 'assets/images/other.jpg', 'hasImage': true},
  ];

  @override
  void initState() {
    super.initState();
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

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 暂时显示功能开发中提示
    _showFeatureUnderDevelopment();
  }

  void _onTabTap(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    // 暂时显示功能开发中提示，因为标签页切换还没有实际内容变化
    _showFeatureUnderDevelopment();
  }

  Widget _buildTopHeader() {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Berkeley 标题和搜索栏
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    // Berkeley 标题
                    GestureDetector(
                      onTap: _showFeatureUnderDevelopment,
                      child: Row(
                        children: [
                          const Text(
                            'Berkeley',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              height: 1.57,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 搜索栏
                    Expanded(
                      child: GestureDetector(
                        onTap: _showFeatureUnderDevelopment,
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: ShapeDecoration(
                            color: const Color(0x1E787880),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 17,
                                color: Color(0x993C3C43),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Color(0x993C3C43),
                                    fontSize: 17,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                    height: 1.29,
                                    letterSpacing: -0.43,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showFeatureUnderDevelopment,
                                child: const Icon(
                                  Icons.mic,
                                  size: 17,
                                  color: Color(0x993C3C43),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 相机和通知图标
                    GestureDetector(
                      onTap: _showFeatureUnderDevelopment,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: ShapeDecoration(
                          color: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 标签页
              Row(
                children: [
                  _buildTabItem('Local', 0),
                  const SizedBox(width: 24),
                  _buildTabItem('U.S.', 1),
                  const SizedBox(width: 24),
                  _buildTabItem('Community', 2),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF8A8A8F),
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 48,
            height: 2,
            decoration: ShapeDecoration(
              color: isSelected ? const Color(0xFFFFA500) : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 148,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFFFFA500), Color(0x72FFA500)],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Stack(
        children: [
          // 左侧文字内容
          Positioned(
            left: 24,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Up to 30% off all\nitems',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // 右侧装饰图片
          Positioned(
            right: 20,
            top: 20,
            child: Image.asset(
              'assets/images/hero_furniture.png',
              width: 124,
              height: 108,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 124,
                  height: 108,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.chair, size: 60, color: Colors.white),
                );
              },
            ),
          ),
          // 小装饰图片
          Positioned(
            right: 30,
            bottom: 20,
            child: Transform.rotate(
              angle: 3.14,
              child: Image.asset(
                'assets/images/hero_decoration.png',
                width: 48,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.home,
                      size: 24,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, double cardWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsPage(
              categoryTitle: category['title'],
              categoryImage: category['image'],
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        height: 200,
        decoration: ShapeDecoration(
          color: const Color(0xFFFBFBFB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 160,
              padding: const EdgeInsets.all(0),
              decoration: ShapeDecoration(
                color: const Color(0xFFF3F3F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: category['hasImage']
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        category['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFD9D9D9),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Text(
                        'ICON',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8D8D8D),
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    category['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A1C1E),
                      fontSize: 14,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算每个卡片的宽度，确保一行显示两个
          final spacing = 24.0;
          final cardWidth = (constraints.maxWidth - spacing) / 2;

          return Column(
            children: [
              for (int i = 0; i < _categories.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i + 2 < _categories.length ? 25 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryCard(_categories[i], cardWidth),
                      if (i + 1 < _categories.length)
                        _buildCategoryCard(_categories[i + 1], cardWidth)
                      else
                        SizedBox(width: cardWidth), // 占位符，保持对齐
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 83 + MediaQuery.of(context).padding.bottom,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 83 + MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3FD9D9D9),
                    blurRadius: 19,
                    offset: Offset(0, -10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, 0),
                  _buildNavItem(Icons.favorite_border, 1),
                  const SizedBox(width: 86), // 为中央按钮留空间
                  _buildNavItem(Icons.shopping_bag_outlined, 2),
                  _buildNavItem(Icons.person_outline, 3),
                ],
              ),
            ),
          ),
          // 中央浮动按钮
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showFeatureUnderDevelopment,
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFA500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x4CFFA500),
                        blurRadius: 17,
                        offset: Offset(0, 16),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        width: 22,
        height: 22,
        child: Icon(
          icon,
          size: 22,
          color: isSelected ? const Color(0xFFFFA500) : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: 20 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeroSection(),
                  const SizedBox(height: 20),
                  _buildCategoriesGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      extendBody: true,
    );
  }
}

// 首页内容页面（不包含底部导航栏）
class HomeContentPage extends StatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeContentPage({Key? key, this.onSearchTap}) : super(key: key);

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  int _selectedTabIndex = 0; // 0: Local, 1: U.S., 2: Community

  // 家具分类数据
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Living Room',
      'image': 'assets/images/living_room.png',
      'hasImage': true,
    },
    {
      'title': 'Bedroom',
      'image': 'assets/images/bedroom.png',
      'hasImage': true,
    },
    {
      'title': 'Office & Study',
      'image': 'assets/images/office_study.png',
      'hasImage': true,
    },
    {
      'title': 'Dining Room',
      'image': 'assets/images/dining_room.png',
      'hasImage': true,
    },
    {
      'title': 'Hallway',
      'image': 'assets/images/hallway.png',
      'hasImage': true,
    },
    {
      'title': 'Accessories',
      'image': 'assets/images/accessories.png',
      'hasImage': true,
    },
    {
      'title': 'Outdoor',
      'image': 'assets/images/outdoor.jpg',
      'hasImage': true,
    },
    {
      'title': 'Appliances',
      'image': 'assets/images/appliances.jpg',
      'hasImage': true,
    },
    {
      'title': 'Lighting',
      'image': 'assets/images/lighting.jpg',
      'hasImage': true,
    },
    {'title': 'Others', 'image': 'assets/images/other.jpg', 'hasImage': true},
  ];

  @override
  void initState() {
    super.initState();
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

  void _onTabTap(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    // 暂时显示功能开发中提示，因为标签页切换还没有实际内容变化
    _showFeatureUnderDevelopment();
  }

  Widget _buildTopHeader() {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Berkeley 标题和搜索栏
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    // Berkeley 标题
                    GestureDetector(
                      onTap: _showFeatureUnderDevelopment,
                      child: Row(
                        children: [
                          const Text(
                            'Berkeley',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              height: 1.57,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 搜索栏
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            widget.onSearchTap ?? _showFeatureUnderDevelopment,
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: ShapeDecoration(
                            color: const Color(0x1E787880),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 17,
                                color: Color(0x993C3C43),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Color(0x993C3C43),
                                    fontSize: 17,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                    height: 1.29,
                                    letterSpacing: -0.43,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showFeatureUnderDevelopment,
                                child: const Icon(
                                  Icons.mic,
                                  size: 17,
                                  color: Color(0x993C3C43),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 相机和通知图标
                    GestureDetector(
                      onTap: _showFeatureUnderDevelopment,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: ShapeDecoration(
                          color: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 标签页
              Row(
                children: [
                  _buildTabItem('Local', 0),
                  const SizedBox(width: 24),
                  _buildTabItem('U.S.', 1),
                  const SizedBox(width: 24),
                  _buildTabItem('Community', 2),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF8A8A8F),
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 48,
            height: 2,
            decoration: ShapeDecoration(
              color: isSelected ? const Color(0xFFFFA500) : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 148,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFFFFA500), Color(0x72FFA500)],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Stack(
        children: [
          // 左侧文字内容
          Positioned(
            left: 24,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Up to 30% off all\nitems',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // 右侧装饰图片
          Positioned(
            right: 20,
            top: 20,
            child: Image.asset(
              'assets/images/hero_furniture.png',
              width: 124,
              height: 108,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 124,
                  height: 108,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.chair, size: 60, color: Colors.white),
                );
              },
            ),
          ),
          // 小装饰图片
          Positioned(
            right: 30,
            bottom: 20,
            child: Transform.rotate(
              angle: 3.14,
              child: Image.asset(
                'assets/images/hero_decoration.png',
                width: 48,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.home,
                      size: 24,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, double cardWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsPage(
              categoryTitle: category['title'],
              categoryImage: category['image'],
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        height: 200,
        decoration: ShapeDecoration(
          color: const Color(0xFFFBFBFB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 160,
              padding: const EdgeInsets.all(0),
              decoration: ShapeDecoration(
                color: const Color(0xFFF3F3F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: category['hasImage']
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        category['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFD9D9D9),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Text(
                        'ICON',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8D8D8D),
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    category['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A1C1E),
                      fontSize: 14,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算每个卡片的宽度，确保一行显示两个
          final spacing = 24.0;
          final cardWidth = (constraints.maxWidth - spacing) / 2;

          return Column(
            children: [
              for (int i = 0; i < _categories.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i + 2 < _categories.length ? 25 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryCard(_categories[i], cardWidth),
                      if (i + 1 < _categories.length)
                        _buildCategoryCard(_categories[i + 1], cardWidth)
                      else
                        SizedBox(width: cardWidth), // 占位符，保持对齐
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: 20 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeroSection(),
                const SizedBox(height: 20),
                _buildCategoriesGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
