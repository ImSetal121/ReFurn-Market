import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/auth_api.dart';
import '../stores/auth_store.dart';
import '../services/google_auth_service.dart';
import '../services/chat_websocket_service.dart';
import '../api/seller_api.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  bool _isLoggingOut = false;
  bool _isLoadingStripeAccount = false;
  Map<String, dynamic>? _stripeAccountInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStripeAccountInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  DateTime? _lastResumeTime;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Refresh Stripe account status when app returns to foreground
    if (state == AppLifecycleState.resumed) {
      print('App resumed to foreground, preparing to refresh account status');

      // Avoid duplicate refresh - limit minimum refresh interval to 3 seconds
      final now = DateTime.now();
      if (_lastResumeTime == null ||
          now.difference(_lastResumeTime!).inSeconds > 3) {
        _lastResumeTime = now;

        // Delay 1 second before refresh to ensure app UI is ready
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            print('Refreshing Stripe account status after resume');
            _loadStripeAccountInfo();

            // Show hint
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Refreshing account status...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _loadStripeAccountInfo() async {
    try {
      setState(() {
        _isLoadingStripeAccount = true;
      });

      // Sync status first, then get information
      try {
        await SellerApi.syncStripeAccountStatus();
      } catch (e) {
        print('Failed to sync Stripe account status: $e');
        // Continue to try getting current information
      }

      // Get latest information
      final accountInfo = await SellerApi.getStripeAccountInfo();

      if (mounted) {
        setState(() {
          _stripeAccountInfo = accountInfo;
          _isLoadingStripeAccount = false;
        });

        // Show hint if account information is available
        if (accountInfo != null) {
          String status =
              accountInfo['verificationStatus'] as String? ?? 'unknown';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account status updated: ${_getStripeAccountStatusText()}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Failed to load Stripe account information: $e');
      if (mounted) {
        setState(() {
          _isLoadingStripeAccount = false;
        });
      }
    }
  }

  Future<void> _handleStripeAccountSetup() async {
    setState(() {
      _isLoadingStripeAccount = true;
    });

    try {
      if (_stripeAccountInfo == null) {
        // Create new Stripe account
        final result = await SellerApi.createStripeAccount();
        if (result != null && result['accountLinkUrl'] != null) {
          // Open Stripe account setup link
          await _openStripeAccountLink(result['accountLinkUrl'] as String);
        }
      } else {
        // Account exists, refresh account link
        final result = await SellerApi.refreshStripeAccountLink();
        if (result != null && result['accountLinkUrl'] != null) {
          await _openStripeAccountLink(result['accountLinkUrl'] as String);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set up payment account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStripeAccount = false;
        });
      }
    }
  }

  Future<void> _openStripeAccountLink(String url) async {
    print('Opening Stripe account setup link: $url');

    // Show confirmation dialog
    if (mounted) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set up Payment Account'),
          content: const Text(
            'You will be redirected to Stripe to complete payment account setup. Please return to the app after completion.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      // If user chooses to continue, open the link
      if (shouldOpen == true) {
        await _launchUrl(url);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Open in external browser
        );

        // After launching URL, wait for a while then refresh account status
        Future.delayed(const Duration(seconds: 3), () {
          _loadStripeAccountInfo();
        });

        // Show hint message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Stripe account setup page opened. Please return to the app after completion.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Cannot open link');
      }
    } catch (e) {
      print('Failed to open link: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStripeAccountStatusText() {
    if (_stripeAccountInfo == null) {
      return 'Not set up';
    }

    final canReceivePayments =
        _stripeAccountInfo!['canReceivePayments'] as bool? ?? false;
    final verificationStatus =
        _stripeAccountInfo!['verificationStatus'] as String? ?? 'unverified';

    if (canReceivePayments && verificationStatus == 'verified') {
      return 'Verified';
    } else if (canReceivePayments) {
      return 'Set up';
    } else {
      return 'Pending';
    }
  }

  Color _getStripeAccountStatusColor() {
    if (_stripeAccountInfo == null) {
      return Colors.grey;
    }

    final canReceivePayments =
        _stripeAccountInfo!['canReceivePayments'] as bool? ?? false;
    final verificationStatus =
        _stripeAccountInfo!['verificationStatus'] as String? ?? 'unverified';

    if (canReceivePayments && verificationStatus == 'verified') {
      return Colors.green;
    } else if (canReceivePayments) {
      return const Color(0xFFFFA500);
    } else {
      return Colors.red;
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        // 1. Call backend API logout
        await AuthApi.logout();
      } catch (e) {
        print('Backend logout failed: $e');
      }

      try {
        // 2. Clear Google login credentials
        await GoogleAuthService.signOut();
        print('Google login credentials cleared');
      } catch (e) {
        print('Google sign out failed: $e');
      }

      try {
        // 3. Disconnect chat connection
        ChatWebSocketService.instance.disconnect();
        print('Chat connection disconnected');
      } catch (e) {
        print('Chat disconnect failed: $e');
      }

      try {
        // 4. Clear local authentication state
        await authStore.reset();
        print('Local authentication state cleared');
      } catch (e) {
        print('Local auth reset failed: $e');
      }

      if (mounted) {
        // Clear all route stack and navigate to home
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    }
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFFFFA500)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFFFFA500),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? const Color(0xFF1A1C1E),
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8B8B8B),
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing:
            trailing ??
            const Icon(Icons.chevron_right, color: Color(0xFF8B8B8B), size: 20),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1A1C1E),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 18,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Account settings section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Account',
                      style: TextStyle(
                        color: const Color(0xFF8B8B8B),
                        fontSize: 12,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Payment account setup option
                  _buildSettingItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Payment Account',
                    subtitle: _getStripeAccountStatusText(),
                    iconColor: const Color(0xFFFFA500),
                    trailing: _isLoadingStripeAccount
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getStripeAccountStatusColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Color(0xFF8B8B8B),
                                  size: 18,
                                ),
                                onPressed: _loadStripeAccountInfo,
                                tooltip: 'Refresh account status',
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF8B8B8B),
                                size: 20,
                              ),
                            ],
                          ),
                    onTap: _isLoadingStripeAccount
                        ? null
                        : _handleStripeAccountSetup,
                  ),

                  const SizedBox(height: 8),

                  // Logout option
                  _buildSettingItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of current account',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    trailing: _isLoggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.red,
                            size: 20,
                          ),
                    onTap: _isLoggingOut ? null : _logout,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom version information
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'ReFlip',
                    style: TextStyle(
                      color: const Color(0xFF8B8B8B),
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: const Color(0xFF8B8B8B),
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
