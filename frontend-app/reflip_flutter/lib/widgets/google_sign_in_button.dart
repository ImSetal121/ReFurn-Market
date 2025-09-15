import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  final String? text;
  final bool isIconOnly;
  final double? width;
  final double? height;

  const GoogleSignInButton({
    Key? key,
    this.onSuccess,
    this.onError,
    this.text,
    this.isIconOnly = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await GoogleAuthService.signInWithGoogle();

      if (success && mounted) {
        widget.onSuccess?.call();
      } else if (mounted) {
        widget.onError?.call();
      }
    } catch (e) {
      print('Google登录错误: $e');
      if (mounted) {
        widget.onError?.call();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isIconOnly) {
      // 图标按钮模式
      return GestureDetector(
        onTap: _handleGoogleSignIn,
        child: Container(
          width: widget.width ?? 40,
          height: widget.height ?? 40,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: OvalBorder(
              side: BorderSide(color: const Color(0xFFE0E0E0), width: 1),
            ),
          ),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.g_mobiledata, color: Colors.black, size: 24),
          ),
        ),
      );
    } else {
      // 完整按钮模式
      return SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleGoogleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: BorderSide(color: const Color(0xFFE0E0E0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata, color: Colors.black, size: 24),
                    SizedBox(width: 8),
                    Text(
                      widget.text ?? '使用 Google 登录',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }
  }
}
