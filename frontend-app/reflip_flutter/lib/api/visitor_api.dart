import '../utils/request.dart';

class VisitorApi {
  static const String _baseUrl = '/api/visitor';

  /// 搜索商品
  ///
  /// [keyword] 搜索关键词
  /// [type] 商品类型
  /// [category] 商品类别
  /// [minPrice] 最低价格
  /// [maxPrice] 最高价格
  /// [sortBy] 排序方式 (recommended, price_asc, price_desc, distance, condition)
  /// [page] 页码 (默认1)
  /// [size] 每页大小 (默认10)
  /// 返回分页搜索结果
  static Future<Map<String, dynamic>?> searchProducts({
    String? keyword,
    String? type,
    String? category,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'recommended',
    int page = 1,
    int size = 10,
  }) async {
    // 构建查询参数
    Map<String, dynamic> queryParams = {
      'sortBy': sortBy,
      'page': page,
      'size': size,
    };

    // 添加可选参数
    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (minPrice != null && minPrice > 0) {
      queryParams['minPrice'] = minPrice;
    }
    if (maxPrice != null && maxPrice > 0) {
      queryParams['maxPrice'] = maxPrice;
    }

    return await HttpRequest.get<Map<String, dynamic>>(
      '$_baseUrl/search',
      queryParameters: queryParams,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 获取热门搜索关键词
  ///
  /// 返回热门关键词列表
  static Future<List<String>?> getHotKeywords() async {
    return await HttpRequest.get<List<String>>(
      '$_baseUrl/hot-keywords',
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item.toString()).toList();
        }
        return null;
      },
    );
  }

  /// 获取商品详情
  ///
  /// [productId] 商品ID
  /// 返回商品详情
  static Future<Map<String, dynamic>?> getProductDetail(int productId) async {
    return await HttpRequest.get<Map<String, dynamic>>(
      '$_baseUrl/product/$productId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 搜索建议（自动补全）
  ///
  /// [query] 查询字符串
  /// 返回搜索建议列表
  static Future<List<String>?> getSearchSuggestions(String query) async {
    if (query.isEmpty) return [];

    // TODO: 实现搜索建议接口
    // 暂时返回一些模拟数据
    List<String> suggestions = [
      'Sofa',
      'Chair',
      'Table',
      'Bed',
      'Desk',
      'Bookshelf',
      'Wardrobe',
      'Coffee Table',
      'Dining Set',
      'TV Stand',
    ];

    return suggestions
        .where(
          (suggestion) =>
              suggestion.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// 获取用户公开信息
  ///
  /// [userId] 用户ID
  /// 返回用户公开信息
  static Future<Map<String, dynamic>?> getUserInfo(int userId) async {
    return await HttpRequest.get<Map<String, dynamic>>(
      '$_baseUrl/user/$userId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// 加载更多商品（分页）
  ///
  /// 这是searchProducts的便捷方法，用于加载下一页数据
  static Future<Map<String, dynamic>?> loadMoreProducts({
    required String? keyword,
    required String? type,
    required String? category,
    required double? minPrice,
    required double? maxPrice,
    required String sortBy,
    required int nextPage,
    int size = 10,
  }) async {
    return await searchProducts(
      keyword: keyword,
      type: type,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
      page: nextPage,
      size: size,
    );
  }
}
