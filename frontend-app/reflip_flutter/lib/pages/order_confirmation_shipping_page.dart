import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import '../models/user_address.dart';
import '../api/user_address_api.dart';
import '../api/visitor_api.dart';
import '../api/buyer_api.dart';
import '../api/balance_api.dart';
import '../services/stripe_service.dart';

class OrderConfirmationShippingPage extends StatefulWidget {
  const OrderConfirmationShippingPage({Key? key}) : super(key: key);

  @override
  State<OrderConfirmationShippingPage> createState() =>
      _OrderConfirmationShippingPageState();
}

class _OrderConfirmationShippingPageState
    extends State<OrderConfirmationShippingPage> {
  // 商品数据相关
  Map<String, dynamic>? _product;
  int? _productId;
  bool _isLoadingProduct = false;

  // 地址选择相关
  int _selectedAddressIndex = 0; // 默认选择第一个地址
  List<UserAddress> _addressList = []; // 改为UserAddress类型
  bool _isLoadingAddresses = false;

  // 商品锁定倒计时相关
  Timer? _lockTimer;
  int _lockRemainingSeconds = 0;
  bool _isProductLocked = false;
  bool _isLockExpired = false; // 新增：跟踪锁定是否已过期

  // 支付相关
  bool _isProcessingPayment = false;
  double _currentBalance = 0.0;
  bool _isLoadingBalance = false;

  @override
  void initState() {
    super.initState();
    // 加载地址列表
    _loadAddressList();
    // 加载用户余额
    _loadUserBalance();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取路由参数
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _product == null) {
      _productId = args['productId'] as int?;
      _product = args['product'] as Map<String, dynamic>?;

      // 如果没有商品数据但有商品ID，则重新查询
      if (_product == null && _productId != null) {
        _loadProductDetail();
      }

      // 检查商品锁定状态并启动倒计时
      if (_productId != null) {
        _checkLockStatusAndStartCountdown();
      }
    }
  }

  // Load user address list
  Future<void> _loadAddressList() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final addresses = await UserAddressApi.getUserAddressList();
      setState(() {
        _addressList = addresses;
        // If there's a default address, select it automatically
        final defaultIndex = addresses.indexWhere(
          (addr) => addr.isDefaultAddress,
        );
        if (defaultIndex != -1) {
          _selectedAddressIndex = defaultIndex;
        } else if (addresses.isNotEmpty) {
          _selectedAddressIndex = 0;
        }
        _isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAddresses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load address list: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 检查商品锁定状态并启动倒计时
  Future<void> _checkLockStatusAndStartCountdown() async {
    if (_productId == null) return;

    try {
      // 检查商品是否被当前用户锁定
      final remainingTime = await BuyerApi.getLockRemainingTime(_productId!);

      if (remainingTime > 0) {
        // 商品被锁定且未过期，启动倒计时
        _startLockCountdown(remainingTime);
      } else {
        // 商品未被锁定或已过期，显示提示但保留在页面
        setState(() {
          _isProductLocked = false;
          _lockRemainingSeconds = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product lock has expired. Please return to product page to try again.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // 获取锁定状态失败，显示错误但保留在页面
      setState(() {
        _isProductLocked = false;
        _lockRemainingSeconds = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to check lock status: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// 开始锁定倒计时
  void _startLockCountdown(int remainingSeconds) {
    setState(() {
      _lockRemainingSeconds = remainingSeconds;
      _isProductLocked = true;
    });

    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lockRemainingSeconds--;
      });

      if (_lockRemainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          // 设置过期状态
          _isLockExpired = true;
        });
        // 显示锁定过期提示，但保留在当前页面
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product lock has expired. Please return to product page to try again.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    });
  }

  /// 格式化剩余时间
  String _formatRemainingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // 解析地址信息，提取文字地址（仅用于显示）
  String _getDisplayAddress(UserAddress address) {
    final region = address.region;
    if (region == null || region.isEmpty) {
      return '';
    }

    try {
      // 尝试解析JSON格式的地址信息
      final json = jsonDecode(region);
      if (json is Map<String, dynamic> &&
          json.containsKey('formattedAddress')) {
        return json['formattedAddress'] as String;
      }
    } catch (e) {
      // 如果不是JSON格式，直接返回原文本
      debugPrint('Region is not JSON format, using as plain text: $e');
    }

    // 返回原始文本
    return region;
  }

  void _showAddressSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) =>
            _buildAddressSelectionSheet(setModalState),
      ),
    );
  }

  void _addNewAddress() async {
    Navigator.pop(context); // Close address selection popup

    // Navigate to add address page
    final result = await Navigator.pushNamed(context, '/add-address');

    // If successful result returned, reload address list
    if (result != null &&
        result is Map<String, dynamic> &&
        result['success'] == true) {
      await _loadAddressList(); // Reload address list
    }
  }

  // Edit address
  void _editAddress(UserAddress address) async {
    Navigator.pop(context); // Close address selection popup

    // Navigate to edit address page
    final result = await Navigator.pushNamed(
      context,
      '/add-address',
      arguments: {'existingAddress': address},
    );

    // If successful result returned, reload address list
    if (result != null &&
        result is Map<String, dynamic> &&
        result['success'] == true) {
      await _loadAddressList(); // Reload address list

      // If address was deleted, show appropriate message
      if (result['deleted'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            backgroundColor: Color(0xFFFFA500),
          ),
        );
      }
    }
  }

  /// 加载商品详情
  Future<void> _loadProductDetail() async {
    if (_productId == null) return;

    setState(() {
      _isLoadingProduct = true;
    });

    try {
      final product = await VisitorApi.getProductDetail(_productId!);
      if (product != null) {
        setState(() {
          _product = product;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load product details: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isLoadingProduct = false;
      });
    }
  }

  /// 解析商品图片URL列表
  List<String> _parseImageUrls() {
    if (_product == null) return ['https://placehold.co/68x68'];

    try {
      if (_product!['imageUrlJson'] != null) {
        final imageJson = jsonDecode(_product!['imageUrlJson']);
        if (imageJson is Map) {
          List<String> urls = [];
          // 按键的数字排序
          final sortedKeys = imageJson.keys.toList()
            ..sort(
              (a, b) =>
                  int.parse(a.toString()).compareTo(int.parse(b.toString())),
            );

          for (String key in sortedKeys) {
            if (imageJson[key] != null &&
                imageJson[key].toString().isNotEmpty) {
              urls.add(imageJson[key].toString());
            }
          }

          if (urls.isNotEmpty) {
            return urls;
          }
        }
      }
    } catch (e) {
      debugPrint('解析图片URL失败: $e');
    }

    return ['https://placehold.co/68x68'];
  }

  /// 获取商品图片URL
  String _getProductImageUrl() {
    final urls = _parseImageUrls();
    return urls.isNotEmpty ? urls[0] : 'https://placehold.co/68x68';
  }

  /// 获取商品名称
  String _getProductName() {
    return _product?['name'] ?? 'Product Name';
  }

  /// 获取商品价格
  double _getProductPrice() {
    if (_product?['price'] != null) {
      return (_product!['price'] as num).toDouble();
    }
    return 120.0;
  }

  /// 计算预估收益 (扣除10%手续费)
  double _getEstimatedEarnings() {
    final price = _getProductPrice();
    return price * 0.9; // 90%收益，扣除10%手续费
  }

  /// 加载用户余额
  Future<void> _loadUserBalance() async {
    setState(() {
      _isLoadingBalance = true;
    });

    try {
      final balance = await BalanceApi.getCurrentBalance();
      if (mounted) {
        setState(() {
          _currentBalance = balance ?? 0.0;
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      print('加载余额失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    }
  }

  /// 显示支付方式选择
  Future<void> _showPaymentMethodSelection() async {
    if (_isProcessingPayment) return;

    // 检查必要信息
    if (_product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product information is loading, please try again later',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_addressList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a shipping address first'),
          backgroundColor: Colors.red,
        ),
      );
      _showAddressSelection();
      return;
    }

    // 检查锁定状态
    if (_isLockExpired || (!_isProductLocked || _lockRemainingSeconds <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product lock has expired. Please return to product page to try again.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // 显示支付方式选择器
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPaymentMethodSelection(),
    );
  }

  /// 处理余额支付
  Future<void> _handleBalancePayment() async {
    Navigator.pop(context); // 关闭支付方式选择器

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final productPrice = _getProductPrice();
      final productName = _getProductName();

      // 先检查余额购买条件
      final checkResult = await BalanceApi.checkBalancePurchaseEligibility(
        productPrice,
      );

      if (checkResult == null || !checkResult.eligible) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              checkResult?.errorMessage ??
                  'Unable to check balance purchase eligibility',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 执行余额购买
      final purchaseResult = await BalanceApi.purchaseWithBalance(
        productId: _productId!,
        amount: productPrice,
        productName: productName,
      );

      if (purchaseResult != null && purchaseResult.success) {
        // 购买成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              purchaseResult.message ?? 'Purchase completed successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // 跳转到主页
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        // 购买失败，释放锁定
        await BuyerApi.unlockProduct(_productId!);
        setState(() {
          _isProductLocked = false;
          _lockRemainingSeconds = 0;
        });
        _lockTimer?.cancel();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(purchaseResult?.message ?? 'Purchase failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('余额支付失败: $e');

      // 支付异常，释放锁定
      await BuyerApi.unlockProduct(_productId!);
      setState(() {
        _isProductLocked = false;
        _lockRemainingSeconds = 0;
      });
      _lockTimer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  /// 处理直接支付
  Future<void> _handleDirectPayment() async {
    Navigator.pop(context); // 关闭支付方式选择器

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // 使用原有的Stripe支付逻辑
      final success = await StripeService.processPayment(
        productId: _productId ?? 0,
        amount: _getProductPrice(),
        productName: _getProductName(),
        context: context,
      );

      if (success) {
        // 支付成功后的处理
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        // 支付失败，释放锁定
        await BuyerApi.unlockProduct(_productId!);
        setState(() {
          _isProductLocked = false;
          _lockRemainingSeconds = 0;
        });
        _lockTimer?.cancel();
      }
    } catch (e) {
      print('直接支付失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildAppBar(),

            // 主内容区域
            Expanded(
              child: _isLoadingProduct
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFA500),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 商品信息卡片
                          _buildProductCard(),
                          const SizedBox(height: 12),

                          // 地址和电话信息
                          _buildContactInfo(),
                          const SizedBox(height: 12),

                          // 联系卖家
                          _buildContactSeller(),
                          const SizedBox(height: 12),

                          // 订单信息
                          _buildOrderInfo(),
                        ],
                      ),
                    ),
            ),

            // 底部操作栏
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),

          const Spacer(),

          // 标题
          const Text(
            'Order Confirmation',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // 占位，保持标题居中
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// 构建商品信息卡片
  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品信息行
          Row(
            children: [
              // 商品图片
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(_getProductImageUrl()),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 商品标题和价格
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getProductName(),
                      style: const TextStyle(
                        color: Color(0xFF252525),
                        fontSize: 15,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w500,
                        height: 1.27,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_getProductPrice().toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 预估收益
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Earnings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${_getEstimatedEarnings().toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFFFF0000),
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建联系信息
  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 地址信息
          GestureDetector(
            onTap: _showAddressSelection,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Address',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _addressList.isEmpty
                        ? 'Please add address'
                        : _getDisplayAddress(
                            _addressList[_selectedAddressIndex],
                          ),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _addressList.isEmpty
                          ? const Color(0xFF8A8A8F)
                          : const Color(0xFF323232),
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 电话信息
          GestureDetector(
            onTap: _showAddressSelection,
            child: Row(
              children: [
                const Icon(Icons.phone_outlined, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _addressList.isEmpty
                      ? 'Please add phone'
                      : (_addressList[_selectedAddressIndex].receiverPhone ??
                            ''),
                  style: TextStyle(
                    color: _addressList.isEmpty
                        ? const Color(0xFF8A8A8F)
                        : const Color(0xFF323232),
                    fontSize: 12,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 联系卖家
  void _contactSeller() {
    if (_product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('商品信息加载中，请稍后重试'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 获取卖家信息
    final sellerInfo = _product!['userInfo'] as Map<String, dynamic>?;
    final sellerId = _product!['userId'] as int?;

    String sellerName = 'Seller';
    String? sellerAvatar;

    if (sellerInfo != null) {
      sellerName =
          sellerInfo['nickname'] as String? ??
          sellerInfo['username'] as String? ??
          'Seller';
      sellerAvatar = sellerInfo['avatar'] as String?;
    } else if (sellerId != null) {
      sellerName = 'User $sellerId';
    }

    // 跳转到聊天对话页面
    Navigator.pushNamed(
      context,
      '/chat-conversation',
      arguments: {
        'userName': sellerName,
        'userAvatar': sellerAvatar,
        'productId': _productId,
        'productInfo': _product,
      },
    );
  }

  /// 构建联系卖家
  Widget _buildContactSeller() {
    return GestureDetector(
      onTap: _contactSeller,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Text(
              'Contact Seller',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 构建订单信息
  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Information',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Number:',
                style: TextStyle(
                  color: Color(0xFF8A8A8F),
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ORD-20240513140238-123456',
                  style: TextStyle(
                    color: Color(0xFF8A8A8F),
                    fontSize: 12,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 如果商品被锁定，显示倒计时
            if (_isProductLocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x0AFFA500),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFA500), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_clock,
                      size: 16,
                      color: Color(0xFFFFA500),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatRemainingTime(_lockRemainingSeconds),
                      style: const TextStyle(
                        color: Color(0xFFFFA500),
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ] else ...[
              const Spacer(),
            ],

            GestureDetector(
              onTap: _isLockExpired
                  ? () {
                      // 锁定过期时的点击提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Order has expired. Please return to product page to try again.',
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  : _isProcessingPayment
                  ? null
                  : _showPaymentMethodSelection,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  gradient: _isLockExpired || _isProcessingPayment
                      ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)],
                        ) // 禁用状态的灰色渐变
                      : const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFFFA500), Color(0xFFFFB631)],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isProcessingPayment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isLockExpired ? 'Session Expired' : 'Pay Now',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
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

  Widget _buildAddressSelectionSheet(StateSetter setModalState) {
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      decoration: const BoxDecoration(
        color: Color.fromARGB(0, 0, 0, 0), // 半透明遮罩
      ),
      child: Stack(
        children: [
          // 点击遮罩关闭
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),

          // 地址选择容器
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                minHeight: 360,
              ),
              decoration: const ShapeDecoration(
                color: Color(0xFFF7F7F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Address',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Transform.rotate(
                            angle: 0.785398, // 45度
                            child: const Icon(
                              Icons.add,
                              size: 24,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 地址列表 - 可滚动区域
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          // 可滚动的地址列表
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // 加载状态
                                  if (_isLoadingAddresses)
                                    const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFFFA500),
                                      ),
                                    )
                                  // Empty list prompt
                                  else if (_addressList.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        'No addresses yet, please add a new address',
                                        style: TextStyle(
                                          color: Color(0xFF8A8A8F),
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  // 地址选项
                                  else
                                    ..._addressList.asMap().entries.map((
                                      entry,
                                    ) {
                                      int index = entry.key;
                                      UserAddress address = entry.value;
                                      bool isSelected =
                                          index == _selectedAddressIndex;

                                      return GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            _selectedAddressIndex = index;
                                          });
                                          setState(() {
                                            _selectedAddressIndex = index;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 10,
                                          ),
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // 选择圆圈
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: ShapeDecoration(
                                                  color: isSelected
                                                      ? const Color(0xFFFFA500)
                                                      : Colors.transparent,
                                                  shape: isSelected
                                                      ? const OvalBorder()
                                                      : const OvalBorder(
                                                          side: BorderSide(
                                                            width: 1,
                                                            color: Color(
                                                              0xFF8A8A8F,
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 14,
                                                        color: Colors.white,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 20),

                                              // 地址信息
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          address.receiverName ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                                color: Color(
                                                                  0xFF1A1C1E,
                                                                ),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'SF Pro',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Text(
                                                          address.receiverPhone ??
                                                              '',
                                                          style: const TextStyle(
                                                            color: Color(
                                                              0xFF1A1C1E,
                                                            ),
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'DIN Alternate',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _getDisplayAddress(
                                                        address,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF323232,
                                                        ),
                                                        fontSize: 12,
                                                        fontFamily: 'SF Pro',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.33,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // 编辑图标
                                              GestureDetector(
                                                onTap: () =>
                                                    _editAddress(address),
                                                child: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 16,
                                                  color: Color(0xFF8A8A8F),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),

                          // 添加新地址按钮 - 固定在底部
                          Container(
                            padding: const EdgeInsets.only(bottom: 32, top: 12),
                            child: GestureDetector(
                              onTap: _addNewAddress,
                              child: Container(
                                width: double.infinity,
                                height: 48,
                                decoration: ShapeDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFFFFA500),
                                      Color(0xFFFFB631),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add New Address',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
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
        ],
      ),
    );
  }

  /// 构建支付方式选择器
  Widget _buildPaymentMethodSelection() {
    final productPrice = _getProductPrice();
    final hasInsufficientBalance = _currentBalance < productPrice;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(0, 0, 0, 0), // 半透明遮罩
      ),
      child: Stack(
        children: [
          // 点击遮罩关闭
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),

          // 支付方式选择容器
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题和关闭按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 商品信息摘要
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _getProductImageUrl(),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getProductName(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${productPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFFA500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 余额支付选项
                    GestureDetector(
                      onTap: hasInsufficientBalance
                          ? null
                          : _handleBalancePayment,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: hasInsufficientBalance
                              ? Colors.grey[100]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasInsufficientBalance
                                ? Colors.grey[300]!
                                : const Color(0xFFFFA500),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: hasInsufficientBalance
                                  ? Colors.grey
                                  : const Color(0xFFFFA500),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pay with Balance',
                                    style: TextStyle(
                                      color: hasInsufficientBalance
                                          ? Colors.grey
                                          : Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Current Balance: \$${_currentBalance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: hasInsufficientBalance
                                          ? Colors.grey
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (hasInsufficientBalance)
                                    const Text(
                                      'Insufficient balance',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (hasInsufficientBalance)
                              Icon(
                                Icons.block,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 直接支付选项
                    GestureDetector(
                      onTap: _handleDirectPayment,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.credit_card,
                              color: Color(0xFF4CAF50),
                              size: 24,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pay with Card',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Credit/Debit Card via Stripe',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
