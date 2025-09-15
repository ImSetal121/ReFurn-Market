import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/user_address.dart';
import '../api/user_address_api.dart';
import '../services/google_maps_service.dart';
import '../widgets/address_picker_widget.dart';
import '../widgets/ios_keyboard_toolbar.dart';

class AddAddressPage extends StatefulWidget {
  final UserAddress? existingAddress; // 传入现有地址用于编辑

  const AddAddressPage({Key? key, this.existingAddress}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  // 表单控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  // 焦点节点
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  // 选中的地址信息
  AddressInfo? _selectedAddressInfo;

  // 表单状态
  bool _isDefault = false;
  bool _isFormValid = false;
  bool _isLoading = false;
  bool _isDeleting = false; // 删除状态

  // 是否为编辑模式
  bool get _isEditMode => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();

    // 如果是编辑模式，填充现有数据
    if (_isEditMode) {
      final address = widget.existingAddress!;
      _nameController.text = address.receiverName ?? '';

      // 处理电话号码：移除+1前缀和其他格式字符
      String phone = address.receiverPhone ?? '';
      phone = phone.replaceFirst('+1', '').trim();
      phone = phone.replaceAll(RegExp(r'^[\s\-\(\)]+'), ''); // 移除开头的空格、短横线、括号
      _phoneController.text = phone;

      _regionController.text = address.region ?? '';
      _isDefault = address.isDefault ?? false;

      // 尝试解析地址信息JSON
      _parseExistingRegion(address.region);
    }

    // 监听输入变化以验证表单
    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _regionController.addListener(_validateForm);

    // 初始验证
    _validateForm();
  }

  // 解析现有地址的region字段，尝试提取AddressInfo
  void _parseExistingRegion(String? region) {
    if (region == null || region.isEmpty) return;

    try {
      // 尝试解析JSON格式的地址信息
      final json = jsonDecode(region);
      if (json is Map<String, dynamic>) {
        _selectedAddressInfo = AddressInfo.fromJson(json);
        // 更新显示的地址文本
        _regionController.text = _selectedAddressInfo!.formattedAddress;
      }
    } catch (e) {
      // 如果不是JSON格式，保持原有的文本
      debugPrint('Region is not JSON format, keeping as text: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Phone validation: at least 5 digits after removing all non-digit characters
      String phoneDigits = _phoneController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      bool isPhoneValid =
          phoneDigits.length >= 5; // Minimum 5 digits, more flexible validation

      _isFormValid =
          _nameController.text.trim().isNotEmpty &&
          isPhoneValid &&
          _regionController.text.trim().isNotEmpty;
    });
  }

