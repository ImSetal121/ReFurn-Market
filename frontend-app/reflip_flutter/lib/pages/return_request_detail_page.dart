import 'package:flutter/material.dart';
import '../api/seller_api.dart';
import '../widgets/ios_keyboard_toolbar.dart';

class ReturnRequestDetailPage extends StatefulWidget {
  final String sellRecordId;

  const ReturnRequestDetailPage({Key? key, required this.sellRecordId})
    : super(key: key);

  @override
  State<ReturnRequestDetailPage> createState() =>
      _ReturnRequestDetailPageState();
}

class _ReturnRequestDetailPageState extends State<ReturnRequestDetailPage> {
  final TextEditingController _sellerOpinionController =
      TextEditingController();
  final FocusNode _sellerOpinionFocusNode = FocusNode();

  Map<String, dynamic>? _returnRequestData;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReturnRequestDetail();
  }

  @override
  void dispose() {
    _sellerOpinionController.dispose();
    _sellerOpinionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadReturnRequestDetail() async {
    setState(() => _isLoading = true);

    try {
      final data = await SellerApi.getReturnRequestDetail(widget.sellRecordId);
      if (data != null) {
        setState(() {
          _returnRequestData = data;
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Failed to load return request details');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFA500),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReturnReasonSection(),
                          const SizedBox(height: 24),
                          _buildSellerOpinionSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
            if (!_isLoading) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                'Return Request',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildReturnReasonSection() {
    final returnReason = _returnRequestData?['returnReasonType'] ?? '';
    final returnDetail = _returnRequestData?['returnReasonDetail'] ?? '';
    final productName =
        _returnRequestData?['product']?['name'] ?? 'Unknown Product';
    final orderId =
        _returnRequestData?['productSellRecordId']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Return Request Details',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // 商品信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product: ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  productName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 订单号
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order ID: ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  orderId,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 退货原因类型
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reason: ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  _getReasonDisplayText(returnReason),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 详细说明
          const Text(
            'Detailed Description:',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              returnDetail.isEmpty
                  ? 'No additional details provided'
                  : returnDetail,
              style: TextStyle(
                color: returnDetail.isEmpty ? Colors.grey : Colors.black,
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerOpinionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seller Response',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please provide your opinion on this return request',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 140),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: KeyboardToolbarBuilder.buildSingle(
            textField: TextField(
              controller: _sellerOpinionController,
              focusNode: _sellerOpinionFocusNode,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Enter your response to the return request...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
            focusNode: _sellerOpinionFocusNode,
            doneButtonText: 'Done',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 拒绝退货按钮
            Expanded(
              child: GestureDetector(
                onTap: _isSubmitting
                    ? null
                    : () => _handleReturnDecision(false),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isSubmitting
                        ? Colors.grey[300]
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSubmitting ? Colors.grey[300]! : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Reject Return',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 同意退货按钮
            Expanded(
              child: GestureDetector(
                onTap: _isSubmitting ? null : () => _handleReturnDecision(true),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _isSubmitting
                        ? const LinearGradient(
                            colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)],
                          )
                        : const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFFFA500), Color(0xFFFFB631)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Accept Return',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReasonDisplayText(String reason) {
    switch (reason) {
      case 'DAMAGED':
        return 'Product Damaged';
      case 'NOT_AS_DESCRIBED':
        return 'Not as Described';
      case 'WRONG_SIZE':
        return 'Wrong Size';
      case 'CHANGED_MIND':
        return 'Changed Mind';
      case 'QUALITY_ISSUE':
        return 'Quality Issue';
      case 'LATE_DELIVERY':
        return 'Late Delivery';
      case 'OTHER':
        return 'Other';
      default:
        return reason;
    }
  }

  Future<void> _handleReturnDecision(bool accept) async {
    if (_isSubmitting) return;

    // 如果同意退货，检查是否填写了意见
    if (accept && _sellerOpinionController.text.trim().isEmpty) {
      _showErrorDialog('Please provide your opinion on the return request');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await SellerApi.handleReturnRequest(
        sellRecordId: widget.sellRecordId,
        accept: accept,
        sellerOpinion: _sellerOpinionController.text.trim(),
      );

      if (success) {
        _showSuccessDialog(accept);
      } else {
        _showErrorDialog('Failed to process return request. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog(bool accepted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(
            accepted
                ? 'Return request has been accepted successfully.'
                : 'Return request has been rejected successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                Navigator.of(context).pop(true); // 返回到销售页面，传递刷新标志
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
