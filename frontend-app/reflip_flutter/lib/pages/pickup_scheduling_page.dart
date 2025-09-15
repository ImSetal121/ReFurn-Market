import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/user_address.dart';
import '../api/user_address_api.dart';
import '../api/seller_api.dart';
import '../services/google_maps_service.dart';

// 时间段数据模型
class PickupTimeSlot {
  final String date;
  final String timeSlot;
  final bool isAvailable;

  PickupTimeSlot(this.date, this.timeSlot, this.isAvailable);
}

class PickupSchedulingPage extends StatefulWidget {
  const PickupSchedulingPage({Key? key}) : super(key: key);

  @override
  State<PickupSchedulingPage> createState() => _PickupSchedulingPageState();
}

class _PickupSchedulingPageState extends State<PickupSchedulingPage> {
  // 从上一页传递的数据
  Map<String, dynamic>? productData;
  String? firstImageUrl;
  String? description;
  double? price;

  // 表单数据
  String? selectedPickupTime;
  final TextEditingController _notesController = TextEditingController();

  // 地址选择相关
  int _selectedAddressIndex = 0; // 默认选择第一个地址
  List<UserAddress> _addressList = []; // 改为UserAddress类型
  bool _isLoadingAddresses = false;

  // 时间选择相关
  int _selectedTimeIndex = -1; // 选中的时间段索引，-1表示未选择
  List<PickupTimeSlot> _timeSlots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取路由参数
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      productData = args['productData'] as Map<String, dynamic>?;
      firstImageUrl = args['firstImageUrl'] as String?;
      description = args['description'] as String?;
      price = args['price'] as double?;
    }

    // 加载地址列表
    _loadAddressList();

    // 生成可选时间段
    _generateTimeSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Generate available time slots based on current time
  void _generateTimeSlots() {
    final now = DateTime.now();
    List<PickupTimeSlot> slots = [];

    // Determine the starting time slot index
    // 0 = today morning, 1 = today afternoon, 2 = tomorrow morning, etc.
    int startingSlotIndex = 0;

    // If it's past 5 PM, pickup staff are off work, start from tomorrow morning
    if (now.hour >= 17) {
      startingSlotIndex = 2; // Start from tomorrow morning
    }
    // If it's past 9 AM but before 5 PM, skip today morning
    else if (now.hour >= 9) {
      startingSlotIndex = 1; // Start from today afternoon
    }
    // Otherwise start from today morning

    // Generate 6 time slots starting from the determined index
    for (int i = 0; i < 6; i++) {
      int currentSlotIndex = startingSlotIndex + i;

      // Calculate which day and time slot
      int dayOffset =
          currentSlotIndex ~/ 2; // Each day has 2 slots (morning + afternoon)
      bool isMorning =
          currentSlotIndex % 2 == 0; // Even index = morning, odd = afternoon

      DateTime slotDate = now.add(Duration(days: dayOffset));
      String timeSlot = isMorning ? 'Morning' : 'Afternoon';
      String formattedDate = _formatDate(slotDate);

      // All slots are available now
      bool isAvailable = true;

      slots.add(PickupTimeSlot(formattedDate, timeSlot, isAvailable));
    }

    setState(() {
      _timeSlots = slots;
    });

    // Debug: Print generated time slots
    print('Generated time slots (current time: ${now.hour}:${now.minute}):');
    for (int i = 0; i < slots.length; i++) {
      print(
        '  ${i}: ${slots[i].date} ${slots[i].timeSlot} (available: ${slots[i].isAvailable})',
      );
    }
  }

  // Format date to display string
  String _formatDate(DateTime date) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    String month = months[date.month - 1];
    String day = date.day.toString().padLeft(2, '0');
    String year = date.year.toString();

    return '$month $day, $year';
  }

  // Convert display date format (e.g., "June 06, 2025") to ISO format (e.g., "2025-06-06")
  String _convertDisplayDateToISO(String displayDate) {
    try {
      List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      // Parse "June 06, 2025" format
      final parts = displayDate.split(' ');
      if (parts.length == 3) {
        String monthName = parts[0];
        String day = parts[1].replaceAll(',', '');
        String year = parts[2];

        int monthIndex = months.indexOf(monthName);
        if (monthIndex != -1) {
          int month = monthIndex + 1;
          return '$year-${month.toString().padLeft(2, '0')}-${day.padLeft(2, '0')}';
        }
      }
    } catch (e) {
      print('Error converting display date to ISO: $e');
    }

    // Fallback: return original string if parsing fails
    return displayDate;
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
      print('Failed to load address list: $e');
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

  void _handleBackButton() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _selectPickupTime() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) =>
            _buildTimeSelectionSheet(setModalState),
      ),
    );
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

  void _contactSupport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContactSupportSheet(),
    );
  }

  void _confirmScheduling() async {
    if (selectedPickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup time')),
      );
      return;
    }

    if (_addressList.isEmpty || _selectedAddressIndex < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup address')),
      );
      return;
    }

    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text(
          'Are you sure you want to submit your pickup appointment and list your item for consignment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFA500),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    // If user didn't confirm, return
    if (confirmed != true) return;

    // Print all product information to console
    _printProductInformation();

    // Prepare consignment data
    Map<String, dynamic> consignmentData = _prepareConsignmentData();

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFFFFA500)),
              SizedBox(width: 20),
              Text('Submitting...'),
            ],
          ),
        ),
      );

      // Submit to backend
      final result = await SellerApi.consignmentListing(consignmentData);

      // Close loading dialog
      Navigator.of(context).pop();

      if (result != null) {
        // Success - Navigate to success page
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/listing-success',
          (route) => false,
        );
      } else {
        // Failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit pickup appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _printProductInformation() {
    print('=== PRODUCT INFORMATION ===');

    // RfProduct fields
    print('--- RfProduct ---');
    print('id: ${productData?['id'] ?? 'null'}');
    print('name: ${productData?['name'] ?? 'null'}');
    print('categoryId: ${productData?['categoryId'] ?? 'null'}');
    print('type: ${productData?['type'] ?? 'null'}');
    print('category: ${productData?['category'] ?? 'null'}');
    print('price: ${price ?? 'null'}');
    print('stock: ${productData?['stock'] ?? 'null'}');
    print('description: ${description ?? 'null'}');
    print('imageUrlJson: ${productData?['imageUrlJson'] ?? 'null'}');

    // Additional image information
    print('--- Image Details ---');
    if (productData?['imageUrlJson'] != null) {
      try {
        final imageMap = jsonDecode(productData!['imageUrlJson']);
        print('Cover image (key "1"): ${imageMap['1'] ?? 'null'}');
        print('Total images: ${imageMap.length}');
        imageMap.forEach((key, value) {
          print('Image $key: $value');
        });
      } catch (e) {
        print('Error parsing imageUrlJson: $e');
      }
    }
    print('firstImageUrl (for display): ${firstImageUrl ?? 'null'}');

    // Since user entered pickup scheduling page, they chose consignment service
    print('isAuction: true'); // User chose consignment service

    // Get pickup address for RfProduct.address field
    String pickupAddress = 'null';
    if (_addressList.isNotEmpty && _selectedAddressIndex >= 0) {
      pickupAddress = _getFullAddressData(_addressList[_selectedAddressIndex]);
    }
    print('address: $pickupAddress'); // This should be the pickup address
    print(
      'isSelfPickup: false',
    ); // User chose consignment service, not self pickup
    print('status: ${productData?['status'] ?? 'null'}');
    print('createTime: ${productData?['createTime'] ?? 'null'}');
    print('updateTime: ${productData?['updateTime'] ?? 'null'}');
    print('isDelete: ${productData?['isDelete'] ?? 'null'}');

    // RfProductAuctionLogistics fields
    print('--- RfProductAuctionLogistics ---');
    print('id: null'); // Will be generated by backend
    print('productId: ${productData?['id'] ?? 'null'}');
    print('productSellRecordId: null'); // Not available in current context
    print(
      'pickupAddress: ${_addressList.isNotEmpty && _selectedAddressIndex >= 0 ? _getFullAddressData(_addressList[_selectedAddressIndex]) : 'null'}',
    );
    print('warehouseId: null'); // Will be assigned by backend
    print('warehouseAddress: null'); // Will be assigned by backend
    print('isUseLogisticsService: true'); // Assuming logistics service is used

    // Parse selected pickup time
    String? appointmentDate;
    String? appointmentTimePeriod;
    if (selectedPickupTime != null) {
      final parts = selectedPickupTime!.split(' - ');
      if (parts.length == 2) {
        // Convert display date format to ISO format (yyyy-MM-dd)
        appointmentDate = _convertDisplayDateToISO(parts[0]);
        appointmentTimePeriod = parts[1];
      }
    }
    print('appointmentPickupDate: ${appointmentDate ?? 'null'}');
    print('appointmentPickupTimePeriod: ${appointmentTimePeriod ?? 'null'}');

    print('internalLogisticsTaskId: null'); // Will be generated by backend
    print('externalLogisticsServiceName: null'); // Not using external service
    print('externalLogisticsOrderNumber: null'); // Not using external service
    print('status: PENDING'); // Initial status
    print('createTime: ${DateTime.now().toString()}');
    print('updateTime: ${DateTime.now().toString()}');
    print('isDelete: false');

    // Additional information
    print('--- Additional Information ---');
    print('selectedAddressIndex: $_selectedAddressIndex');
    if (_addressList.isNotEmpty && _selectedAddressIndex >= 0) {
      final selectedAddress = _addressList[_selectedAddressIndex];
      print('receiverName: ${selectedAddress.receiverName}');
      print('receiverPhone: ${selectedAddress.receiverPhone}');
      print('fullAddress: ${_getFullAddressData(selectedAddress)}');
      print('isDefaultAddress: ${selectedAddress.isDefaultAddress}');
    }
    print(
      'notes: ${_notesController.text.isEmpty ? 'null' : _notesController.text}',
    );
    print('estimatedEarnings: ${_calculateEstimatedEarnings()}');

    print('=== END PRODUCT INFORMATION ===');
  }

  // 计算预估收入
  double _calculateEstimatedEarnings() {
    if (price == null) return 0.0;
    // 扣除5%服务费、3%税费和$5包装费
    double serviceFee = price! * 0.05;
    double tax = price! * 0.03;
    double packagingFee = 5.0;
    return price! - serviceFee - tax - packagingFee;
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

  // 获取完整地址信息（用于后端传输，保持JSON格式）
  String _getFullAddressData(UserAddress address) {
    return address.region ?? '';
  }

  // 准备寄卖数据
  Map<String, dynamic> _prepareConsignmentData() {
    final selectedAddress = _addressList[_selectedAddressIndex];

    // Parse selected pickup time
    String? appointmentDate;
    String? appointmentTimePeriod;
    if (selectedPickupTime != null) {
      final parts = selectedPickupTime!.split(' - ');
      if (parts.length == 2) {
        // Convert display date format to ISO format (yyyy-MM-dd)
        appointmentDate = _convertDisplayDateToISO(parts[0]);
        appointmentTimePeriod = parts[1];
      }
    }

    return {
      // Product basic information
      'name': productData?['name'] ?? '',
      'categoryId': productData?['categoryId'],
      'type': productData?['type'] ?? '',
      'category': productData?['category'] ?? '',
      'price': price ?? 0.0,
      'stock': productData?['stock'] ?? 1,
      'description': description ?? '',
      'imageUrlJson': productData?['imageUrlJson'] ?? '',

      // Pickup address (for product.address field) - 使用完整JSON数据
      'address': _getFullAddressData(selectedAddress),

      // Logistics information - 使用完整JSON数据
      'pickupAddress': _getFullAddressData(selectedAddress),
      'appointmentPickupDate': appointmentDate,
      'appointmentPickupTimePeriod': appointmentTimePeriod,
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),

      // Contact information
      'receiverName': selectedAddress.receiverName,
      'receiverPhone': selectedAddress.receiverPhone,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // 点击空白处取消焦点，收起键盘
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        // 确保空白区域也能接收到点击事件
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.50, 0.00),
              end: Alignment(0.50, 1.00),
              colors: [Color(0xFFDFF9FF), Color(0xFFFFF6E5), Colors.white],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 头部
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // 商品信息区域
                    _buildProductInfo(),
                    const SizedBox(height: 20),

                    // 预约取货时间区域
                    _buildScheduleSection(),
                    const SizedBox(height: 10),

                    // 联系客服
                    _buildContactSupport(),
                    const SizedBox(height: 20),

                    // 订单信息
                    _buildOrderInfo(),
                    const SizedBox(height: 36),

                    // 确认按钮
                    _buildConfirmButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: _handleBackButton,
          child: Container(
            width: 24,
            height: 24,
            child: const Icon(
              Icons.arrow_back_ios,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 26),
        const Text(
          'Pending Scheduling',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
            color: Color(0xCCEAEAEA),
            blurRadius: 4,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
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
                decoration: ShapeDecoration(
                  color: const Color(0xFFE5E5E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: firstImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          firstImageUrl!,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image,
                              size: 34,
                              color: Color(0xFF999999),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 34,
                        color: Color(0xFF999999),
                      ),
              ),
              const SizedBox(width: 12),
              // 商品描述和价格
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description ?? '商品描述',
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
                      '\$${price?.toStringAsFixed(0) ?? '0'}',
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

          // 预估收入
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
                '\$${_calculateEstimatedEarnings().toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFFFF0000),
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 地址信息
          _buildAddressInfo(),
          const SizedBox(height: 16),

          // 电话信息
          _buildPhoneInfo(),
        ],
      ),
    );
  }

  Widget _buildAddressInfo() {
    if (_addressList.isEmpty) {
      return GestureDetector(
        onTap: _showAddressSelection,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 18),
            const Text(
              'Address',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Expanded(
              flex: 2,
              child: Text(
                'Please add address',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xFF8A8A8F),
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
              size: 12,
              color: Color(0xFF999999),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showAddressSelection,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            child: const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 18),
          const Text(
            'Address',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              _getDisplayAddress(_addressList[_selectedAddressIndex]),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF323232),
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
            size: 12,
            color: Color(0xFF999999),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInfo() {
    if (_addressList.isEmpty) {
      return GestureDetector(
        onTap: _showAddressSelection,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.phone_outlined,
                size: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 18),
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
            const Text(
              'Please add phone',
              style: TextStyle(
                color: Color(0xFF8A8A8F),
                fontSize: 12,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Color(0xFF999999),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showAddressSelection,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            child: const Icon(
              Icons.phone_outlined,
              size: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 18),
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
            _addressList[_selectedAddressIndex].receiverPhone ?? '',
            style: const TextStyle(
              color: Color(0xFF323232),
              fontSize: 12,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Color(0xFF999999),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
            color: Color(0xCCEAEAEA),
            blurRadius: 4,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Schedule Pickup Time',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFA500),
                fontSize: 18,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 取货时间选择
          GestureDetector(
            onTap: _selectPickupTime,
            child: Container(
              width: double.infinity,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pickup Time',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedPickupTime != null)
                        Text(
                          selectedPickupTime!,
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Color(0xFF999999),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 备注区域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 0,
              bottom: 0,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: _notesController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Please enter pickup notes...',
                      hintStyle: TextStyle(
                        color: Color(0xFFABABAB),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
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

  Widget _buildContactSupport() {
    return GestureDetector(
      onTap: _contactSupport,
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadows: const [
            BoxShadow(
              color: Color(0xCCEAEAEA),
              blurRadius: 4,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
            color: Color(0xCCEAEAEA),
            blurRadius: 4,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
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
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pickup Tracking Number:',
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
                  'PU-20240513140238-123456',
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

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: _confirmScheduling,
        child: Container(
          height: 48,
          decoration: ShapeDecoration(
            color: selectedPickupTime != null
                ? const Color(0xFFFFA500)
                : const Color(0xFFC7C7CC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Center(
            child: Text(
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

  Widget _buildContactSupportSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      decoration: const BoxDecoration(
        color: Color.fromARGB(0, 4, 4, 4), // Semi-transparent overlay
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

          // Contact Support Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 332,
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
                  // Header
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Contact Support',
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
                            angle: 0.785398, // 45 degrees
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

                  // Contact Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        // Chat with Us
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _openChat();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            padding: const EdgeInsets.only(left: 22, right: 10),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0xCCEAEAEA),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Chat with Us',
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
                        ),

                        const SizedBox(height: 8),

                        // Contact by Phone
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _contactByPhone();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            padding: const EdgeInsets.only(left: 22, right: 10),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0xCCEAEAEA),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Contact by Phone',
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

  void _openChat() {
    // TODO: Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat feature will be available soon'),
        backgroundColor: Color(0xFFFFA500),
      ),
    );
  }

  void _contactByPhone() {
    // TODO: Implement phone contact functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact by Phone'),
        content: const Text(
          'Support Phone: +1 (555) 123-4567\n\nBusiness Hours:\nMonday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectionSheet(StateSetter setModalState) {
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      decoration: const BoxDecoration(
        color: Color.fromARGB(0, 4, 4, 4), // Semi-transparent overlay
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

          // Time Selection Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 332,
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
                  // Header
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Pickup Time',
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
                            angle: 0.785398, // 45 degrees
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

                  // Time Slots List
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          // 可滚动的时间段列表
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: _timeSlots.asMap().entries.map((
                                  entry,
                                ) {
                                  int index = entry.key;
                                  PickupTimeSlot timeSlot = entry.value;
                                  bool isSelected = index == _selectedTimeIndex;

                                  return GestureDetector(
                                    onTap: timeSlot.isAvailable
                                        ? () {
                                            setModalState(() {
                                              _selectedTimeIndex = index;
                                            });
                                          }
                                        : null,
                                    child: Container(
                                      width: double.infinity,
                                      height: 36,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.only(
                                        left: 22,
                                        right: 10,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: timeSlot.isAvailable
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        shadows: timeSlot.isAvailable
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0xCCEAEAEA),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 0,
                                                ),
                                              ]
                                            : null,
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
                                                  : OvalBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color:
                                                            timeSlot.isAvailable
                                                            ? const Color(
                                                                0xFF8A8A8F,
                                                              )
                                                            : const Color(
                                                                0x998A8A8F,
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
                                          const SizedBox(width: 21),

                                          // 日期
                                          Text(
                                            timeSlot.date,
                                            style: TextStyle(
                                              color: timeSlot.isAvailable
                                                  ? const Color(0xFF737373)
                                                  : const Color(0x99737373),
                                              fontSize: 16,
                                              fontFamily: 'SF Pro',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),

                                          const Spacer(),

                                          // 时间段
                                          Text(
                                            timeSlot.timeSlot,
                                            style: TextStyle(
                                              color: timeSlot.isAvailable
                                                  ? const Color(0xFFFFA500)
                                                  : const Color(0x99FFA500),
                                              fontSize: 15,
                                              fontFamily: 'SF Pro',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          // Confirm Button - 固定在底部
                          Container(
                            padding: const EdgeInsets.only(bottom: 36, top: 12),
                            child: GestureDetector(
                              onTap: _selectedTimeIndex != -1
                                  ? () {
                                      setState(() {
                                        selectedPickupTime =
                                            '${_timeSlots[_selectedTimeIndex].date} - ${_timeSlots[_selectedTimeIndex].timeSlot}';
                                      });
                                      Navigator.pop(context);
                                      // Reset selection for next time
                                      _selectedTimeIndex = -1;
                                    }
                                  : null,
                              child: Container(
                                width: double.infinity,
                                height: 48,
                                decoration: ShapeDecoration(
                                  color: _selectedTimeIndex != -1
                                      ? const Color(0xFFFFA500)
                                      : const Color(0xFFC7C7CC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
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