  // 打开地址选择器
  Future<void> _openAddressPicker() async {
    // 检查Google Maps是否可用
    final isAvailable = await GoogleMapsService.isAvailable();
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Maps is not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 打开地址选择器
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressPicker(
          initialAddress: _selectedAddressInfo,
          onAddressSelected: (AddressInfo addressInfo) {
            setState(() {
              _selectedAddressInfo = addressInfo;
              _regionController.text = addressInfo.formattedAddress;
            });
            _validateForm();
          },
        ),
      ),
    );
  }

  void _handleBackButton() {
    Navigator.pop(context);
  }

  void _confirmAddress() async {
    if (!_isFormValid || _isLoading || _isDeleting) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Clean phone number format
      String cleanPhone = _phoneController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      String formattedPhone = '+1 $cleanPhone';

      // Build address object with JSON region data
      String regionData;
      if (_selectedAddressInfo != null) {
        // 使用JSON格式存储完整的地址信息
        regionData = _selectedAddressInfo!.toJsonString();
      } else {
        // 如果没有选择地址，使用纯文本
        regionData = _regionController.text.trim();
      }

      final address = UserAddress(
        id: _isEditMode ? widget.existingAddress!.id : null,
        receiverName: _nameController.text.trim(),
        receiverPhone: formattedPhone,
        region: regionData,
        isDefault: _isDefault,
      );

      bool success;
      String message;

      if (_isEditMode) {
        // Update address
        success = await UserAddressApi.updateAddress(address);
        message = success
            ? 'Address updated successfully'
            : 'Failed to update address';
      } else {
        // Add address
        success = await UserAddressApi.addAddress(address);
        message = success
            ? 'Address added successfully'
            : 'Failed to add address';
      }

      if (success) {
        // Set as default address if needed
        if (_isDefault &&
            address.id != null &&
            (!_isEditMode || widget.existingAddress?.isDefault != _isDefault)) {
          await UserAddressApi.setDefaultAddress(address.id!);
        }

        // Return success result
        Navigator.pop(context, {
          'success': true,
          'address': address,
          'isEdit': _isEditMode,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFFFA500),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Save address error: $e');
      print('Error type: ${e.runtimeType}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Operation failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 删除地址
  void _deleteAddress() async {
    if (!_isEditMode || widget.existingAddress?.id == null) return;

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text(
          'Are you sure you want to delete this address? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await UserAddressApi.deleteAddress(
        widget.existingAddress!.id!,
      );

      if (success) {
        // Return success result
        Navigator.pop(context, {
          'success': true,
          'deleted': true,
          'address': widget.existingAddress,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            backgroundColor: Color(0xFFFFA500),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete address'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Delete address error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        // 点击空白处取消焦点，收起键盘
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        // 确保空白区域也能接收到点击事件
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Column(
            children: [
              // 头部
              _buildHeader(),

              // 可滚动内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Address Information 标题
                      const Text(
                        'Address Information',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 输入字段
                      Column(
                        children: [
                          // 全名输入
                          _buildInputField(
                            label: 'Full Name',
                            controller: _nameController,
                            placeholder: 'name',
                            focusNode: _nameFocusNode,
                          ),
                          const SizedBox(height: 32),

                          // 电话号码输入
                          _buildPhoneInputField(),
                          const SizedBox(height: 32),
                        ],
                      ),

                      // 地区输入 - 改为地址选择器
                      _buildAddressPickerField(),
                      const SizedBox(height: 40),

                      // 设为默认地址
                      _buildDefaultAddressOption(),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),

              // 底部确认按钮
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBackButton,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _isEditMode ? 'Edit Address' : 'Add New Address',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 44), // 平衡右侧空间
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    bool hasLocationIcon = false,
    FocusNode? focusNode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 标签
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 输入框区域
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                if (hasLocationIcon) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFFACB5BB),
                    ),
                  ),
                ],
                Expanded(
                  child: KeyboardToolbarBuilder.buildSingle(
                    textField: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: placeholder,
                        hintStyle: const TextStyle(
                          color: Color(0xFFACB5BB),
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.only(
                          left: hasLocationIcon ? 0 : 12,
                          right: 12,
                          top: 0,
                          bottom: 8,
                        ),
                      ),
                    ),
                    focusNode: focusNode!,
                    doneButtonText: 'Done',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressPickerField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 标签
        const SizedBox(
          width: 100,
          child: Text(
            'Region',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 地址选择区域
        Expanded(
          child: GestureDetector(
            onTap: _openAddressPicker,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFFACB5BB),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _regionController.text.isNotEmpty
                          ? _regionController.text
                          : 'Tap to select address',
                      style: TextStyle(
                        color: _regionController.text.isNotEmpty
                            ? Colors.black
                            : const Color(0xFFACB5BB),
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 标签
        const SizedBox(
          width: 100,
          child: Text(
            'Phone Number',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 输入框区域
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                // +1 前缀
                const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Text(
                    '+1',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                // 分隔线
                Container(width: 1, height: 20, color: const Color(0xFFF3F3F3)),
                // 电话号码输入
                Expanded(
                  child: KeyboardToolbarBuilder.buildSingle(
                    textField: TextField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9\-\s\(\)]'),
                        ), // 允许数字、短横线、空格、括号
                        LengthLimitingTextInputFormatter(20), // 增加到20位
                      ],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'phone number',
                        hintStyle: TextStyle(
                          color: Color(0xFFACB5BB),
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    focusNode: _phoneFocusNode,
                    doneButtonText: 'Done',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAddressOption() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDefault = !_isDefault;
        });
      },
      child: Row(
        children: [
          // 复选框
          Container(
            width: 20,
            height: 20,
            decoration: ShapeDecoration(
              color: _isDefault ? const Color(0xFFFFA500) : Colors.transparent,
              shape: _isDefault
                  ? const OvalBorder()
                  : const OvalBorder(
                      side: BorderSide(width: 1, color: Color(0xFF8A8A8F)),
                    ),
            ),
            child: _isDefault
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),

          // 文本
          const Text(
            'Set As Default',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: _isEditMode
          ? Column(
              children: [
                // 删除按钮
                GestureDetector(
                  onTap: _isDeleting ? null : _deleteAddress,
                  child: Container(
                    height: 48,
                    decoration: ShapeDecoration(
                      color: _isDeleting
                          ? const Color(0xFFC7C7CC)
                          : Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _isDeleting
                              ? const Color(0xFFC7C7CC)
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: _isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Delete Address',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 更新按钮
                GestureDetector(
                  onTap: (_isFormValid && !_isLoading && !_isDeleting)
                      ? _confirmAddress
                      : null,
                  child: Container(
                    height: 48,
                    decoration: ShapeDecoration(
                      color: (_isFormValid && !_isLoading && !_isDeleting)
                          ? const Color(0xFFFFA500)
                          : const Color(0xFFC7C7CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            )
          :
            // 添加模式的确认按钮
            GestureDetector(
              onTap: (_isFormValid && !_isLoading) ? _confirmAddress : null,
              child: Container(
                height: 48,
                decoration: ShapeDecoration(
                  color: (_isFormValid && !_isLoading)
                      ? const Color(0xFFFFA500)
                      : const Color(0xFFC7C7CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
    );
  }
}
