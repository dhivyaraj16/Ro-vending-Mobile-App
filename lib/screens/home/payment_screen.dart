import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final ROmachine machine;
  const PaymentScreen({super.key, required this.machine});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double _selectedLitres = 5.0;
  String _selectedPayment = 'wallet';
  bool _isProcessing = false;
  final List<double> _quickLitres = [1, 2, 5, 10];

  double get _totalAmount =>
      _selectedLitres * widget.machine.pricePerLitre;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final user = context.watch<AuthProvider>().userModel;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Machine Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.water_drop,
                        color: AppTheme.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.machine.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.deepBlue)),
                        Text(
                          '₹${widget.machine.pricePerLitre}/L  •  ${widget.machine.address}',
                          style: const TextStyle(
                              color: AppTheme.textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Quantity
            const Text('Select Quantity',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepBlue)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _quickLitres.map((l) {
                final selected = _selectedLitres == l;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLitres = l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primaryBlue
                            : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text('${l.toInt()}L',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: selected ? Colors.white : AppTheme.deepBlue,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Slider
            const Text('Custom Quantity (Liters)',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepBlue)),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.primaryBlue,
                inactiveTrackColor: AppTheme.primaryBlue.withOpacity(0.2),
                thumbColor: AppTheme.primaryBlue,
                trackHeight: 4,
              ),
              child: Slider(
                value: _selectedLitres,
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (val) => setState(() => _selectedLitres = val),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('1L',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                Text(
                  '${_selectedLitres.toInt()}L',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text('20L',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text('Payment Method',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepBlue)),
            const SizedBox(height: 12),
            _paymentOption('wallet', Icons.account_balance_wallet,
                'RO Vending Wallet',
                'Balance: ₹${wallet.balance.toStringAsFixed(2)}',
                AppTheme.primaryBlue),
            const SizedBox(height: 8),
            _paymentOption('upi', Icons.phone_android,
                'UPI Payment', 'GPay, PhonePe, Paytm',
                const Color(0xFF5C6BC0)),
            const SizedBox(height: 8),
            _paymentOption('qr', Icons.qr_code_scanner,
                'QR Code Pay', 'Scan & Pay instantly',
                const Color(0xFF00897B)),
            const SizedBox(height: 8),
            _paymentOption('netbanking', Icons.account_balance,
                'Net Banking', 'SBI, HDFC, ICICI & more',
                const Color(0xFF1E88E5)),
            const SizedBox(height: 8),
            _paymentOption('card', Icons.credit_card,
                'Credit / Debit Card', 'Visa, Mastercard, RuPay',
                const Color(0xFFE53935)),
            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row('Quantity', '${_selectedLitres.toInt()} L'),
                  const SizedBox(height: 8),
                  _row('Price per Litre',
                      '₹${widget.machine.pricePerLitre}'),
                  const Divider(height: 20),
                  _row('Total Amount',
                      '₹${_totalAmount.toStringAsFixed(2)}',
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _handlePayment(context, user, wallet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Pay ₹${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 13, color: AppTheme.textGrey),
                SizedBox(width: 4),
                Text('100% Secure & Encrypted',
                    style:
                        TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String id, IconData icon, String title,
      String subtitle, Color color) {
    final isSelected = _selectedPayment == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textGrey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: isTotal ? AppTheme.deepBlue : AppTheme.textGrey,
              fontWeight:
                  isTotal ? FontWeight.w700 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            )),
        Text(value,
            style: TextStyle(
              color:
                  isTotal ? AppTheme.primaryBlue : AppTheme.deepBlue,
              fontWeight: FontWeight.w700,
              fontSize: isTotal ? 20 : 14,
            )),
      ],
    );
  }

  Future<void> _handlePayment(
      BuildContext context, user, WalletProvider wallet) async {
    if (_selectedPayment == 'wallet') {
      if (wallet.balance < _totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Insufficient wallet balance!'),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: 'Add Money',
              textColor: Colors.white,
              onPressed: () => context.push('/wallet/add-money'),
            ),
          ),
        );
        return;
      }
      setState(() => _isProcessing = true);
      final success = await wallet.deductForWater(
        userId: user!.uid,
        machineId: widget.machine.id,
        machineName: widget.machine.name,
        amount: _totalAmount,
        litres: _selectedLitres,
      );
      setState(() => _isProcessing = false);
      if (success && mounted) _showSuccess();
    } else {
      _showSimulateSheet();
    }
  }

  void _showSimulateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Icon(
              _selectedPayment == 'upi' ? Icons.phone_android
                  : _selectedPayment == 'qr' ? Icons.qr_code_2
                  : _selectedPayment == 'netbanking' ? Icons.account_balance
                  : Icons.credit_card,
              size: 52, color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 12),
            Text(
              'Amount: ₹${_totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Demo mode - Razorpay integrate பண்ணும்போது real payment ஆகும்',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simulate Payment ✓',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: AppTheme.success, shape: BoxShape.circle),
              child: const Icon(Icons.check,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Water Dispensing! 💧',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              '${_selectedLitres.toInt()}L from ${widget.machine.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '₹${_totalAmount.toStringAsFixed(2)} paid',
                style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue),
              child: const Text('Done',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}