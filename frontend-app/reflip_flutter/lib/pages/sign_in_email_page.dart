import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/auth_api.dart';
import '../stores/auth_store.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/ios_keyboard_toolbar.dart';

class SignInEmailPage extends StatefulWidget {
  final Function? onLoginSuccess;
  final String? message;

  const SignInEmailPage({Key? key, this.onLoginSuccess, this.message})
    : super(key: key);

  @override
  State<SignInEmailPage> createState() => _SignInEmailPageState();
}

class _SignInEmailPageState extends State<SignInEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // 焦点节点
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _usernameError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 清除之前的错误状态
    setState(() {
      _usernameError = null;
      _passwordError = null;
      _generalError = null;
    });

    // 手动验证
    bool hasError = false;
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _usernameError = 'empty';
        _generalError = '请输入用户名';
      });
      hasError = true;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'empty';
        _generalError = 'Please enter your password';
      });
      hasError = true;
    }

    // 如果两个都为空，显示通用提示
    if (_usernameController.text.trim().isEmpty &&
        _passwordController.text.isEmpty) {
      setState(() {
        _generalError = '请输入用户名和密码';
      });
    }

    if (hasError) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginUser = await AuthApi.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (loginUser != null && loginUser.token != null) {
        // 打印token信息以便调试
        print('Login successful, token: ${loginUser.token}');

        // 保存令牌
        await authStore.setAccessToken(loginUser.token!);

        // 登录成功回调
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        } else {
          // 登录成功后清除路由栈，避免返回到无效页面
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false, // 清除所有之前的路由
            );
          }
        }

        // 测试获取存储的token
        final storedToken = authStore.accessToken;
        print('Stored token: $storedToken');
      } else {
        if (mounted) {
          Fluttertoast.showToast(
            msg: '登录失败，请检查用户名和密码',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: '登录失败: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() {
    Fluttertoast.showToast(msg: '忘记密码功能即将上线', toastLength: Toast.LENGTH_SHORT);
  }

  void _signUp() {
    Fluttertoast.showToast(msg: '请联系管理员创建账号', toastLength: Toast.LENGTH_SHORT);
  }

  void _onGoogleSignInSuccess() {
    // 登录成功回调
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
    } else {
      // Google登录成功后清除路由栈，避免返回到无效页面
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false, // 清除所有之前的路由
      );
    }
  }

  void _socialLogin(String provider) {
    Fluttertoast.showToast(
      msg: '$provider 登录功能即将上线',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Widget icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF8A8A8F), width: 1),
          color: Colors.white,
        ),
        child: Center(child: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E6), // 根据设计稿的背景色
      resizeToAvoidBottomInset: false, // 防止键盘弹出时页面布局调整
      body: GestureDetector(
        // 点击空白处取消焦点，收起键盘
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        // 确保空白区域也能接收到点击事件
        behavior: HitTestBehavior.translucent,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  // 顶部家具图片背景 - 恢复原有设计
                  Positioned(
                    left: -12,
                    top: 39,
                    child: Container(
                      width: 418,
                      height: 240,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/furniture_bg.png'),
                          fit: BoxFit.cover,
                          onError: (_, __) => print(
                            '图片加载失败，请确保assets/images/furniture_bg.png存在',
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 白色卡片容器 - 调整位置和高度
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 280,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 20,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 37),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 21),

                            // 欢迎标题
                            const Text(
                              'Welcome back!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                                fontFamily: 'Exo 2',
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // 副标题
                            const SizedBox(
                              width: 315,
                              child: Text(
                                'Log in to continue your furniture journey—faster, smarter, and more sustainable.',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 邮箱输入框 - 使用单独的键盘工具栏
                            Container(
                              width: 320,
                              height: 56,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: KeyboardToolbarBuilder.buildSingle(
                                  textField: TextField(
                                    controller: _usernameController,
                                    focusNode: _usernameFocusNode,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email address',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFC7C7CC),
                                        fontSize: 16,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 15,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _usernameError != null
                                              ? const Color(0xFFFF3B30)
                                              : const Color(0xFFE0E0E0),
                                          width: _usernameError != null ? 2 : 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _usernameError != null
                                              ? const Color(0xFFFF3B30)
                                              : const Color(0xFFE0E0E0),
                                          width: _usernameError != null ? 2 : 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _usernameError != null
                                              ? const Color(0xFFFF3B30)
                                              : const Color(0xFFE0E0E0),
                                          width: _usernameError != null ? 2 : 1,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      errorStyle: const TextStyle(height: 0),
                                    ),
                                  ),
                                  focusNode: _usernameFocusNode,
                                  doneButtonText: 'Done',
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 密码输入框 - 使用单独的键盘工具栏
                            Container(
                              width: 320,
                              height: 56,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: KeyboardToolbarBuilder.buildSingle(
                                  textField: TextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFC7C7CC),
                                        fontSize: 16,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 15,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _passwordError != null
                                              ? const Color(0xFFFF3B30)
                                              : const Color(0xFFE0E0E0),
                                          width: _passwordError != null ? 2 : 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _passwordError != null
                                              ? const Color(0xFFFF3B30)
                                              : const Color(0xFFE0E0E0),
                                          width: _passwordError != null ? 2 : 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _passwordError != null
                                              ? const Color(0xFFFF3B30)
                                              : const Color(0xFFE0E0E0),
                                          width: _passwordError != null ? 2 : 1,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      errorStyle: const TextStyle(height: 0),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          margin: const EdgeInsets.all(12),
                                          child: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: const Color(0xFFC7C7CC),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  focusNode: _passwordFocusNode,
                                  doneButtonText: 'Done',
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 忘记密码
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _forgotPassword,
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Color(0xFF8A8A8F),
                                    fontSize: 13,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 0),

                            // 统一错误提示 - 使用固定高度容器
                            Container(
                              height: 20, // 固定高度
                              margin: const EdgeInsets.only(bottom: 16),
                              child: _generalError != null
                                  ? Text(
                                      _generalError!,
                                      style: const TextStyle(
                                        color: Color(0xFFFF3B30),
                                        fontSize: 12,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),

                            // 登录按钮
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
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
                                          'Sign in',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'PingFang SC',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const Spacer(), // 使用Spacer推送底部内容
                            // 分隔线和文本
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFF8A8A8F),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'or sign in with',
                                    style: TextStyle(
                                      color: Color(0xFF8A8A8F),
                                      fontSize: 14,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFF8A8A8F),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 社交媒体登录选项 - 按设计稿顺序：手机、谷歌、苹果
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 手机登录
                                _buildSocialButton(
                                  onTap: () => _socialLogin('Phone'),
                                  icon: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFF070707),
                                      shape: OvalBorder(),
                                    ),
                                    child: const Icon(
                                      Icons.phone_android,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),

                                // Google 登录
                                GoogleSignInButton(
                                  isIconOnly: true,
                                  width: 40,
                                  height: 40,
                                  onSuccess: _onGoogleSignInSuccess,
                                ),
                                const SizedBox(width: 24),

                                // Apple 登录
                                _buildSocialButton(
                                  onTap: () => _socialLogin('Apple'),
                                  icon: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFF070707),
                                      shape: OvalBorder(),
                                    ),
                                    child: const Icon(
                                      Icons.apple,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // 注册提示
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Color(0xFF8A8A8F),
                                    fontSize: 14,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _signUp,
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Color(0xFFFFA500),
                                      fontSize: 14,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
