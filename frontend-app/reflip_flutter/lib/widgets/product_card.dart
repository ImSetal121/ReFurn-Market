import 'package:flutter/material.dart';
import 'dart:convert';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;

  const ProductCard({Key? key, required this.product, this.onTap})
    : super(key: key);

  /// 导航到商品详情页
  void _navigateToProductDetail(BuildContext context) {
    final productId = product['id'];
    if (productId != null) {
      Navigator.pushNamed(
        context,
        '/product-detail',
        arguments: {'productId': productId},
      );
    }
  }

  /// 检查商品是否可点击（状态为LISTED）
  bool get _isClickable {
    final status = product['status']?.toString().toUpperCase();
    return status == 'LISTED';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isClickable
          ? () {
              // 优先使用传入的onTap回调，否则默认跳转到商品详情页
              if (onTap != null) {
                onTap!();
              } else {
                _navigateToProductDetail(context);
              }
            }
          : null,
      child: Stack(
        children: [
          Container(
            decoration: ShapeDecoration(
              color: const Color(0xFFFBFBFB),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 商品图片
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(0),
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0.00, 0.00),
                        end: Alignment(0.73, 1.00),
                        colors: [Color(0xFFFFFAF1), Color(0xFFF6F6F6)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Image.network(
                      product['image'] ?? 'https://placehold.co/160x120',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),

                // 商品信息
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 商品标题
                        Flexible(
                          child: Text(
                            product['title'] ?? 'Unknown Product',
                            style: const TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 11,
                              fontFamily: 'PingFang SC',
                              fontWeight: FontWeight.w400,
                              height: 1.27,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 价格
                        Row(
                          children: [
                            const Text(
                              '\$',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontFamily: 'PingFang SC',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              product['price']?.toString() ?? '0',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (product['cents'] != null &&
                                product['cents'].toString().isNotEmpty)
                              Text(
                                product['cents'].toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 6,
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // 标签
                        Wrap(spacing: 4, runSpacing: 2, children: _buildTags()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 状态不为LISTED时显示灰色蒙版
          if (!_isClickable)
            Positioned.fill(
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(product['status']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 获取状态显示文本
  String _getStatusText(String? status) {
    switch (status?.toUpperCase()) {
      case 'LISTED':
        return 'Listed';
      case 'UNLISTED':
        return 'Unlisted';
      case 'PAYMENT_LOCKED':
        return 'Payment Locked';
      case 'SOLD':
        return 'Sold';
      case 'RETURNED_TO_SELLER':
        return 'Returned to Seller';
      default:
        return 'Unknown Status';
    }
  }

  /// 构建标签列表
  List<Widget> _buildTags() {
    List<String> tags = _generateTags(product);
    List<Color> tagColors = _generateTagColors(product);

    return List.generate(
      tags.length,
      (index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: ShapeDecoration(
          color: tagColors[index].withOpacity(0.1),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.2, color: tagColors[index]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        child: Text(
          tags[index],
          style: TextStyle(
            color: tagColors[index],
            fontSize: 6,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 生成商品标签
  List<String> _generateTags(Map<String, dynamic> product) {
    List<String> tags = [];

    // 根据商品属性生成标签
    if (product['isSelfPickup'] == true) {
      tags.add('Self Pickup');
    } else {
      tags.add('Delivery Available');
    }

    // 根据库存生成标签
    int stock = product['stock'] ?? 0;
    if (stock > 10) {
      tags.add('In Stock');
    } else if (stock > 0) {
      tags.add('Limited Stock');
    }

    // 根据商品状态生成标签
    if (product['status'] == 'LISTED' || product['status'] == 'ACTIVE') {
      tags.add('Good Condition');
    }

    return tags.take(2).toList(); // 最多显示2个标签
  }

  /// 生成标签颜色
  List<Color> _generateTagColors(Map<String, dynamic> product) {
    List<Color> colors = [];
    List<String> tags = _generateTags(product);

    for (String tag in tags) {
      switch (tag) {
        case 'Self Pickup':
          colors.add(const Color(0xFFFCA600));
          break;
        case 'Delivery Available':
          colors.add(const Color(0xFF267AFF));
          break;
        case 'In Stock':
        case 'Good Condition':
          colors.add(const Color(0xFF35B13F));
          break;
        case 'Limited Stock':
          colors.add(const Color(0xFFFF6B35));
          break;
        default:
          colors.add(const Color(0xFF8A8A8F));
      }
    }

    return colors;
  }

  /// 从后端数据创建ProductCard所需的产品数据
  static Map<String, dynamic> fromBackendData(
    Map<String, dynamic> backendProduct,
  ) {
    // 解析图片JSON
    String imageUrl = 'https://placehold.co/160x120';
    try {
      if (backendProduct['imageUrlJson'] != null) {
        final imageJson = jsonDecode(backendProduct['imageUrlJson']);
        if (imageJson is Map && imageJson.containsKey('1')) {
          imageUrl = imageJson['1'];
        }
      }
    } catch (e) {
      print('解析图片URL失败: $e');
    }

    // 解析价格
    double price = (backendProduct['price'] ?? 0).toDouble();
    String priceStr = price.toStringAsFixed(2);
    List<String> priceParts = priceStr.split('.');

    return {
      'id': backendProduct['id'],
      'title': backendProduct['name'] ?? 'Unknown Product',
      'price': priceParts[0],
      'cents': priceParts.length > 1 && priceParts[1] != '00'
          ? priceParts[1]
          : '',
      'image': imageUrl,
      'description': backendProduct['description'] ?? '',
      'type': backendProduct['type'] ?? '',
      'category': backendProduct['category'] ?? '',
      'address': backendProduct['address'] ?? '',
      'isSelfPickup': backendProduct['isSelfPickup'] ?? false,
      'stock': backendProduct['stock'] ?? 0,
      'status': backendProduct['status'] ?? '',
    };
  }
}
