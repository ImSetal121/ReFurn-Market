import 'package:flutter/material.dart';
import 'dart:convert';
import '../api/buyer_api.dart';
import '../api/user_address_api.dart';
import '../models/user_address.dart';
import '../widgets/ios_keyboard_toolbar.dart';

class RefundApplicationPage extends StatefulWidget {
  final String orderId;

  const RefundApplicationPage({Key? key, required this.orderId})
    : super(key: key);

  @override
  State<RefundApplicationPage> createState() => _RefundApplicationPageState();
}

class _RefundApplicationPageState extends State<RefundApplicationPage> {
  final TextEditingController _detailController = TextEditingController();
  final FocusNode _detailFocusNode = FocusNode();
  String? _selectedReason;
  bool _isSubmitting = false;

  // 地址选择相关
  int _selectedAddressIndex = 0;
  List<UserAddress> _addressList = [];
  bool _isLoadingAddresses = false;

  // 退货原因选项
  final List<Map<String, String>> _refundReasons = [
    {
      'value': 'DAMAGED',
      'label': 'Product Damaged',
      'description': 'Item received is damaged or broken',
    },
    {
      'value': 'NOT_AS_DESCRIBED',
      'label': 'Not as Described',
      'description': 'Item doesn\'t match the description',
    },
    {
      'value': 'WRONG_SIZE',
      'label': 'Wrong Size',
      'description': 'Size doesn\'t fit as expected',
    },
    {
      'value': 'CHANGED_MIND',
      'label': 'Changed Mind',
      'description': 'No longer need this item',
    },
    {
      'value': 'QUALITY_ISSUE',
      'label': 'Quality Issue',
      'description': 'Poor quality or manufacturing defect',
    },
    {
      'value': 'LATE_DELIVERY',
      'label': 'Late Delivery',
      'description': 'Item arrived too late',
    },
    {
      'value': 'OTHER',
      'label': 'Other',
      'description': 'Other reasons not listed above',
    },
  ];

  @override
  void initState() {
    super.initState();
    // 加载地址列表
    _loadAddressList();
  }

  @override
  void dispose() {
    _detailController.dispose();
    _detailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderInfo(),
                    const SizedBox(height: 24),
                    _buildReasonSelection(),
                    const SizedBox(height: 24),
                    _buildPickupAddressSelection(),
                    const SizedBox(height: 24),
                    _buildDetailInput(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Apply for Refund',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Information',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order ID: ${widget.orderId}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Refund Reason',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please select why you want to return this item',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        ..._refundReasons.map((reason) => _buildReasonOption(reason)),
      ],
    );
  }

  Widget _buildReasonOption(Map<String, String> reason) {
    final isSelected = _selectedReason == reason['value'];

    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason['value']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFFFA500) : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFFFA500) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason['label']!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'SF Pro',
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason['description']!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please provide more details about your refund request (optional)',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 140),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: KeyboardToolbarBuilder.buildSingle(
            textField: TextField(
              controller: _detailController,
              focusNode: _detailFocusNode,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Describe the issue in detail...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
            focusNode: _detailFocusNode,
            doneButtonText: 'Done',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedReason != null && !_isSubmitting
            ? _submitRefundApplication
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA500),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit Refund Request',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitRefundApplication() async {
    if (_selectedReason == null) return;

    // 检查是否选择了取货地址
    if (_addressList.isEmpty) {
      _showErrorDialog('Please add a pickup address first.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 获取选中的地址信息
      final selectedAddress = _addressList[_selectedAddressIndex];
      final success = await BuyerApi.applyRefund(
        orderId: widget.orderId,
        reason: _selectedReason!,
        description: _detailController.text.trim(),
        pickupAddress: selectedAddress.region, // 传递地址JSON信息
      );

      if (success) {
        // 显示成功提示
        _showSuccessDialog();
      } else {
        _showErrorDialog('Failed to submit refund request. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text(
            'Your refund request has been submitted successfully. We will review your request and get back to you within 24 hours.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                Navigator.of(context).pop(); // 返回到订单页面
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 加载地址列表
  Future<void> _loadAddressList() async {
    setState(() => _isLoadingAddresses = true);
    try {
      final addresses = await UserAddressApi.getUserAddressList();
      setState(() {
        _addressList = addresses;
        // 如果有默认地址，自动选择
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
      setState(() => _isLoadingAddresses = false);
      _showErrorDialog('Failed to load address list: ${e.toString()}');
    }
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

  // 显示地址选择弹窗
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

  // 添加新地址
  void _addNewAddress() async {
    Navigator.pop(context); // 关闭地址选择弹窗

    // 跳转到添加地址页面
    final result = await Navigator.pushNamed(context, '/add-address');

    // 如果成功返回结果，重新加载地址列表
    if (result != null &&
        result is Map<String, dynamic> &&
        result['success'] == true) {
      await _loadAddressList();
    }
  }

  // 编辑地址
  void _editAddress(UserAddress address) async {
    Navigator.pop(context); // 关闭地址选择弹窗

    // 跳转到编辑地址页面
    final result = await Navigator.pushNamed(
      context,
      '/add-address',
      arguments: {'existingAddress': address},
    );

    // 如果成功返回结果，重新加载地址列表
    if (result != null &&
        result is Map<String, dynamic> &&
        result['success'] == true) {
      await _loadAddressList();

      // 如果地址被删除，显示相应提示
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

  Widget _buildPickupAddressSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pickup Address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please select the address where we can pick up the item',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showAddressSelection,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isLoadingAddresses)
                        const Text(
                          'Loading addresses...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      else if (_addressList.isEmpty)
                        const Text(
                          'Please add address',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      else ...[
                        Text(
                          _addressList[_selectedAddressIndex].receiverName ??
                              '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
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
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
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
        ),
      ],
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
                          'Select Pickup Address',
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
}
