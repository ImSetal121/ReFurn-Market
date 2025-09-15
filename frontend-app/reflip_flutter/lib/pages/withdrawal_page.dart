import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/balance_api.dart';
import '../widgets/ios_keyboard_toolbar.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({Key? key}) : super(key: key);

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  double _currentBalance = 0.0;
  bool _isLoading = false;
  bool _isWithdrawing = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentBalance();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  // 加载当前余额
  Future<void> _loadCurrentBalance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final balance = await BalanceApi.getCurrentBalance();
      if (mounted) {
        setState(() {
          _currentBalance = balance ?? 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load balance: ${e.toString()}';
        });
      }
    }
  }

  // 检查提现条件
  Future<void> _checkWithdrawal() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter withdrawal amount';
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final checkResult = await BalanceApi.checkWithdrawEligibility(amount);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (checkResult?.eligible == true) {
          _showConfirmationDialog(amount);
        } else {
          setState(() {
            _errorMessage =
                checkResult?.errorMessage ?? 'Withdrawal not eligible';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to check withdrawal eligibility: ${e.toString()}';
        });
      }
    }
  }

  // 显示确认对话框
  void _showConfirmationDialog(double amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Withdrawal'),
          content: Text(
            'Are you sure you want to withdraw \$${amount.toStringAsFixed(2)}?\n\n'
            'The funds will be transferred to your Stripe account and should arrive in your bank account within 1-2 business days.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processWithdrawal(amount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  // 处理提现
  Future<void> _processWithdrawal(double amount) async {
    setState(() {
      _isWithdrawing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await BalanceApi.withdrawToStripe(amount);
      if (mounted) {
        setState(() {
          _isWithdrawing = false;
        });

        if (success == true) {
          setState(() {
            _successMessage =
                'Withdrawal successful! Funds will arrive in your bank account within 1-2 business days.';
            _amountController.clear();
          });
          // 重新加载余额
          _loadCurrentBalance();

          // 延迟返回钱包页面，让用户看到成功消息
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context, true); // 传递true表示需要刷新
            }
          });
        } else {
          setState(() {
            _errorMessage = 'Withdrawal failed. Please try again later.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWithdrawing = false;
          _errorMessage = 'Withdrawal failed: ${e.toString()}';
        });
      }
    }
  }

  // 设置最大金额
  void _setMaxAmount() {
    _amountController.text = _currentBalance.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // 顶部导航栏
          _buildHeader(),
          // 主要内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 余额卡片
                  _buildBalanceCard(),
                  const SizedBox(height: 32),
                  // 提现表单
                  _buildWithdrawalForm(),
                  const SizedBox(height: 24),
                  // 消息提示
                  if (_errorMessage != null) _buildErrorMessage(),
                  if (_successMessage != null) _buildSuccessMessage(),
                  const SizedBox(height: 32),
                  // 提现按钮
                  _buildWithdrawButton(),
                  const SizedBox(height: 24),
                  // 提示信息
                  _buildNotice(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 24,
                  height: 24,
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Withdrawal',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24), // 平衡布局
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _isLoading
              ? const CircularProgressIndicator()
              : Text(
                  '\$${_currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Withdrawal Amount',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // 金额输入框
          Container(
            constraints: const BoxConstraints(minHeight: 56, maxHeight: 56),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _amountFocusNode.hasFocus
                    ? const Color(0xFFFFA500)
                    : const Color(0xFFE8E8E8),
                width: 1,
              ),
            ),
            child: KeyboardToolbarBuilder.buildSingle(
              textField: TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                textInputAction: TextInputAction.done,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null;
                    _successMessage = null;
                  });
                },
              ),
              focusNode: _amountFocusNode,
              doneButtonText: 'Done',
            ),
          ),
          const SizedBox(height: 12),
          // 最大金额按钮
          GestureDetector(
            onTap: _setMaxAmount,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Max',
                style: TextStyle(
                  color: Color(0xFFFFA500),
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE53E3E), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFE53E3E),
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _successMessage!,
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return Container(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (_isLoading || _isWithdrawing) ? null : _checkWithdrawal,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isWithdrawing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Withdraw',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Withdrawal Notice',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Funds will be transferred to your connected Stripe account\n'
            '• Processing typically takes 1-2 business days\n'
            '• Make sure your Stripe account is active and can receive payments\n'
            '• Contact support if you encounter any issues',
            style: TextStyle(
              color: Color(0xFF8A8A8F),
              fontSize: 12,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
