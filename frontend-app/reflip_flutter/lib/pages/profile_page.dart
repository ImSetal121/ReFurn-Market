import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../api/seller_api.dart';
import '../api/visitor_api.dart';
import '../stores/auth_store.dart';
import '../services/chat_websocket_service.dart';
import '../utils/auth_utils.dart';

class ProfilePage extends StatefulWidget {
  // 当 sellerId 不为空时，表示查看卖家个人主页
  final int? sellerId;
  final bool isSellerProfile;

  const ProfilePage({Key? key, this.sellerId, this.isSellerProfile = false})
    : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _username = '';
  String _nickname = '';
  String _avatar = '';
  String _email = '';
  bool _isLoggingIn = false;
  List<Map<String, dynamic>> _userProducts = [];
  bool _isLoadingProducts = false;

  // 卖家信息相关状态
  Map<String, dynamic>? _sellerInfo;
  bool _isLoadingSellerInfo = false;

  @override
  void initState() {
    super.initState();
    if (widget.isSellerProfile && widget.sellerId != null) {
      _loadSellerInfo();
    } else {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoggedIn = authStore.isAuthenticated;
    });

    if (_isLoggedIn) {
      await _loadUserInfo();
      await _loadUserProducts();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await AuthApi.getUserInfo();
      if (userInfo != null && userInfo['user'] != null) {
        setState(() {
          _username = userInfo['user'].username ?? '';
          _nickname = userInfo['user'].nickname ?? _username;
          _avatar = userInfo['user'].avatar ?? '';
          _email = userInfo['user'].email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('加载用户信息失败: $e');
    }
  }

  /// 加载卖家信息
  Future<void> _loadSellerInfo() async {
    if (widget.sellerId == null) return;

    setState(() {
      _isLoadingSellerInfo = true;
      _isLoading = true;
    });

    try {
      final sellerInfo = await VisitorApi.getUserInfo(widget.sellerId!);
      if (sellerInfo != null) {
        setState(() {
          _sellerInfo = sellerInfo;
          _username = sellerInfo['username'] ?? '';
          _nickname = sellerInfo['nickname'] ?? _username;
          _avatar = sellerInfo['avatar'] ?? '';
          _email = sellerInfo['email'] ?? '';
        });
      }
    } catch (e) {
      print('加载卖家信息失败: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载卖家信息失败: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoadingSellerInfo = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserProducts() async {
    if (!authStore.isAuthenticated) return;

    setState(() {
      _isLoadingProducts = true;
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
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await AuthApi.logout();
    } finally {
      // 断开聊天连接
      ChatWebSocketService.instance.disconnect();
      await authStore.reset();
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

  Future<void> _handleLogin() async {
    if (_isLoggingIn) {
      print('ProfilePage: Login already in progress, ignoring');
      return;
    }

    print('ProfilePage: Starting login process');
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final success = await AuthUtils.requireLogin(
        context,
        message: 'Login to view your profile and orders',
      );

      print('ProfilePage: Login result: $success');

      if (success) {
        setState(() {
          _isLoggedIn = true;
          _isLoading = true;
        });
        await _loadUserInfo();
        await _loadUserProducts();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  void _handleOrderAction(String action) {
    if (!AuthUtils.checkLoginWithPrompt(
      context,
      title: 'Login Required',
      message: 'Please login to view order information',
    )) {
      return;
    }
    // 处理订单操作
    print('Handle order action: $action');
  }

  // 未登录状态的UI
  Widget _buildNotLoggedInUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 顶部用户信息区域
                  Container(
                    width: double.infinity,
                    height: 400,
                    child: Stack(
                      children: [
                        // 顶部渐变背景
                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 247,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.50, -0.00),
                                end: Alignment(0.50, 1.00),
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 默认头像和在线状态指示器
                        Positioned(
                          left: 14,
                          top: 68,
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFB2B2B2),
                                      shape: OvalBorder(),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // 在线状态指示器
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF35B13F),
                                        shape: OvalBorder(
                                          side: BorderSide(
                                            width: 1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // 用户信息
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guest User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap to login',
                                    style: TextStyle(
                                      color: const Color(0xFFBCBCBC),
                                      fontSize: 10,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 10,
                                        color: const Color(0xFFBCBCBC),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '--',
                                        style: TextStyle(
                                          color: const Color(0xFFBCBCBC),
                                          fontSize: 10,
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 右上角图标
                        Positioned(
                          right: 14,
                          top: 68,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _showFeatureUnderDevelopment,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: ShapeDecoration(
                                    color: const Color(0x66FFEDCC),
                                    shape: OvalBorder(),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x3F767676),
                                        blurRadius: 1,
                                        offset: Offset(0, 1),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.settings,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _showFeatureUnderDevelopment,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: ShapeDecoration(
                                    color: const Color(0x66FFEDCC),
                                    shape: OvalBorder(),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x3F767676),
                                        blurRadius: 1,
                                        offset: Offset(0, 1),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.headset_mic_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 登录按钮
                        Positioned(
                          left: 50,
                          right: 50,
                          top: 320,
                          child: GestureDetector(
                            onTap: _isLoggingIn ? null : _handleLogin,
                            child: Container(
                              height: 50,
                              decoration: ShapeDecoration(
                                color: _isLoggingIn
                                    ? const Color(0xFFCCCCCC)
                                    : const Color(0xFFFFA500),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 如果是查看卖家个人主页，使用原有样式但显示卖家信息
    if (widget.isSellerProfile) {
      return _buildProfileUI(isSellerProfile: true);
    }

    // 如果未登录，显示未登录UI
    if (!_isLoggedIn) {
      return _buildNotLoggedInUI();
    }

    // 已登录的UI
    return _buildProfileUI(isSellerProfile: false);
  }

  /// 构建个人主页UI（统一样式，根据参数区分是否为卖家页面）
  Widget _buildProfileUI({required bool isSellerProfile}) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Material(
        color: const Color(0xFFFAFAFA),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
          child: Stack(
            children: [
              Column(
                children: [
                  // 主要内容区域
                  Expanded(
                    child: Stack(
                      children: [
                        // 底部白色背景
                        Positioned(
                          left: 0,
                          top: 235,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFAFAFA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        // 顶部背景图片（橙色调室内场景）
                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 247,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/profile_background.jpg',
                                ),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Profile background image not found');
                                },
                              ),
                              // 如果图片加载失败，使用渐变背景
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFD4A574),
                                  Color(0xFFB8956A),
                                  Color(0xFF9A7B5A),
                                ],
                              ),
                            ),
                            child: Container(
                              // 添加半透明遮罩以确保文字可读性
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.5),
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // 返回按钮（仅卖家页面显示）
                                  if (isSellerProfile)
                                    Positioned(
                                      left: 14,
                                      top: 50,
                                      child: SafeArea(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: ShapeDecoration(
                                              color: const Color(0x66000000),
                                              shape: OvalBorder(),
                                            ),
                                            child: const Icon(
                                              Icons.arrow_back_ios,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // 用户信息区域
                                  Positioned(
                                    left: 14,
                                    top: 80,
                                    right: 14,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 左侧用户信息
                                        Expanded(
                                          child: Row(
                                            children: [
                                              // 用户头像和在线状态指示器
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 64,
                                                    height: 64,
                                                    decoration: ShapeDecoration(
                                                      color: Colors.white,
                                                      shape: OvalBorder(),
                                                    ),
                                                    child: ClipOval(
                                                      child: _avatar.isNotEmpty
                                                          ? Image.network(
                                                              _avatar,
                                                              fit: BoxFit.cover,
                                                              width: 64,
                                                              height: 64,
                                                              loadingBuilder:
                                                                  (
                                                                    context,
                                                                    child,
                                                                    loadingProgress,
                                                                  ) {
                                                                    if (loadingProgress ==
                                                                        null)
                                                                      return child;
                                                                    return Container(
                                                                      width: 64,
                                                                      height:
                                                                          64,
                                                                      color: Colors
                                                                          .grey[200],
                                                                      child: const Center(
                                                                        child: CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                              errorBuilder:
                                                                  (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) {
                                                                    print(
                                                                      'Failed to load avatar: $error',
                                                                    );
                                                                    return Container(
                                                                      width: 64,
                                                                      height:
                                                                          64,
                                                                      color: Colors
                                                                          .grey[200],
                                                                      child: const Icon(
                                                                        Icons
                                                                            .person,
                                                                        size:
                                                                            32,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    );
                                                                  },
                                                            )
                                                          : Container(
                                                              width: 64,
                                                              height: 64,
                                                              color: Colors
                                                                  .grey[200],
                                                              child: const Icon(
                                                                Icons.person,
                                                                size: 32,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  // 在线状态指示器
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration:
                                                          ShapeDecoration(
                                                            color: const Color(
                                                              0xFF35B13F,
                                                            ),
                                                            shape: OvalBorder(
                                                              side: BorderSide(
                                                                width: 1,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 12),
                                              // 用户信息
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // 用户名和下拉箭头
                                                    Row(
                                                      children: [
                                                        Text(
                                                          _nickname.isNotEmpty
                                                              ? _nickname
                                                              : _username,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 24,
                                                            fontFamily:
                                                                'SF Pro',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 0),
                                                    Text(
                                                      _email.isNotEmpty
                                                          ? _email
                                                          : 'No email',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFFBCBCBC,
                                                        ),
                                                        fontSize: 12,
                                                        fontFamily: 'SF Pro',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          size: 10,
                                                          color: const Color(
                                                            0xFFBCBCBC,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          '4.49',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFBCBCBC,
                                                            ),
                                                            fontSize: 10,
                                                            fontFamily:
                                                                'SF Pro',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 右上角图标 - 与用户名齐高（仅自己的主页显示）
                                        if (!isSellerProfile)
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/settings',
                                                  );
                                                },
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0x66FFEDCC,
                                                    ),
                                                    shape: OvalBorder(),
                                                    shadows: [
                                                      BoxShadow(
                                                        color: Color(
                                                          0x3F767676,
                                                        ),
                                                        blurRadius: 1,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.settings,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap:
                                                    _showFeatureUnderDevelopment,
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0x66FFEDCC,
                                                    ),
                                                    shape: OvalBorder(),
                                                    shadows: [
                                                      BoxShadow(
                                                        color: Color(
                                                          0x3F767676,
                                                        ),
                                                        blurRadius: 1,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.headset_mic_outlined,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  // 功能按钮行
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 187,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: BouncingScrollPhysics(),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          // Wallet按钮
                                          _buildFunctionButton(
                                            icon: Icons
                                                .account_balance_wallet_outlined,
                                            label: 'Wallet',
                                            hasNotification: true,
                                            onTap: _showFeatureUnderDevelopment,
                                          ),
                                          const SizedBox(width: 12),
                                          // Viewed按钮
                                          _buildFunctionButton(
                                            icon: Icons.visibility_outlined,
                                            label: 'Viewed',
                                            onTap: _showFeatureUnderDevelopment,
                                          ),
                                          const SizedBox(width: 12),
                                          // Reviews按钮
                                          _buildFunctionButton(
                                            icon: Icons.rate_review_outlined,
                                            label: 'Reviews',
                                            onTap: _showFeatureUnderDevelopment,
                                          ),
                                          const SizedBox(width: 12),
                                          // After-Sales按钮
                                          _buildFunctionButton(
                                            icon: Icons.support_agent_outlined,
                                            label: 'After-Sales',
                                            onTap: _showFeatureUnderDevelopment,
                                          ),
                                          const SizedBox(width: 12), // 右侧额外间距
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 白色圆角顶部区域
                        Positioned(
                          left: 0,
                          top: 235,
                          right: 0,
                          child: Container(
                            height: 44,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFFFBF5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x19FFA500),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 标签页导航
                        Positioned(
                          left: 12,
                          top: 245,
                          child: Row(
                            children: [
                              Text(
                                isSellerProfile ? 'Products' : 'My Post',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (!isSellerProfile) ...[
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: _showFeatureUnderDevelopment,
                                  child: Text(
                                    'My Sales',
                                    style: TextStyle(
                                      color: const Color(0xFF8A8A8F),
                                      fontSize: 14,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: _showFeatureUnderDevelopment,
                                  child: Text(
                                    'Interest',
                                    style: TextStyle(
                                      color: const Color(0xFF8A8A8F),
                                      fontSize: 14,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: _showFeatureUnderDevelopment,
                                  child: Text(
                                    'My Orders',
                                    style: TextStyle(
                                      color: const Color(0xFF8A8A8F),
                                      fontSize: 14,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // 选中指示器
                        Positioned(
                          left: 12,
                          top: 273,
                          child: Container(
                            width: isSellerProfile
                                ? 55
                                : 48, // Products vs My Post
                            height: 2,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFFA500),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        // 子标签页
                        Positioned(
                          left: 12,
                          top: 291,
                          right: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isSellerProfile ? 'All Items' : 'For Sale',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (!isSellerProfile) ...[
                                    const SizedBox(width: 24),
                                    GestureDetector(
                                      onTap: _showFeatureUnderDevelopment,
                                      child: Text(
                                        'Draft',
                                        style: TextStyle(
                                          color: const Color(0xFF8A8A8F),
                                          fontSize: 12,
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    GestureDetector(
                                      onTap: _showFeatureUnderDevelopment,
                                      child: Text(
                                        'Unlisted',
                                        style: TextStyle(
                                          color: const Color(0xFF8A8A8F),
                                          fontSize: 12,
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // 右侧菜单图标（仅自己的主页显示）
                              if (!isSellerProfile)
                                GestureDetector(
                                  onTap: _showFeatureUnderDevelopment,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    child: Icon(
                                      Icons.menu,
                                      size: 20,
                                      color: const Color(0xFF8A8A8F),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // 商品网格
                        Positioned(
                          left: 0,
                          top: 324,
                          right: 0,
                          bottom: 0,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              top: 5,
                              left: 16,
                              right: 16,
                              bottom:
                                  16 +
                                  MediaQuery.of(
                                    context,
                                  ).padding.bottom, // 底部导航栏高度 + 系统安全区域
                            ),
                            child: isSellerProfile
                                ? // 卖家页面显示功能开发中提示
                                  const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Seller\'s Products Coming Soon!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'We\'re working on bringing you the ability to\nview seller\'s product listings.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : // 自己的主页显示商品
                                  _isLoadingProducts
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _userProducts.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No products yet',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Start listing your items!',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      runAlignment: WrapAlignment.center,
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: _userProducts
                                          .map(
                                            (product) =>
                                                _buildProductCardFromData(
                                                  product,
                                                ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 底部导航栏（仅自己的主页显示）
              if (!isSellerProfile)
                Positioned(
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 83,
                    child: Stack(
                      children: [
                        // 底部白色背景
                        Positioned(
                          left: 0,
                          top: 49,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white),
                          ),
                        ),
                        // 主导航栏
                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 49,
                            decoration: BoxDecoration(
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
                                GestureDetector(
                                  onTap: _showFeatureUnderDevelopment,
                                  child: Icon(
                                    Icons.apps,
                                    size: 24,
                                    color: const Color(0xFFACB5BB),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _showFeatureUnderDevelopment,
                                  child: Icon(
                                    Icons.favorite_border,
                                    size: 24,
                                    color: const Color(0xFFACB5BB),
                                  ),
                                ),
                                const SizedBox(width: 86), // 为中央按钮留空间
                                GestureDetector(
                                  onTap: _showFeatureUnderDevelopment,
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 24,
                                    color: const Color(0xFFACB5BB),
                                  ),
                                ),
                                Icon(
                                  Icons.person,
                                  size: 24,
                                  color: const Color(0xFFFFA500),
                                ), // 当前页面高亮，不需要点击事件
                              ],
                            ),
                          ),
                        ),
                        // 中央浮动按钮
                        Positioned(
                          left: 0,
                          right: 0,
                          top: -34,
                          child: Center(
                            child: Container(
                              width: 86,
                              height: 86,
                              padding: const EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: _showFeatureUnderDevelopment,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFFFA500),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x4CFFA500),
                                        blurRadius: 17,
                                        offset: Offset(0, 16),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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

  // 构建功能按钮
  Widget _buildFunctionButton({
    required IconData icon,
    required String label,
    bool hasNotification = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: const Color(0x66FFFBF5),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: const Color(0x19FFFBF5)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasNotification) ...[
              const SizedBox(width: 6),
              Container(
                width: 4,
                height: 4,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFFA500),
                  shape: OvalBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    String imageUrl,
    String title,
    String price,
    String cents, {
    String? originalPrice,
  }) {
    return Container(
      width: 160,
      height: 200,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 商品图片
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 160,
              height: 120,
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, 0.00),
                    end: Alignment(0.73, 1.00),
                    colors: [const Color(0xFFFFFAF1), const Color(0xFFF6F6F6)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      print('Product image not found: $imageUrl');
                    },
                  ),
                ),
                // 如果图片加载失败，显示占位符
                child: Center(
                  child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          // 商品标题
          Positioned(
            left: 8,
            top: 122,
            child: Container(
              width: 144,
              height: 32,
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF252525),
                  fontSize: 11,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  height: 1.27,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 价格和统计信息
          Positioned(
            left: 8,
            top: 156,
            child: Container(
              width: 144,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 价格
                  Row(
                    children: [
                      Text(
                        '\$',
                        style: TextStyle(
                          color: const Color(0xFFFFA500),
                          fontSize: 10,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        price.substring(1),
                        style: TextStyle(
                          color: const Color(0xFFFFA500),
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (cents.isNotEmpty)
                        Text(
                          cents,
                          style: TextStyle(
                            color: const Color(0xFFFFA500),
                            fontSize: 6,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  // 原价（如果有）
                  if (originalPrice != null)
                    Text(
                      originalPrice,
                      style: TextStyle(
                        color: const Color(0xFFC7C7CC),
                        fontSize: 6,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  // 统计信息
                  Row(
                    children: [
                      Text(
                        'Views 47',
                        style: TextStyle(
                          color: const Color(0xFF8A8A8F),
                          fontSize: 6,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Saves 12',
                        style: TextStyle(
                          color: const Color(0xFF8A8A8F),
                          fontSize: 6,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 底部按钮
          Positioned(
            left: 6,
            top: 180,
            child: Row(
              children: [
                Icon(Icons.more_horiz, size: 16, color: Colors.grey),
                const SizedBox(width: 11),
                Container(
                  width: 61,
                  height: 15,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEBEBEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                    'Lower Price',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 31,
                  height: 15,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFECECEC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                    'Edit',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 从后端数据构建商品卡片
  Widget _buildProductCardFromData(Map<String, dynamic> product) {
    // 解析图片URL JSON
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

    final String name = product['name'] as String? ?? 'Unknown Product';
    final double price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final String status = product['status'] as String? ?? 'unknown';

    return Container(
      width: 160,
      height: 200,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 商品图片
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 160,
              height: 120,
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, 0.00),
                    end: Alignment(0.73, 1.00),
                    colors: [const Color(0xFFFFFAF1), const Color(0xFFF6F6F6)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 156,
                          height: 116,
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
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),
          ),
          // 商品标题
          Positioned(
            left: 8,
            top: 122,
            child: Container(
              width: 144,
              height: 32,
              child: Text(
                name,
                style: TextStyle(
                  color: const Color(0xFF252525),
                  fontSize: 11,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  height: 1.27,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 价格和状态信息
          Positioned(
            left: 8,
            top: 156,
            child: Container(
              width: 144,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 价格
                  Row(
                    children: [
                      Text(
                        '\$',
                        style: TextStyle(
                          color: const Color(0xFFFFA500),
                          fontSize: 10,
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        price.toStringAsFixed(0),
                        style: TextStyle(
                          color: const Color(0xFFFFA500),
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  // 状态
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部按钮
          Positioned(
            left: 6,
            top: 180,
            child: Row(
              children: [
                Icon(Icons.more_horiz, size: 16, color: Colors.grey),
                const SizedBox(width: 11),
                Container(
                  width: 61,
                  height: 15,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEBEBEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                    'Edit',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'unlisted':
        return Colors.orange;
      case 'sold':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // 获取状态文本
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'unlisted':
        return 'Unlisted';
      case 'sold':
        return 'Sold';
      case 'draft':
        return 'Draft';
      default:
        return 'Unknown';
    }
  }
}
