import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import '../api/upload_api.dart';
import '../api/seller_api.dart';
import '../models/uploaded_image.dart';
import '../widgets/ios_keyboard_toolbar.dart';

class ListItemDetailsPage extends StatefulWidget {
  const ListItemDetailsPage({Key? key}) : super(key: key);

  @override
  State<ListItemDetailsPage> createState() => _ListItemDetailsPageState();
}

class _ListItemDetailsPageState extends State<ListItemDetailsPage> {
  // 从上一页传递过来的参数
  String? selectedType;
  String? selectedCategory;

  // 表单数据
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // 焦点节点
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  List<UploadedImage> _selectedImages = [];
  String? _deliveryMethod;
  bool _agreeToTerms = false;

  // 定价相关
  double? _selectedPrice;
  double _suggestedPrice = 108.0;
  double _tipAmount = 5.0;

  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取路由参数
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedType = args['type'] as String?;
      selectedCategory = args['category'] as String?;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  void _handleCloseButton() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _onSend() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请同意卖家承诺协议')));
      return;
    }

    // 检查是否还有正在上传的图片
    if (_selectedImages.any((img) => img.isUploading)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请等待图片上传完成')));
      return;
    }

    // 构建图片URL的JSON格式
    final successfulImages = _selectedImages
        .where((img) => img.isSuccess)
        .map((img) => img.fileUrl)
        .toList();

    Map<String, String> imageUrlMap = {};
    for (int i = 0; i < successfulImages.length; i++) {
      imageUrlMap[(i + 1).toString()] = successfulImages[i]!;
    }

    final productData = {
      'name': _descriptionController.text, // 使用描述作为商品名称
      'categoryId': null, // TODO: 需要从类别名称获取categoryId
      'type': selectedType,
      'category': selectedCategory,
      'price': _selectedPrice ?? 0.0,
      'stock': 1, // 默认库存为1
      'description': _descriptionController.text,
      'imageUrlJson': jsonEncode(imageUrlMap), // 转换为JSON字符串
      'isAuction': false, // 默认不是拍卖
      'address': '', // TODO: 获取用户地址
      'isSelfPickup': _deliveryMethod == 'no_consignment', // no_consignment表示自提
    };

    print('准备发送商品数据: $productData');

    // 根据配送方式选择跳转
    if (_deliveryMethod == 'consignment') {
      // 选择代售服务，跳转到预约取货页面
      Navigator.pushNamed(
        context,
        '/pickup-scheduling',
        arguments: {
          'productData': productData,
          'firstImageUrl': imageUrlMap['1'],
          'description': _descriptionController.text,
          'price': _selectedPrice,
        },
      );
    } else {
      // 选择自提，调用自提上架API
      _handleSelfPickupListing(productData);
    }
  }

  /// 处理自提商品上架
  Future<void> _handleSelfPickupListing(
    Map<String, dynamic> productData,
  ) async {
    try {
      // 显示加载提示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 调用自提上架API
      final result = await SellerApi.selfPickupListing(productData);

      // 关闭加载提示
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (result != null) {
        // 上架成功，跳转到成功页面
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/listing-success',
          (route) => false,
        );
      } else {
        // 上架失败，显示错误提示
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('商品上架失败，请重试')));
      }
    } catch (e) {
      // 关闭加载提示
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 显示错误提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('上架失败: ${e.toString()}')));
    }
  }

  /// 上传图片到S3
  Future<void> _uploadImage(UploadedImage uploadedImage) async {
    try {
      print('===== 开始上传图片 =====');
      // 更新状态为正在上传
      final index = _selectedImages.indexOf(uploadedImage);
      if (index == -1) {
        print('找不到要上传的图片索引');
        return;
      }

      setState(() {
        _selectedImages[index] = uploadedImage.copyWith(
          status: UploadStatus.uploading,
          progress: 0.0,
        );
      });

      // 确定文件类型
      String contentType = 'image/jpeg';
      final fileName = uploadedImage.fileName ?? 'image.jpg';
      print('上传图片文件名: $fileName');

      if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.gif')) {
        contentType = 'image/gif';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        contentType = 'image/webp';
      }
      print('确定的内容类型: $contentType');

      // 尝试修复iOS相机图片色彩问题 - 检查是否是iOS平台
      if (Platform.isIOS) {
        try {
          print('检测到iOS平台，图片路径: ${uploadedImage.file.path}');
          // 这里只添加日志，不做处理，观察图片路径和特性
        } catch (e) {
          print('检查图片信息失败: $e');
        }
      }

      // 1. 获取预签名URL
      print('获取预签名上传URL...');
      final uploadResponse = await UploadApi.getImageUploadUrl(
        fileName,
        contentType,
      );

      if (uploadResponse == null) {
        throw Exception('获取上传URL失败');
      }
      print('获取预签名URL成功: ${uploadResponse.uploadUrl}');

      // 更新进度
      setState(() {
        _selectedImages[index] = _selectedImages[index].copyWith(
          progress: 30.0,
        );
      });

      // 2. 上传文件到S3
      print('开始上传文件到S3...');
      final uploadSuccess = await UploadApi.uploadFileToS3(
        uploadResponse.uploadUrl,
        uploadedImage.file,
        contentType,
      );

      if (!uploadSuccess) {
        throw Exception('上传到S3失败');
      }
      print('上传S3成功');

      // 3. 上传成功
      setState(() {
        _selectedImages[index] = _selectedImages[index].copyWith(
          status: UploadStatus.success,
          progress: 100.0,
          fileUrl: uploadResponse.fileUrl,
          fileKey: uploadResponse.fileKey,
        );
      });
      print('文件URL: ${uploadResponse.fileUrl}');

      Fluttertoast.showToast(
        msg: '图片上传成功',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('上传图片失败: ${e.toString()}');
      // 上传失败
      final index = _selectedImages.indexOf(uploadedImage);
      if (index != -1) {
        setState(() {
          _selectedImages[index] = _selectedImages[index].copyWith(
            status: UploadStatus.failed,
            errorMessage: e.toString(),
          );
        });
      }

      Fluttertoast.showToast(
        msg: '图片上传失败: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _addImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('最多只能选择5张图片')));
      return;
    }

    // 显示图片来源选择菜单
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 从选定的来源获取图片
  Future<void> _getImage(ImageSource source) async {
    try {
      print('===== 开始拍照/选择图片 source: $source =====');

      // 针对iOS相机的特殊处理
      if (source == ImageSource.camera && Platform.isIOS) {
        print('检测到iOS相机，使用特殊参数');
        // iOS相机情况下的参数组合
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1200, // 稍微提高分辨率
          maxHeight: 1200, // 稍微提高分辨率
          imageQuality: 95, // 高质量
          preferredCameraDevice: CameraDevice.rear,
          // iOS颜色处理参数：通常对于图片颜色问题，requestFullMetadata设为false会有帮助
          requestFullMetadata: false,
        );

        if (image != null) {
          print('iOS相机图片获取成功：${image.path}');
          _processImage(image);
        } else {
          print('用户取消了拍照');
        }
      } else {
        // 相册或其他情况
        print('使用普通参数');
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (image != null) {
          print('图片获取成功：${image.path}');
          _processImage(image);
        } else {
          print('用户取消了选择图片');
        }
      }
    } catch (e) {
      print('拍照/选择图片错误: ${e.toString()}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败: ${e.toString()}')));
    }
  }

  // 处理获取的图片
  void _processImage(XFile image) async {
    print('图片名称：${image.name}');

    // 读取图片信息
    final file = File(image.path);
    final fileSize = await file.length();
    print('图片大小：${(fileSize / 1024).toStringAsFixed(2)}KB');

    // 处理iOS相机图片颜色问题
    File processedFile = file;
    if (Platform.isIOS &&
        (image.path.toLowerCase().endsWith('.jpg') ||
            image.path.toLowerCase().endsWith('.jpeg'))) {
      try {
        print('处理iOS相机图片...');

        // 读取原始图片并处理
        final bytes = await file.readAsBytes();
        final originalImage = img.decodeImage(bytes);

        if (originalImage != null) {
          // 保存处理后的图片到临时文件
          final tempDir = Directory.systemTemp;
          final tempPath =
              '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final processedImageFile = File(tempPath);

          // 进行图片转换 (此处转为PNG格式可以避免iOS的颜色空间问题)
          final processedBytes = img.encodeJpg(originalImage, quality: 90);
          await processedImageFile.writeAsBytes(processedBytes);

          print('处理后的图片保存到: $tempPath');
          processedFile = processedImageFile;
        }
      } catch (e) {
        print('处理图片失败，将使用原始图片: $e');
        // 如果处理失败，使用原始图片
        processedFile = file;
      }
    }

    final uploadedImage = UploadedImage(
      file: processedFile,
      fileName: image.name,
    );

    setState(() {
      _selectedImages.add(uploadedImage);
    });

    // 立即开始上传
    _uploadImage(uploadedImage);
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _selectDeliveryMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) =>
            _buildDeliveryMethodBottomSheet(setModalState),
      ),
    );
  }

  void _selectPrice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) =>
            _buildPriceBottomSheet(setModalState),
      ),
    );
  }

  // 计算预估收入
  double _calculateEstimatedEarnings(double price) {
    // 扣除5%服务费、3%税费和$5包装费
    double serviceFee = price * 0.05;
    double tax = price * 0.03;
    double packagingFee = 5.0;
    return price - serviceFee - tax - packagingFee;
  }

  Widget _buildDeliveryMethodBottomSheet(StateSetter setModalState) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'Delivery Method',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 选项区域
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFF7F7F7)),
              child: Column(
                children: [
                  // Use Consignment Service选项
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _deliveryMethod = 'consignment';
                      });
                      setState(() {
                        _deliveryMethod = 'consignment';
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
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
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: ShapeDecoration(
                              color: _deliveryMethod == 'consignment'
                                  ? const Color(0xFFFFA500)
                                  : Colors.transparent,
                              shape: _deliveryMethod != 'consignment'
                                  ? const OvalBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: Color(0xFF8A8A8F),
                                      ),
                                    )
                                  : const OvalBorder(),
                            ),
                            child: _deliveryMethod == 'consignment'
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Text(
                              'Use Consignment Service',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // No Consignment Service选项
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _deliveryMethod = 'no_consignment';
                      });
                      setState(() {
                        _deliveryMethod = 'no_consignment';
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
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
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: ShapeDecoration(
                              color: _deliveryMethod == 'no_consignment'
                                  ? const Color(0xFFFFA500)
                                  : Colors.transparent,
                              shape: _deliveryMethod != 'no_consignment'
                                  ? const OvalBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: Color(0xFF8A8A8F),
                                      ),
                                    )
                                  : const OvalBorder(),
                            ),
                            child: _deliveryMethod == 'no_consignment'
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Text(
                              'No Consignment Service Needed',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 说明文字
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 2, right: 8),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF8A8A8F),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '?',
                                style: TextStyle(
                                  color: Color(0xFF8A8A8F),
                                  fontSize: 8,
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Note: Storage fees will apply starting from the second month after pickup. Additional return shipping costs may also apply.',
                              style: TextStyle(
                                color: Color(0xFF8A8A8F),
                                fontSize: 11,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w500,
                                height: 1.27,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 确认按钮
                  Container(
                    width: double.infinity,
                    height: 48,
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildPriceBottomSheet(StateSetter setModalState) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      color: const Color.fromARGB(0, 255, 255, 255),
      child: Stack(
        children: [
          // 半透明背景（用于关闭弹窗）
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color.fromARGB(0, 0, 0, 0),
            ),
          ),

          // 各个浮动组件
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 橙色横幅 - 浮动在顶部，只占一半宽度
                Positioned(
                  left: 0,
                  top: -46,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.62,
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFFFA500), Color(0xFFFFB631)],
                          ),
                          // borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Check Suggested Pricing!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Exo 2',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      // 突出的鸭子图标
                      Positioned(
                        left: 190,
                        top: -42,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/duck_pricing.png',
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 建议价格区域
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF666666),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x20000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // 左侧鸭子图标
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: SvgPicture.asset(
                                'assets/images/duck_icon.svg',
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Suggested Price',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${_suggestedPrice.toInt()}',
                          style: const TextStyle(
                            color: Color(0xFFFFBA40),
                            fontSize: 24,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 价格输入区域
                Positioned(
                  left: 0,
                  right: 0,
                  top: 70,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xCCEAEAEA),
                          blurRadius: 4,
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Price',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          '\$',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: KeyboardToolbarBuilder.buildSingle(
                            textField: TextField(
                              controller: _priceController,
                              focusNode: _priceFocusNode,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  _selectedPrice = double.tryParse(value);
                                });
                              },
                            ),
                            focusNode: _priceFocusNode,
                            doneButtonText: 'Done',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 预估收入区域
                Positioned(
                  left: 0,
                  right: 0,
                  top: 118,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
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
                          'Estimated Earnings',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '\$${_selectedPrice != null ? _calculateEstimatedEarnings(_selectedPrice!).toStringAsFixed(2) : "0.00"}',
                          style: const TextStyle(
                            color: Color(0xFF267AFF),
                            fontSize: 20,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 添加小费区域
                Positioned(
                  left: 0,
                  right: 0,
                  top: 166,
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xCCEAEAEA),
                          blurRadius: 4,
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Add a Tip',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '\$${_tipAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFFFA500),
                            fontSize: 16,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 费用说明
                Positioned(
                  left: 0,
                  right: 0,
                  top: 206,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xCCEAEAEA),
                          blurRadius: 4,
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 2, right: 8),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFF8A8A8F),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: Color(0xFF8A8A8F),
                                fontSize: 8,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Estimated earnings after deducting 5% service fee, 3% tax, and \$5 packaging fee.',
                            style: TextStyle(
                              color: Color(0xFF8A8A8F),
                              fontSize: 11,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.27,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 确认按钮
                Positioned(
                  left: 20,
                  right: 20,
                  // bottom: 40,
                  top: 296,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_priceController.text.isNotEmpty) {
                        setState(() {
                          _selectedPrice = double.tryParse(
                            _priceController.text,
                          );
                        });
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w800,
                      ),
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

  bool get _canSend =>
      _selectedImages.isNotEmpty &&
      _selectedImages.any((img) => img.isSuccess) &&
      _descriptionController.text.isNotEmpty &&
      _deliveryMethod != null &&
      _selectedPrice != null &&
      _selectedPrice! > 0 &&
      _agreeToTerms;

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
              colors: [Color(0xFFFFF6E6), Colors.white],
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

                    // 主要内容区域
                    _buildMainContent(),
                    const SizedBox(height: 20),

                    // 配送方式
                    _buildDeliveryMethod(),
                    const SizedBox(height: 10),

                    // 价格
                    _buildPrice(),
                    const SizedBox(height: 32),

                    // 协议和按钮
                    _buildAgreementAndButton(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _handleCloseButton,
              child: Container(
                width: 24,
                height: 24,
                child: const Icon(Icons.close, size: 24, color: Colors.black),
              ),
            ),
            const SizedBox(width: 26),
            const Text(
              'List Your Item',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _canSend ? _onSend : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: ShapeDecoration(
              color: _canSend
                  ? const Color(0xFFFFA500)
                  : const Color(0xFFC7C7CC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Send',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
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
          // 图片上传区域
          _buildImageUploadSection(),
          const SizedBox(height: 24),

          // 描述输入区域
          _buildDescriptionSection(),
          const SizedBox(height: 24),

          // 标签显示区域
          _buildTagsSection(),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 显示已选择的图片
          ..._selectedImages.asMap().entries.map((entry) {
            int index = entry.key;
            UploadedImage uploadedImage = entry.value;
            return Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      uploadedImage.file,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 上传状态覆盖层
                  if (uploadedImage.isUploading)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${uploadedImage.progress.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 上传失败状态
                  if (uploadedImage.isFailed)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.white, size: 20),
                          SizedBox(height: 2),
                          Text(
                            '上传失败',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 上传成功标识
                  if (uploadedImage.isSuccess)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // 删除按钮
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          // 只显示一个占位图片框（当没有图片时）
          if (_selectedImages.isEmpty)
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: ShapeDecoration(
                color: const Color(0xFFF3F3F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.image,
                size: 40,
                color: Color(0xFF999999),
              ),
            ),

          // 添加图片按钮
          if (_selectedImages.length < 5)
            GestureDetector(
              onTap: _addImage,
              child: Container(
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: Color(0xFF7F7F7F),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      height: 80, // 为多行TextField提供固定高度
      child: KeyboardToolbarBuilder.buildSingle(
        textField: TextField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          maxLines: 3,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Describe your item to attract more buyers!',
            hintStyle: TextStyle(
              color: Color(0xFFABABAB),
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() {}),
        ),
        focusNode: _descriptionFocusNode,
        doneButtonText: 'Done',
      ),
    );
  }

  Widget _buildTagsSection() {
    return Row(
      children: [
        if (selectedCategory != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFBA40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              selectedCategory!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: ShapeDecoration(
            color: const Color(0xFFF3F3F3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text(
            'Condition',
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 8,
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryMethod() {
    return GestureDetector(
      onTap: _selectDeliveryMethod,
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
              'Delivery Method',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_deliveryMethod != null)
                  Text(
                    _deliveryMethod == 'consignment' ? 'UCS' : 'NCSN',
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF999999),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrice() {
    return GestureDetector(
      onTap: _selectPrice,
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
              'Price',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedPrice != null)
                  Text(
                    '\$${_selectedPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF999999),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementAndButton() {
    return Column(
      children: [
        // 协议复选框
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _agreeToTerms = !_agreeToTerms;
                });
              },
              child: Container(
                width: 15,
                height: 15,
                decoration: ShapeDecoration(
                  color: _agreeToTerms
                      ? const Color(0xFFFFA500)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: _agreeToTerms
                          ? const Color(0xFFFFA500)
                          : const Color(0xFFB4B4B4),
                    ),
                    borderRadius: BorderRadius.circular(7.5),
                  ),
                ),
                child: _agreeToTerms
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'I agree to fulfill the ',
                      style: TextStyle(
                        color: Color(0xFFB4B4B4),
                        fontSize: 10,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(
                      text: 'Seller Commitment Agreement',
                      style: TextStyle(
                        color: Color(0xFF4195F9),
                        fontSize: 10,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(
                      text: '.',
                      style: TextStyle(
                        color: Color(0xFFB4B4B4),
                        fontSize: 10,
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
        const SizedBox(height: 16),

        // Next 按钮
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: _canSend ? _onSend : null,
            child: Container(
              height: 48,
              decoration: ShapeDecoration(
                color: _canSend
                    ? const Color(0xFFFFA500)
                    : const Color(0xFFC7C7CC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
