import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../api/auth_api.dart';
import '../api/seller_api.dart';
import '../models/sys_menu.dart';
import '../stores/auth_store.dart';
import '../utils/auth_utils.dart';
import 'home_page.dart';
import 'my_profile_page.dart';
import 'search_page.dart';
import 'chat_page.dart';

// 自定义绘制器，用于绘制平坦的导航栏
class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // 简单的矩形导航栏
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 绘制阴影
    canvas.drawRect(rect, shadowPaint);
    // 绘制导航栏
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({Key? key}) : super(key: key);

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _selectedIndex = 0;
  bool _hasProcessedInitialArgs = false;
  bool _isLoading = true;
  String _username = '';
  String _nickname = '';
  String _avatar = '';
  List<SysMenu> _menus = [];
  bool _isCheckingStripeAccount = false;

  // 页面列表
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 初始化页面列表
    _pages = [
      HomeContentPage(onSearchTap: () => _switchToSearchPage()), // 首页内容
      const SearchPage(), // 搜索页面
      const ChatPage(), // 聊天页面
      const MyProfilePage(), // 个人主页
    ];

    // 设置为加载完成，无论是否登录
    setState(() {
      _isLoading = false;
    });

    // 只有在已登录状态下才加载用户信息和菜单
    if (authStore.isAuthenticated) {
      _loadUserInfo();
      _loadMenus();
    }
  }

  Future<void> _loadUserInfo() async {
    // 再次检查登录状态
    if (!authStore.isAuthenticated) {
      return;
    }

    try {
      final userInfo = await AuthApi.getUserInfo();
      if (userInfo != null && userInfo['user'] != null) {
        setState(() {
          _username = userInfo['user'].username ?? '';
          _nickname = userInfo['user'].nickname ?? _username;
          _avatar = userInfo['user'].avatar ?? '';
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  Future<void> _loadMenus() async {
    // 再次检查登录状态
    if (!authStore.isAuthenticated) {
      return;
    }

    try {
      final menus = await AuthApi.getMenus();
      if (menus != null) {
        setState(() {
          _menus = menus;
        });
      }
    } catch (e) {
      print('加载菜单失败: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 只在第一次加载时检查参数来设置选中的tab
    if (!_hasProcessedInitialArgs) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('selectedTab')) {
        setState(() {
          _selectedIndex = args['selectedTab'] as int;
        });
      }
      _hasProcessedInitialArgs = true;
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 切换到搜索页面
  void _switchToSearchPage() {
    setState(() {
      _selectedIndex = 1; // 搜索页面在索引1
    });
  }

  // 检查Stripe账户状态并处理发布商品逻辑
  Future<void> _handleListItemTap() async {
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
          message: 'Please login to list your items',
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
          'You need to set up a payment account before listing items',
        );
        return;
      }

      final canReceivePayments =
          accountInfo['canReceivePayments'] as bool? ?? false;
      final accountStatus =
          accountInfo['accountStatus'] as String? ?? 'pending';
      final verificationStatus =
          accountInfo['verificationStatus'] as String? ?? 'unverified';

      // 3. 检查账户状态是否满足发布商品的条件
      if (!canReceivePayments || accountStatus != 'active') {
        String message =
            'Your payment account status is abnormal, please complete the setup before listing items';
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

      // 4. 账户状态正常，可以发布商品
      if (mounted) {
        Navigator.pushNamed(context, '/list-item');
      }
    } catch (e) {
      print('Check Stripe account status failed: $e');

      // Network error or other exceptions, prompt the user to check the network and try again
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
              onPressed: _handleListItemTap,
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
      // 连贯跳转：先跳转到个人主页，然后自动跳转到设置页面
      setState(() {
        _selectedIndex = 3; // 切换到"我的"tab页
      });

      // 等待页面切换完成后跳转到设置页面
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        await Navigator.pushNamed(context, '/settings');

        // 从设置页面返回后，可能需要重新检查账户状态
        // 这里可以选择自动重新检查，或者让用户重新点击
      }
    }
  }

  // 构建底部导航栏（不包含按钮）
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      child: CustomPaint(
        size: Size(
          MediaQuery.of(context).size.width,
          70 + MediaQuery.of(context).padding.bottom,
        ),
        painter: BottomNavPainter(),
        child: Container(
          height: 70 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                'assets/icons/main_layout/home.svg',
                'assets/icons/main_layout/home_select.svg',
                'Home',
                0,
              ),
              _buildNavItem(
                'assets/icons/main_layout/search.svg',
                'assets/icons/main_layout/search_select.svg',
                'Search',
                1,
              ),
              const SizedBox(width: 60), // 为中央按钮留空间
              _buildNavItem(
                'assets/icons/main_layout/message.svg',
                'assets/icons/main_layout/message_select.svg',
                'Chat',
                2,
              ),
              _buildNavItem(
                'assets/icons/main_layout/profile.svg',
                'assets/icons/main_layout/profile_select.svg',
                'My',
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建浮动按钮
  Widget _buildFloatingButton() {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 40, // 居中定位
      bottom: MediaQuery.of(context).padding.bottom + 10, // 突出导航栏
      child: GestureDetector(
        onTap: _handleListItemTap, // 使用新的处理逻辑
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFB347), // 浅橙色
                Color(0xFFFFA500), // 标准橙色
                Color(0xFFFF8C00), // 深橙色
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA500).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFFFFA500).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: _isCheckingStripeAccount
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Transform.scale(
                  scale: 0.55, // 缩放到60%大小
                  child: SvgPicture.asset(
                    'assets/icons/main_layout/mid_button.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // 构建导航项
  Widget _buildNavItem(
    String unselectedIconPath,
    String selectedIconPath,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SvgPicture.asset(
          isSelected ? selectedIconPath : unselectedIconPath,
          width: 18,
          height: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁止返回手势
      onPopInvokedWithResult: (didPop, result) {
        // 如果用户尝试返回，什么都不做
        // 这样可以防止侧滑返回到上一页
        if (didPop) return;

        // 可以在这里添加额外的逻辑，比如显示确认对话框
        // 但为了简单起见，我们直接阻止返回
        print('主页面阻止了返回操作');
      },
      child: Stack(
        children: [
          // Scaffold在底层
          Scaffold(
            backgroundColor: Colors.white,
            body: Column(children: [Expanded(child: _pages[_selectedIndex])]),
            bottomNavigationBar: _buildBottomNavigationBar(),
            extendBody: false, // 不延伸到底部导航栏下方
          ),
          // 浮动按钮在最上层
          _buildFloatingButton(),
        ],
      ),
    );
  }
}
