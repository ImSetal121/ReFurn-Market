import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/user_address.dart';
import '../api/user_address_api.dart';
import '../api/seller_api.dart';
import '../stores/auth_store.dart';

class ConfirmReturnToSellerPage extends StatefulWidget {
  const ConfirmReturnToSellerPage({Key? key}) : super(key: key);

  @override
  State<ConfirmReturnToSellerPage> createState() =>
      _ConfirmReturnToSellerPageState();
}

class _ConfirmReturnToSellerPageState extends State<ConfirmReturnToSellerPage> {
  // 商品数据
  Map<String, dynamic>? _product;

  // 地址选择相关
  int _selectedAddressIndex = 0;
  List<UserAddress> _addressList = [];
  bool _isLoadingAddresses = false;

  // 提交状态
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAddressList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取路由参数
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _product == null) {
      _product = args['product'] as Map<String, dynamic>?;
    }
  }

  /// 加载用户地址列表
  Future<void> _loadAddressList() async {
    if (!authStore.isAuthenticated) return;

    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final addresses = await UserAddressApi.getUserAddressList();
      setState(() {
        _addressList = addresses;
        // 如果有默认地址，自动选择
        final defaultIndex = addresses.indexWhere(
          (addr) => addr.isDefault == true,
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

  /// 解析地址信息，提取文字地址（仅用于显示）
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

  /// 显示地址选择
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

  /// 添加新地址
  void _addNewAddress() async {
    Navigator.pop(context); // 关闭地址选择弹窗

    // 导航到添加地址页面
    final result = await Navigator.pushNamed(context, '/add-address');

    // 如果返回成功结果，重新加载地址列表
    if (result != null &&
        result is Map<String, dynamic> &&
        result['success'] == true) {
      await _loadAddressList();
    }
  }

  /// 编辑地址
  void _editAddress(UserAddress address) async {
    Navigator.pop(context); // 关闭地址选择弹窗

    // 导航到编辑地址页面
    final result = await Navigator.pushNamed(
      context,
      '/add-address',
      arguments: {'existingAddress': address},
    );

    // 如果返回成功结果，重新加载地址列表
    if (result != null &&
        result is Map<String, dynamic> &&
        result['success'] == true) {
      await _loadAddressList();

      // 如果地址被删除了，显示相应消息
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

  /// 获取商品图片URL
  String _getProductImageUrl() {
    if (_product == null) return 'https://placehold.co/80x80';

    try {
      if (_product!['imageUrlJson'] != null) {
        final imageJson = jsonDecode(_product!['imageUrlJson']);
        if (imageJson is Map) {
          // 按键的数字排序
          final sortedKeys = imageJson.keys.toList()
            ..sort(
              (a, b) =>
                  int.parse(a.toString()).compareTo(int.parse(b.toString())),
            );

          for (String key in sortedKeys) {
            if (imageJson[key] != null &&
                imageJson[key].toString().isNotEmpty) {
              return imageJson[key].toString();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('解析图片URL失败: $e');
    }

    return 'https://placehold.co/80x80';
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
    return 0.0;
  }

  /// 确认退回
  Future<void> _confirmReturn() async {
    if (_isSubmitting) return;

    // 检查是否有选择的地址
    if (_addressList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加收货地址'), backgroundColor: Colors.red),
      );
      _showAddressSelection();
      return;
    }

    // 检查商品信息
    if (_product == null || _product!['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('商品信息不完整，无法处理退回'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 获取选中的地址信息
      final selectedAddress = _addressList[_selectedAddressIndex];

      // 调用退回API
      final success = await SellerApi.requestReturnToSeller(
        productId: _product!['id'].toString(),
        returnAddress: selectedAddress.region ?? '',
      );

      if (success) {
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('退回申请提交成功'),
            backgroundColor: Colors.green,
          ),
        );

        // 返回并刷新商品列表
        Navigator.pop(context, {'success': true});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('退回申请提交失败，请稍后重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('退回申请失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('退回申请失败: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品信息卡片
                    _buildProductCard(),
                    const SizedBox(height: 16),

                    // 退回信息说明
                    _buildReturnInfoCard(),
                    const SizedBox(height: 16),

                    // 地址选择卡片
                    _buildAddressCard(),
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
            'Confirm Return to Seller',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 商品图片
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(_getProductImageUrl()),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProductName(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      '\$',
                      style: TextStyle(
                        color: Color(0xFFFFA500),
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _getProductPrice().toInt().toString(),
                      style: const TextStyle(
                        color: Color(0xFFFFA500),
                        fontSize: 20,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x0A267AFF),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFF267AFF),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'Consignment',
                    style: TextStyle(
                      color: Color(0xFF267AFF),
                      fontSize: 10,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建退回信息说明卡片
  Widget _buildReturnInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: Color(0xFFFFA500),
              ),
              const SizedBox(width: 8),
              const Text(
                'Return Information',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Your consigned product will be returned from the warehouse to your specified address\n'
            '• A logistics task will be created for pickup and delivery\n'
            '• You will be notified when the return process begins\n'
            '• Please ensure the return address is accurate',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建地址选择卡片
  Widget _buildAddressCard() {
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
            'Return Address',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // 地址选择区域
          GestureDetector(
            onTap: _showAddressSelection,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E5E5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 24,
                    color: Color(0xFF666666),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_addressList.isEmpty) ...[
                          const Text(
                            'Please add a return address',
                            style: TextStyle(
                              color: Color(0xFF8A8A8F),
                              fontSize: 14,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ] else ...[
                          Text(
                            _addressList[_selectedAddressIndex].receiverName ??
                                '',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getDisplayAddress(
                              _addressList[_selectedAddressIndex],
                            ),
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF999999),
                  ),
                ],
              ),
            ),
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
        child: GestureDetector(
          onTap: _isSubmitting ? null : _confirmReturn,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: _isSubmitting
                  ? const LinearGradient(
                      colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFA500), Color(0xFFFFB631)],
                    ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirm Return',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建地址选择弹窗
  Widget _buildAddressSelectionSheet(StateSetter setModalState) {
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      decoration: const BoxDecoration(color: Color.fromARGB(0, 0, 0, 0)),
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
                          'Select Return Address',
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

                  // 地址列表
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
                                  // 空列表提示
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

                          // 添加新地址按钮
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
}
