import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

/// iOS风格的键盘工具栏组件
/// 基于keyboard_actions包实现，支持多平台但目前仅在iOS上生效
/// 提供Done按钮来收起键盘
class IOSKeyboardToolbar extends StatelessWidget {
  /// 子组件，通常包含TextField
  final Widget child;

  /// 焦点节点列表，需要与TextField的focusNode对应
  final List<FocusNode> focusNodes;

  /// Done按钮的文本，默认为"Done"
  final String doneButtonText;

  /// 键盘工具栏的背景色，默认为浅灰色
  final Color? keyboardBarColor;

  /// 是否启用焦点间的导航（上一个/下一个），默认为true
  final bool nextFocus;

  /// 是否仅在iOS平台显示工具栏，默认为true
  final bool iOSOnly;

  const IOSKeyboardToolbar({
    Key? key,
    required this.child,
    required this.focusNodes,
    this.doneButtonText = 'Done',
    this.keyboardBarColor,
    this.nextFocus = true,
    this.iOSOnly = true,
  }) : super(key: key);

  /// 构建键盘配置
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      // 根据iOSOnly参数决定平台支持
      keyboardActionsPlatform: iOSOnly
          ? KeyboardActionsPlatform.IOS
          : KeyboardActionsPlatform.ALL,

      // 键盘工具栏背景色
      keyboardBarColor: keyboardBarColor ?? Colors.grey[200],

      // 是否启用焦点间导航
      nextFocus: nextFocus,

      // 为每个焦点节点创建KeyboardActionsItem
      actions: focusNodes
          .map(
            (focusNode) => KeyboardActionsItem(
              focusNode: focusNode,
              // 自定义Done按钮
              toolbarButtons: [
                (node) {
                  return GestureDetector(
                    onTap: () {
                      // 点击Done按钮时收起键盘
                      node.unfocus();
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        doneButtonText,
                        style: const TextStyle(
                          color: Color(0xFF007AFF), // iOS蓝色
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ],
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 如果设置为仅iOS且当前不是iOS平台，则直接返回child
    if (iOSOnly && defaultTargetPlatform != TargetPlatform.iOS) {
      return child;
    }

    return KeyboardActions(config: _buildConfig(context), child: child);
  }
}

/// 简化版的单个TextField键盘工具栏
/// 适用于只有一个TextField的场景
class SingleTextFieldKeyboardToolbar extends StatelessWidget {
  /// TextField组件
  final TextField textField;

  /// 焦点节点
  final FocusNode focusNode;

  /// Done按钮的文本，默认为"Done"
  final String doneButtonText;

  /// 键盘工具栏的背景色
  final Color? keyboardBarColor;

  /// 是否仅在iOS平台显示工具栏，默认为true
  final bool iOSOnly;

  const SingleTextFieldKeyboardToolbar({
    Key? key,
    required this.textField,
    required this.focusNode,
    this.doneButtonText = 'Done',
    this.keyboardBarColor,
    this.iOSOnly = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IOSKeyboardToolbar(
      focusNodes: [focusNode],
      doneButtonText: doneButtonText,
      keyboardBarColor: keyboardBarColor,
      nextFocus: false, // 单个TextField不需要导航
      iOSOnly: iOSOnly,
      child: textField,
    );
  }
}

/// 键盘工具栏构建器
/// 提供静态方法来快速创建键盘工具栏
class KeyboardToolbarBuilder {
  /// 为单个TextField构建键盘工具栏
  static Widget buildSingle({
    required TextField textField,
    required FocusNode focusNode,
    String doneButtonText = 'Done',
    Color? keyboardBarColor,
    bool iOSOnly = true,
  }) {
    return SingleTextFieldKeyboardToolbar(
      textField: textField,
      focusNode: focusNode,
      doneButtonText: doneButtonText,
      keyboardBarColor: keyboardBarColor,
      iOSOnly: iOSOnly,
    );
  }

  /// 为多个TextField构建键盘工具栏
  static Widget buildMultiple({
    required Widget child,
    required List<FocusNode> focusNodes,
    String doneButtonText = 'Done',
    Color? keyboardBarColor,
    bool nextFocus = true,
    bool iOSOnly = true,
  }) {
    return IOSKeyboardToolbar(
      child: child,
      focusNodes: focusNodes,
      doneButtonText: doneButtonText,
      keyboardBarColor: keyboardBarColor,
      nextFocus: nextFocus,
      iOSOnly: iOSOnly,
    );
  }
}

/// 自定义的表单容器，自动为包含的TextField添加键盘工具栏
class KeyboardAwareForm extends StatelessWidget {
  /// 表单内容
  final Widget child;

  /// 焦点节点列表
  final List<FocusNode> focusNodes;

  /// Done按钮文本
  final String doneButtonText;

  /// 键盘工具栏背景色
  final Color? keyboardBarColor;

  const KeyboardAwareForm({
    Key? key,
    required this.child,
    required this.focusNodes,
    this.doneButtonText = '完成',
    this.keyboardBarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IOSKeyboardToolbar(
      child: child,
      focusNodes: focusNodes,
      doneButtonText: doneButtonText,
      keyboardBarColor: keyboardBarColor,
    );
  }
}
