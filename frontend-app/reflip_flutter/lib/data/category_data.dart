/// 统一管理所有分类和子分类数据的类
///
/// 使用示例：
/// ```dart
/// // 获取主要分类列表
/// final categories = CategoryData.mainCategories;
///
/// // 获取Living Room的子分类
/// final subCategories = CategoryData.getSubCategories('Living Room');
///
/// // 获取发布商品页面的分类（包含Others选项）
/// final listingSubCategories = CategoryData.getListingSubCategories('Living Room');
///
/// // 验证分类是否有效
/// final isValid = CategoryData.isCategoryValid('Living Room');
/// ```
class CategoryData {
  // 主要分类列表
  static const List<String> mainCategories = [
    'Living Room',
    'Bedroom',
    'Office & Study',
    'Dining Room',
    'Hallway',
    'Accessories',
    'Outdoor',
    'Appliances',
    'Lighting',
    'Others',
  ];

  // 分类和子分类映射
  static const Map<String, List<String>> categorySubCategories = {
    'Living Room': [
      'Sofa',
      'Coffee Table',
      'TV Stand',
      'Armchair',
      'Storage Cabinet',
      'Rug',
    ],
    'Bedroom': ['Bed', 'Nightstand', 'Dresser', 'Wardrobe', 'Mirror', 'Bench'],
    'Office & Study': [
      'Desk',
      'Chair',
      'Bookshelf',
      'File Cabinet',
      'Lamp',
      'Storage',
    ],
    'Dining Room': [
      'Dining Table',
      'Dining Chair',
      'Buffet',
      'Bar Stool',
      'Sideboard',
      'Cart',
    ],
    'Hallway': [
      'Console Table',
      'Coat Rack',
      'Mirror',
      'Bench',
      'Storage',
      'Shoe Cabinet',
    ],
    'Accessories': [
      'Vase',
      'Picture Frame',
      'Cushion',
      'Throw',
      'Candle',
      'Clock',
    ],
    'Outdoor': [
      'Patio Set',
      'Garden Chair',
      'Umbrella',
      'Planter',
      'Outdoor Sofa',
      'Fire Pit',
    ],
    'Appliances': [
      'Refrigerator',
      'Washing Machine',
      'Microwave',
      'Air Conditioner',
      'Vacuum',
      'Blender',
    ],
    'Lighting': [
      'Ceiling Light',
      'Table Lamp',
      'Floor Lamp',
      'Wall Light',
      'Pendant Light',
      'Chandelier',
    ],
    'Others': [
      'Tool',
      'Sports Equipment',
      'Pet Supplies',
      'Garden Tool',
      'Cleaning Supply',
      'Electronics',
    ],
  };

  // 为发布商品页面特别定制的分类映射（包含Others选项）
  static const Map<String, List<String>> listingCategories = {
    'Living Room': [
      'Sofa',
      'Coffee Table',
      'TV Stand',
      'Armchair',
      'Storage Cabinet',
      'Rug',
      'Others',
    ],
    'Bedroom': [
      'Bed',
      'Wardrobe',
      'Dresser',
      'Bedside Table',
      'Mirror',
      'Others',
    ],
    'Office & Study': [
      'Desk',
      'Office Chair',
      'Bookshelf',
      'Filing Cabinet',
      'Others',
    ],
    'Dining Room': ['Dining Table', 'Dining Chair', 'Cabinet', 'Others'],
    'Hallway': [
      'Console Table',
      'Coat Rack',
      'Mirror',
      'Bench',
      'Storage',
      'Shoe Cabinet',
      'Others',
    ],
    'Accessories': ['Lamp', 'Cushion', 'Vase', 'Picture Frame', 'Others'],
    'Outdoor': ['Garden Chair', 'Garden Table', 'Umbrella', 'Others'],
    'Appliances': [
      'Refrigerator',
      'Washing Machine',
      'Air Conditioner',
      'Others',
    ],
    'Lighting': [
      'Ceiling Light',
      'Table Lamp',
      'Floor Lamp',
      'Wall Light',
      'Pendant Light',
      'Chandelier',
      'Others',
    ],
    'Others': [
      'Tool',
      'Sports Equipment',
      'Pet Supplies',
      'Garden Tool',
      'Cleaning Supply',
      'Electronics',
      'Others',
    ],
  };

  // 发布商品页面使用的主分类（包含Pet分类）
  static const List<String> listingMainCategories = [
    'Living Room',
    'Bedroom',
    'Office & Study',
    'Dining Room',
    'Pet',
    'Outdoor',
    'Appliances',
    'Accessories',
    'Others',
  ];

  // Pet分类的子分类
  static const Map<String, List<String>> petCategories = {
    'Pet': ['Pet Bed', 'Pet House', 'Pet Toy', 'Others'],
  };

  /// 获取指定分类的子分类列表
  /// 用于商品浏览页面（不包含Others选项）
  static List<String> getSubCategories(String category) {
    return categorySubCategories[category] ?? [];
  }

  /// 获取发布商品页面指定分类的子分类列表
  /// 包含Others选项，用于商品发布时的分类选择
  static List<String> getListingSubCategories(String category) {
    if (category == 'Pet') {
      return petCategories[category] ?? [];
    }
    return listingCategories[category] ?? [];
  }

  /// 检查分类是否存在
  static bool isCategoryValid(String category) {
    return mainCategories.contains(category) || category == 'Pet';
  }

  /// 检查子分类是否存在于指定分类中（商品浏览）
  static bool isSubCategoryValid(String category, String subCategory) {
    final subCategories = getSubCategories(category);
    return subCategories.contains(subCategory);
  }

  /// 检查发布商品的子分类是否存在于指定分类中
  static bool isListingSubCategoryValid(String category, String subCategory) {
    final subCategories = getListingSubCategories(category);
    return subCategories.contains(subCategory);
  }

  /// 获取所有分类名称（包含Pet）
  static List<String> getAllCategories() {
    final allCategories = List<String>.from(mainCategories);
    allCategories.add('Pet');
    return allCategories;
  }
}
