import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../api/seller_api.dart';
import '../stores/auth_store.dart';
import '../services/chat_websocket_service.dart';
import '../utils/auth_utils.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _username = '';
  String _nickname = '';
  String _avatar = '';
  String _email = '';
  bool _isLoggingIn = false;
  List<Map<String, dynamic>> _userProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    setState(() {
      _isLoggedIn = authStore.isAuthenticated;
    });

    if (_isLoggedIn) {
      await _loadUserInfo();
      await _loadUserProducts();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await AuthApi.getUserInfo();
      if (userInfo != null && userInfo['user'] != null && mounted) {
        setState(() {
          _username = userInfo['user'].username ?? '';
          _nickname = userInfo['user'].nickname ?? _username;
          _avatar = userInfo['user'].avatar ?? '';
          _email = userInfo['user'].email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('加载用户信息失败: $e');
    }
  }

  Future<void> _loadUserProducts() async {
    if (!authStore.isAuthenticated || !mounted) return;

    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final products = await SellerApi.getMyProducts();
      if (products != null && mounted) {
        setState(() {
          _userProducts = products;
        });
      }
    } catch (e) {
      print('加载用户商品失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await AuthApi.logout();
    } finally {
      // 断开聊天连接
      ChatWebSocketService.instance.disconnect();
      await authStore.reset();
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _username = '';
          _nickname = '';
          _avatar = '';
          _email = '';
          _userProducts = [];
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_isLoggingIn || !mounted) return;

    setState(() {
      _isLoggingIn = true;
    });

    try {
      // 添加Navigator检查
      if (!Navigator.of(context).mounted) {
        return;
      }

      final success = await AuthUtils.requireLogin(
        context,
        message: 'Login to view your profile and orders',
      );

      if (success && mounted) {
        setState(() {
          _isLoggedIn = true;
          _isLoading = true;
        });
        await _loadUserInfo();
        await _loadUserProducts();
      }
    } catch (e) {
      print('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isLoggedIn) {
      return _buildNotLoggedInUI();
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFFFFF6E6), Color(0xFFFAFAFA)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildUserHeader(),
              const SizedBox(height: 20),
              _buildOverlappingBannerSection(),
              const SizedBox(height: 9),
              _buildTransactionsSection(),
              const SizedBox(height: 12),
              _buildGiftCardBalance(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const ShapeDecoration(shape: OvalBorder()),
                child: ClipOval(
                  child: _avatar.isNotEmpty
                      ? Image.network(
                          _avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF35B13F),
                    shape: OvalBorder(
                      side: BorderSide(width: 1, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nickname.isNotEmpty ? _nickname : _username,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    height: 0.92,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _email.isNotEmpty ? _email : 'No email',
                  style: const TextStyle(
                    color: Color(0xFF8A8A8F),
                    fontSize: 10,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.star, size: 10, color: Color(0xFF8A8A8F)),
                    SizedBox(width: 2),
                    Text(
                      '4.49',
                      style: TextStyle(
                        color: Color(0xFF8A8A8F),
                        fontSize: 10,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(10),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
              child: const Icon(Icons.settings, size: 24, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlappingBannerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 186, // banner高度90 + 重叠部分40
      child: Stack(
        children: [
          // 底层的Banner
          Positioned(top: 0, left: 0, right: 0, child: _buildPromotionBanner()),
          // 上层的QuickAccessButtons，向上偏移20px创建重叠效果
          Positioned(
            top: 70, // 从banner的中间位置开始重叠
            left: 0,
            right: 0,
            child: _buildQuickAccessButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 90,
      decoration: const ShapeDecoration(
        color: Color(0xFFFFA500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Smarter with ReFlip',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Join for exclusive benefits—delivered smarter.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x3FA8A8A8),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickAccessButton(
            icon: Icons.star_outline,
            label: 'Favorites',
            onTap: () {
              Navigator.pushNamed(context, '/my-favorite-products');
            },
          ),
          _buildQuickAccessButton(
            icon: Icons.history,
            label: 'Recently Viewed',
            onTap: () {
              Navigator.pushNamed(context, '/my-browse-history');
            },
          ),
          _buildQuickAccessButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            onTap: () {
              Navigator.pushNamed(context, '/my-wallet');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        shadows: [
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
            'My Transactions',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTransactionButton(
                icon: Icons.post_add_outlined,
                label: 'My Post',
                onTap: () {
                  Navigator.pushNamed(context, '/my-post');
                },
              ),
              _buildTransactionButton(
                icon: Icons.monetization_on_outlined,
                label: 'My Sales',
                onTap: () {
                  Navigator.pushNamed(context, '/my-sales');
                },
              ),
              _buildTransactionButton(
                icon: Icons.shopping_bag_outlined,
                label: 'My Orders',
                onTap: () {
                  Navigator.pushNamed(context, '/my-orders');
                },
              ),
              _buildTransactionButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'My Bill',
                onTap: () {
                  Navigator.pushNamed(context, '/my-bill');
                },
              ),
              _buildTransactionButton(
                icon: Icons.support_agent_outlined,
                label: 'After-Sales',
                onTap: () {
                  _showFeatureUnderDevelopment();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 80,
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftCardBalance() {
    return GestureDetector(
      onTap: _showFeatureUnderDevelopment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x3FA8A8A8),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gift Card Balance',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '\$0.0',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFFFFF6E6), Color(0xFFFAFAFA)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 60, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to ReFlip',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Login to view your profile and manage your items',
                style: TextStyle(
                  color: Color(0xFF8A8A8F),
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _isLoggingIn ? null : _handleLogin,
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: ShapeDecoration(
                    color: _isLoggingIn
                        ? const Color(0xFFCCCCCC)
                        : const Color(0xFFFFA500),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                  ),
                  child: Center(
                    child: _isLoggingIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
