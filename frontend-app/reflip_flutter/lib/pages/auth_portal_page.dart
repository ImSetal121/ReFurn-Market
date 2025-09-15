import 'package:flutter/material.dart';
import '../stores/auth_store.dart';
import '../widgets/google_sign_in_button.dart';

class AuthPortalPage extends StatefulWidget {
  const AuthPortalPage({Key? key}) : super(key: key);

  @override
  State<AuthPortalPage> createState() => _AuthPortalPageState();
}

class _AuthPortalPageState extends State<AuthPortalPage> with RouteAware {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToEmailSignIn() async {
    print('AuthPortalPage: Navigating to email sign in');
    final result = await Navigator.of(context).pushNamed('/sign-in-email');
    print('AuthPortalPage: Returned from email sign in with result: $result');

    // 检查登录状态，如果登录成功则关闭门户页面
    if (mounted && authStore.isAuthenticated) {
      print('AuthPortalPage: 邮箱登录成功, closing portal');
      // 使用延迟确保Navigator状态稳定
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      });
    } else {
      print('AuthPortalPage: User not authenticated, staying on portal');
    }
  }

  void _onGoogleSignInSuccess() {
    print('AuthPortalPage: Google登录成功');
    if (mounted) {
      // Google登录成功，关闭门户页面并返回成功标识
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFFFFF6E6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // 主要插图图片
                  Container(
                    width: 260,
                    height: 340,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/auth_welcome_illustration.png',
                        ),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Welcome illustration image not found');
                        },
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color.fromARGB(0, 238, 238, 238), // 占位背景色
                    ),
                  ),

                  const SizedBox(height: 44),

                  // 欢迎文本区域
                  Column(
                    children: [
                      // 主标题
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome to ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'R',
                              style: TextStyle(
                                color: const Color(0xFFFFA500),
                                fontSize: 32,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'eFlip!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // 副标题
                      Text(
                        'From listing to living — ReFlip covers it all.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  // 手机注册按钮
                  Container(
                    width: double.infinity,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        _showPhoneSignUpDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sign up with phone',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 分隔线和文本
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFC7C7CC),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or sign up with',
                          style: TextStyle(
                            color: const Color(0xFF8A8A8F),
                            fontSize: 14,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFC7C7CC),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 社交登录按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 邮箱登录按钮
                      GestureDetector(
                        onTap: () {
                          _showEmailSignUpDialog(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF267AFF),
                            shape: OvalBorder(),
                          ),
                          child: Icon(
                            Icons.email,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Apple登录按钮
                      GestureDetector(
                        onTap: () {
                          _showAppleSignInDialog(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF000000),
                            shape: OvalBorder(),
                          ),
                          child: Icon(
                            Icons.apple,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Google登录按钮
                      GoogleSignInButton(
                        isIconOnly: true,
                        onSuccess: _onGoogleSignInSuccess,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 底部登录提示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account ?',
                        style: TextStyle(
                          color: const Color(0xFF8A8A8F),
                          fontSize: 14,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _navigateToEmailSignIn,
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: const Color(0xFFFFA500),
                            fontSize: 14,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 显示手机注册对话框
  void _showPhoneSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Phone Sign Up'),
          content: const Text('Not available yet, please use Google Sign In'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 显示Apple登录对话框
  void _showAppleSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Apple Sign In'),
          content: const Text('Not available yet, please use Google Sign In'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 显示邮箱注册对话框
  void _showEmailSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Sign Up'),
          content: const Text('Not available yet, please use Google Sign In'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
