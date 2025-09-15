import 'package:flutter/material.dart';
import 'ios_keyboard_toolbar.dart';

/// iOS键盘工具栏使用示例页面
class IOSKeyboardToolbarExample extends StatefulWidget {
  const IOSKeyboardToolbarExample({Key? key}) : super(key: key);

  @override
  State<IOSKeyboardToolbarExample> createState() =>
      _IOSKeyboardToolbarExampleState();
}

class _IOSKeyboardToolbarExampleState extends State<IOSKeyboardToolbarExample> {
  // 单个TextField的焦点节点
  final FocusNode _singleFocusNode = FocusNode();
  final TextEditingController _singleController = TextEditingController();

  // 多个TextField的焦点节点
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    // 清理控制器和焦点节点
    _singleFocusNode.dispose();
    _singleController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _descriptionFocusNode.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS键盘工具栏示例'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 示例1：单个TextField使用KeyboardToolbarBuilder
            _buildSectionTitle('示例1：单个TextField (使用KeyboardToolbarBuilder)'),
            const SizedBox(height: 10),
            KeyboardToolbarBuilder.buildSingle(
              textField: TextField(
                controller: _singleController,
                focusNode: _singleFocusNode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '输入数字，查看Done按钮',
                  border: OutlineInputBorder(),
                ),
              ),
              focusNode: _singleFocusNode,
              doneButtonText: '完成',
            ),

            const SizedBox(height: 40),

            // 示例2：单个TextField使用SingleTextFieldKeyboardToolbar
            _buildSectionTitle(
              '示例2：单个TextField (使用SingleTextFieldKeyboardToolbar)',
            ),
            const SizedBox(height: 10),
            SingleTextFieldKeyboardToolbar(
              textField: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: '输入邮箱地址',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              focusNode: FocusNode(),
              doneButtonText: 'Done',
            ),

            const SizedBox(height: 40),

            // 示例3：多个TextField使用IOSKeyboardToolbar
            _buildSectionTitle('示例3：多个TextField (带焦点导航)'),
            const SizedBox(height: 10),
            IOSKeyboardToolbar(
              focusNodes: [_nameFocusNode, _emailFocusNode, _phoneFocusNode],
              doneButtonText: '完成',
              nextFocus: true, // 启用焦点导航
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '姓名',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '邮箱',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: '电话',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 示例4：使用KeyboardAwareForm
            _buildSectionTitle('示例4：使用KeyboardAwareForm'),
            const SizedBox(height: 10),
            KeyboardAwareForm(
              focusNodes: [_descriptionFocusNode],
              doneButtonText: '确定',
              child: TextField(
                controller: _descriptionController,
                focusNode: _descriptionFocusNode,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: '描述',
                  hintText: '输入详细描述...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 使用说明
            _buildUsageInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildUsageInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '使用说明：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1. 键盘工具栏仅在iOS设备上显示\n'
            '2. 点击任意TextField激活键盘时会显示工具栏\n'
            '3. 工具栏上的Done按钮可以收起键盘\n'
            '4. 多个TextField可以通过上/下箭头导航\n'
            '5. 支持自定义Done按钮文本和工具栏颜色',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}
