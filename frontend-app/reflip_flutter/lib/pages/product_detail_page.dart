import 'package:flutter/material.dart';
import 'dart:convert';
import '../api/visitor_api.dart';
import '../api/buyer_api.dart';
import '../api/user_api.dart';
import '../widgets/ios_keyboard_toolbar.dart';
import '../routes/app_routes.dart';
import '../stores/auth_store.dart';
import '../utils/auth_utils.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({Key? key}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final PageController _imagePageController = PageController();

  Map<String, dynamic>? _product;
  bool _isLoading = true;
  bool _isLiked = false;
  int _likeCount = 133;
  bool _isFavorited = false;
  bool _isFavoriteLoading = false;
  int? _productId;
  int _currentImageIndex = 0;
  List<String> _imageUrls = [];
  int _browseCount = 0; // 商品浏览数

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 获取路由参数
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _productId == null) {
      _productId = args['productId'] as int?;
      if (_productId != null) {
        _loadProductDetail();
        // 只有在用户已登录时才加载收藏状态
        if (authStore.isAuthenticated) {
          _loadFavoriteStatus();
        }

        // 加载商品浏览数
        _loadProductBrowseCount();

        // 记录浏览历史（如果用户已登录）
        _recordBrowseHistory();
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  /// 加载商品详情
  Future<void> _loadProductDetail() async {
    if (_productId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final product = await VisitorApi.getProductDetail(_productId!);
      if (product != null) {
        setState(() {
          _product = product;
          _imageUrls = _parseImageUrls();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载商品详情失败: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 加载收藏状态
  Future<void> _loadFavoriteStatus() async {
    if (_productId == null) return;

    try {
      final isFavorited = await UserApi.isProductFavorited(_productId!);
      setState(() {
        _isFavorited = isFavorited;
      });
    } catch (e) {
      print('加载收藏状态失败: $e');
      // 不显示错误提示，静默处理
    }
  }

  /// 加载商品浏览数
  Future<void> _loadProductBrowseCount() async {
    if (_productId == null) return;

    try {
      final browseCount = await UserApi.getProductBrowseCount(_productId!);
      setState(() {
        _browseCount = browseCount;
      });
    } catch (e) {
      print('加载商品浏览数失败: $e');
      // 不显示错误提示，静默处理
    }
  }

  /// 记录浏览历史
  Future<void> _recordBrowseHistory() async {
    if (_productId == null) return;

    // 只有在用户已登录时才记录浏览历史
    if (!authStore.isAuthenticated) {
      return;
    }

    try {
      // 异步记录浏览历史，不阻塞UI
      await UserApi.recordBrowseHistory(_productId!);
      print('浏览历史记录成功');
    } catch (e) {
      print('记录浏览历史失败: $e');
      // 静默处理，不影响用户体验
    }
  }

  /// 切换收藏状态
  Future<void> _toggleFavorite() async {
    if (_productId == null || _isFavoriteLoading) return;

    // 首先检查用户是否已登录
    if (!authStore.isAuthenticated) {
      // 用户未登录，跳转到登录门户页面
      final success = await AuthUtils.requireLogin(
        context,
        message: 'Please login to add products to favorites',
      );

      if (!success) {
        // 用户取消登录或登录失败
        return;
      }

      // 登录成功后，加载收藏状态
      await _loadFavoriteStatus();
    }

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      bool success;
      if (_isFavorited) {
        // 取消收藏
        success = await UserApi.removeFavoriteProduct(_productId!);
        if (success) {
          setState(() {
            _isFavorited = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已取消收藏'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.grey,
            ),
          );
        }
      } else {
        // 添加收藏
        success = await UserApi.addFavoriteProduct(_productId!);
        if (success) {
          setState(() {
            _isFavorited = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已添加到收藏'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFFFFA500),
            ),
          );
        }
      }

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorited ? '取消收藏失败' : '收藏失败'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isFavoriteLoading = false;
      });
    }
  }

  /// 解析商品图片URL列表
  List<String> _parseImageUrls() {
    if (_product == null) return ['https://placehold.co/288x202'];

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
      print('解析图片URL失败: $e');
    }

    return ['https://placehold.co/288x202'];
  }

  /// 解析商品图片 (保留兼容性)
  String _getProductImage() {
    if (_imageUrls.isNotEmpty) {
      return _imageUrls[0];
    }
    return 'https://placehold.co/288x202';
  }

  /// 格式化价格
  String _formatPrice() {
    if (_product == null) return '0.00';

    double price = (_product!['price'] ?? 0).toDouble();
    String priceStr = price.toStringAsFixed(2);
    return priceStr;
  }

  /// 切换点赞状态
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  /// 处理Want It按钮点击
  void _handleWantItTap() async {
    if (_product == null || _productId == null) return;

    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFA500)),
      ),
    );

    try {
      // 先检查当前用户是否是商品的拥有者
      final isOwner = await BuyerApi.isProductOwner(_productId!);

      if (isOwner) {
        // 关闭加载指示器
        Navigator.pop(context);
        // 显示无法购买自己商品的提示
        _showCannotBuyOwnProductDialog();
        return;
      }

      // 先检查商品是否已被锁定
      final isLocked = await BuyerApi.checkProductLockStatus(_productId!);

      if (isLocked) {
        // 如果已锁定，检查当前用户是否是锁的拥有者
        // 通过尝试获取剩余时间来判断（只有拥有者能获取到有效时间）
        final remainingTime = await BuyerApi.getLockRemainingTime(_productId!);

        if (remainingTime <= 0) {
          // 不是拥有者或锁已过期，显示商品已被购买的提示
          Navigator.pop(context); // 关闭加载指示器
          _showProductLockedDialog();
          return;
        }

        // 是锁的拥有者，允许进入订单确认页面
        Navigator.pop(context); // 关闭加载指示器
        _navigateToOrderConfirmation();
        return;
      }

      // 商品未被锁定，尝试锁定商品
      final lockSuccess = await BuyerApi.lockProduct(_productId!);

      // 关闭加载指示器
      Navigator.pop(context);

      if (!lockSuccess) {
        // 锁定失败，显示商品已被购买的提示
        _showProductLockedDialog();
        return;
      }

      // 锁定成功，跳转到相应的订单确认页面
      _navigateToOrderConfirmation();
    } catch (e) {
      // 关闭加载指示器
      Navigator.pop(context);

      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('操作失败：${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 跳转到订单确认页面
  void _navigateToOrderConfirmation() {
    // 判断商品是否为寄卖：isAuction为true就是寄卖，否则就是邮寄
    final isAuction = _product!['isAuction'] ?? false;

    if (isAuction) {
      // 跳转到寄卖订单确认页面
      Navigator.pushNamed(
        context,
        AppRoutes.consignmentOrderConfirmation,
        arguments: {'productId': _productId, 'product': _product},
      );
    } else {
      // 跳转到发货订单确认页面
      Navigator.pushNamed(
        context,
        AppRoutes.shippingOrderConfirmation,
        arguments: {'productId': _productId, 'product': _product},
      );
    }
  }

  /// 显示商品已被锁定的对话框
  void _showProductLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFFFA500)),
            SizedBox(width: 12),
            Text(
              'Product Unavailable',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          'Sorry, this product has been purchased by another user or is currently being processed. Please browse other products.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFFFA500),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示无法购买自己商品的对话框
  void _showCannotBuyOwnProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFFFFA500)),
            SizedBox(width: 12),
            Text(
              'Cannot Purchase',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          'You cannot purchase your own product. Please browse other products instead.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFFFA500),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 跳转到卖家个人主页
  void _navigateToSellerProfile() {
    if (_product == null) return;

    // 获取卖家用户ID
    final sellerId = _product!['userId'];
    if (sellerId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.sellerProfile,
        arguments: {
          'sellerId': sellerId,
          'isSellerProfile': true, // 标识这是查看卖家主页
        },
      );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
          ? const Center(child: Text('商品不存在'))
          : Column(
              children: [
                // 顶部导航栏
                _buildAppBar(),

                // 主内容区域
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 商品价格
                        _buildPriceSection(),

                        // 标签和浏览次数
                        _buildTagsAndViews(),

                        // 商品标题
                        _buildProductTitle(),

                        // 商品图片
                        _buildProductImage(),

                        // 商品描述
                        _buildProductDescription(),

                        // 评论区
                        _buildCommentsSection(),

                        // 底部安全区域
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // 底部操作栏
                _buildBottomActionBar(),
              ],
            ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildAppBar() {
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
        child: Container(
          height: 56, // 固定导航栏内容高度
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

              // 卖家头像和昵称（可点击跳转）
              GestureDetector(
                onTap: _navigateToSellerProfile,
                child: Row(
                  children: [
                    // 卖家头像
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFFFEDCC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(36)),
                        ),
                      ),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_getUserAvatar()),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(36),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 卖家昵称
                    Text(
                      _getUserNickname(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 关注按钮
              GestureDetector(
                onTap: () {
                  _showFeatureUnderDevelopment();
                },
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFA500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 分享按钮
              GestureDetector(
                onTap: () {
                  _showFeatureUnderDevelopment();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Icon(Icons.share_outlined, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建价格区域
  Widget _buildPriceSection() {
    final priceStr = _formatPrice();
    final priceParts = priceStr.split('.');

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\$',
            style: TextStyle(
              color: Color(0xFFFFA500),
              fontSize: 16,
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            priceParts[0],
            style: const TextStyle(
              color: Color(0xFFFFA500),
              fontSize: 32,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
          if (priceParts.length > 1 && priceParts[1] != '00')
            Text(
              priceParts[1],
              style: const TextStyle(
                color: Color(0xFFFFA500),
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建标签和浏览次数
  Widget _buildTagsAndViews() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 14, right: 16),
      child: Row(
        children: [
          // 商品类型标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: ShapeDecoration(
              color: const Color(0x0AFCA600),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 0.20, color: Color(0xFFFCA600)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: Text(
              _getProductTypeTag(),
              style: const TextStyle(
                color: Color(0xFFFCA600),
                fontSize: 12,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 自提标签
          if (_product?['isSelfPickup'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: ShapeDecoration(
                color: const Color(0x0A267AFF),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 0.20, color: Color(0xFF267AFF)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: const Text(
                'Self-Pickup',
                style: TextStyle(
                  color: Color(0xFF267AFF),
                  fontSize: 12,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

          const Spacer(),

          // 浏览次数
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Views ',
                style: TextStyle(
                  color: Color(0xFF8A8A8F),
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _browseCount.toString(),
                style: const TextStyle(
                  color: Color(0xFF8A8A8F),
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取商品类型标签
  String _getProductTypeTag() {
    if (_product == null) return 'Unknown';

    final isAuction = _product!['isAuction'] ?? false;
    final isSelfPickup = _product!['isSelfPickup'] ?? false;

    if (isAuction) {
      return 'Auction';
    } else if (isSelfPickup) {
      return 'Direct Sale';
    } else {
      return 'Consignment';
    }
  }

  /// 构建商品标题
  Widget _buildProductTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 14, right: 16),
      child: Text(
        _product?['name'] ?? 'Unknown Product',
        style: const TextStyle(
          color: Color(0xFF252525),
          fontSize: 16,
          fontFamily: 'PingFang SC',
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    );
  }

  /// 构建商品图片
  Widget _buildProductImage() {
    return Container(
      margin: const EdgeInsets.only(left: 18, top: 30, right: 18),
      width: double.infinity,
      height: 240,
      // padding: const EdgeInsets.all(10),
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
      child: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: PageView.builder(
            controller: _imagePageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: _imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                _imageUrls[index],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 288,
                    height: 202,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 48,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// 构建商品描述
  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片指示器（多图片时显示）
        if (_imageUrls.length > 1)
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _imageUrls.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? const Color(0xFFFFA500)
                        : const Color(0xFFC7C7CC),
                  ),
                ),
              ),
            ),
          ),

        // 描述文本
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
          child: Text(
            _product?['description'] ?? 'No description available.',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        // 标签
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 8, right: 16),
          child: Text(
            '#Lorem #faucibus  #facilisis',
            style: TextStyle(
              color: Color(0xFF267AFF),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        // 发布时间
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
          child: Text(
            'Posted on ${_formatCreateTime()}',
            style: const TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 8,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  /// 格式化创建时间
  String _formatCreateTime() {
    if (_product == null || _product!['createTime'] == null) {
      return 'Unknown date';
    }

    try {
      final createTime = DateTime.parse(_product!['createTime']);
      final now = DateTime.now();
      final difference = now.difference(createTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  /// 获取用户头像
  String _getUserAvatar() {
    if (_product?['userInfo'] != null &&
        _product!['userInfo']['avatar'] != null) {
      final avatar = _product!['userInfo']['avatar'].toString();
      if (avatar.isNotEmpty) {
        return avatar;
      }
    }
    return 'https://placehold.co/24x24';
  }

  /// 获取用户昵称
  String _getUserNickname() {
    if (_product?['userInfo'] != null) {
      // 优先使用昵称
      if (_product!['userInfo']['nickname'] != null) {
        final nickname = _product!['userInfo']['nickname'].toString();
        if (nickname.isNotEmpty) {
          return nickname;
        }
      }
      // 其次使用用户名
      if (_product!['userInfo']['username'] != null) {
        final username = _product!['userInfo']['username'].toString();
        if (username.isNotEmpty) {
          return username;
        }
      }
    }
    return 'Unknown User';
  }

  /// 构建评论区域
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, top: 20),
          child: Text(
            'Comment',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        // 功能即将上线提示
        _buildComingSoonMessage(),
      ],
    );
  }

  /// 构建功能即将上线提示
  Widget _buildComingSoonMessage() {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 16),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFF8F9FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'Comments Coming Soon!',
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'re working on bringing you the ability to\ncomment and interact with other users.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 12,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomActionBar() {
    return Container(
      width: double.infinity,
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
      child: SafeArea(
        top: false,
        child: Container(
          height: 56, // 固定底部操作栏内容高度
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 收藏按钮
              GestureDetector(
                onTap: _isFavoriteLoading ? null : _toggleFavorite,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: _isFavoriteLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFA500),
                            ),
                          ),
                        )
                      : Icon(
                          // 如果用户未登录，显示空心图标；已登录则根据收藏状态显示
                          (!authStore.isAuthenticated || !_isFavorited)
                              ? Icons.favorite_border
                              : Icons.favorite,
                          size: 20,
                          color: (authStore.isAuthenticated && _isFavorited)
                              ? const Color(0xFFFFA500)
                              : Colors.black,
                        ),
                ),
              ),

              Text(
                _likeCount.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 16),

              // 评论输入框
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: 8,
                  ),
                  decoration: const ShapeDecoration(
                    color: Color(0x1E787880),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                  ),
                  child: KeyboardToolbarBuilder.buildSingle(
                    textField: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Leave a comment...',
                        hintStyle: TextStyle(
                          color: Color(0x993C3C43),
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                    focusNode: _commentFocusNode,
                    doneButtonText: 'Done',
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Want It 按钮
              GestureDetector(
                onTap: _handleWantItTap,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFA500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Want It',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
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
}
