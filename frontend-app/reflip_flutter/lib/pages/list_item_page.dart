import 'package:flutter/material.dart';
import '../data/category_data.dart';

class ListItemPage extends StatefulWidget {
  const ListItemPage({Key? key}) : super(key: key);

  @override
  State<ListItemPage> createState() => _ListItemPageState();
}

class _ListItemPageState extends State<ListItemPage> {
  String? selectedType;
  String? selectedCategory;

  List<String> get currentCategories {
    if (selectedType == null) return [];
    return CategoryData.getListingSubCategories(selectedType!);
  }

  void _onTypeSelected(String type) {
    setState(() {
      selectedType = type;
      selectedCategory = null; // 重置类别选择
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void _onNext() {
    if (selectedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择家具类型')));
      return;
    }
    if (selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择家具类别')));
      return;
    }

    // 跳转到发布-补全信息页面，传递选中的类型和类别
    Navigator.pushNamed(
      context,
      '/list-item-details',
      arguments: {'type': selectedType, 'category': selectedCategory},
    );
  }

  bool get _canProceed => selectedType != null && selectedCategory != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // 头部标题
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Type 选择部分
                  _buildTypeSection(),
                  const SizedBox(height: 32),

                  // Category 选择部分
                  _buildCategorySection(),
                  const SizedBox(height: 40),

                  // Next 按钮
                  _buildNextButton(),
                  const SizedBox(height: 20),
                ],
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
          onTap: () => _handleCloseButton(),
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
    );
  }

  void _handleCloseButton() {
    // 检查是否可以正常返回上一页
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // 如果无法返回（例如通过登录后直接跳转过来），则导航到首页
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: CategoryData.listingMainCategories
                .map((type) => _buildTypeChip(type))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => _onTypeSelected(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xCCFFA500) : const Color(0xFFF3F3F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1A1C1E),
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: selectedType == null
              ? Container(
                  height: 100,
                  child: const Center(
                    child: Text(
                      '请先选择家具类型',
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: currentCategories
                      .map((category) => _buildCategoryChip(category))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => _onCategorySelected(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xCCFFA500) : const Color(0xFFF3F3F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: _canProceed ? _onNext : null,
        child: Container(
          height: 48,
          decoration: ShapeDecoration(
            color: _canProceed
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
    );
  }
}
