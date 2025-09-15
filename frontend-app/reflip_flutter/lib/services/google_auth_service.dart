import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../api/auth_api.dart';
import '../models/login_user.dart';
import '../stores/auth_store.dart';

class GoogleAuthService {
  static GoogleSignIn? _googleSignIn;

  /// 初始化Google Sign In
  static GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn(
      // 明确指定客户端ID（对于iOS模拟器很重要）
      clientId: Platform.isIOS
          ? '800222111986-sa7j8st9bg0r0kin6u7q9ih3khugn59b.apps.googleusercontent.com'
          : null,
      scopes: ['email', 'profile', 'openid'],
    );
    return _googleSignIn!;
  }

  /// Google登录
  static Future<bool> signInWithGoogle() async {
    try {
      print('GoogleAuthService: 开始Google登录流程');

      // 检查是否在iOS模拟器上
      if (Platform.isIOS) {
        print('GoogleAuthService: 运行在iOS平台');
      }

      // 1. 发起Google登录
      print('GoogleAuthService: 调用googleSignIn.signIn()');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('GoogleAuthService: 用户取消登录');
        return false;
      }

      print('GoogleAuthService: 用户选择了账户: ${googleUser.email}');

      // 2. 获取认证详情
      print('GoogleAuthService: 获取认证详情');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print('GoogleAuthService: 无法获取ID Token');
        Fluttertoast.showToast(
          msg: '无法获取Google ID Token',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }

      print('GoogleAuthService: 成功获取ID Token');

      // 3. 调用后端API进行登录
      print('GoogleAuthService: 调用后端API登录');
      final LoginUser? loginUser = await AuthApi.googleMobileLogin(idToken);

      if (loginUser != null && loginUser.token != null) {
        // 4. 保存登录状态
        await authStore.setAccessToken(loginUser.token!);

        // 5. 显示成功提示
        final isNewUser = loginUser.isNewUser ?? false;
        Fluttertoast.showToast(
          msg: isNewUser ? 'Google注册成功，欢迎加入！' : 'Google登录成功',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        print('GoogleAuthService: 登录成功');
        return true;
      } else {
        print('GoogleAuthService: 后端API返回空结果');
        Fluttertoast.showToast(
          msg: 'Google登录失败',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('GoogleAuthService: 登录错误: $e');
      Fluttertoast.showToast(
        msg: 'Google登录失败: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }
  }

  /// Google登出
  static Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      print('GoogleAuthService: Google登出成功');
    } catch (e) {
      print('GoogleAuthService: Google登出错误: $e');
    }
  }

  /// 检查是否已经登录Google
  static Future<bool> isSignedIn() async {
    try {
      return await googleSignIn.isSignedIn();
    } catch (e) {
      print('GoogleAuthService: 检查Google登录状态错误: $e');
      return false;
    }
  }

  /// 获取当前Google用户
  static GoogleSignInAccount? getCurrentUser() {
    return googleSignIn.currentUser;
  }

  /// 静默登录（如果之前已经授权过）
  static Future<bool> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn
          .signInSilently();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken != null) {
          final LoginUser? loginUser = await AuthApi.googleMobileLogin(idToken);

          if (loginUser != null && loginUser.token != null) {
            await authStore.setAccessToken(loginUser.token!);
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('GoogleAuthService: Google静默登录错误: $e');
      return false;
    }
  }
}
