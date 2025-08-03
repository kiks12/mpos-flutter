import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashPaymentDialog extends StatefulWidget {
  final double totalAmount;
  final double discountAmount;
  final TextEditingController cashController;
  final VoidCallback onPay;
  final VoidCallback onCancel;

  const CashPaymentDialog({
    Key? key,
    required this.totalAmount,
    required this.discountAmount,
    required this.onPay,
    required this.onCancel,
    required this.cashController,
  }) : super(key: key);

  @override
  State<CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<CashPaymentDialog> {
  double _change = 0.0;

  @override
  void initState() {
    super.initState();
    widget.cashController.addListener(_calculateChange);
  }

  @override
  void dispose() {
    widget.cashController.removeListener(_calculateChange);
    widget.cashController.clear();
    super.dispose();
  }

  void _calculateChange() {
    final cashInput = double.tryParse(widget.cashController.text) ?? 0.0;
    final netTotal = widget.totalAmount - widget.discountAmount;
    setState(() {
      _change = cashInput - netTotal;
    });
  }

  void _onKeypadTap(String value) {
    String currentText = widget.cashController.text;
    if (value == 'C') {
      currentText = '';
    } else if (value == 'DEL') {
      if (currentText.isNotEmpty) {
        currentText = currentText.substring(0, currentText.length - 1);
      }
    } else if (value == '00') {
      currentText += '00';
    } else if (value == '.') {
      if (!currentText.contains('.')) {
        currentText += '.';
      }
    } else {
      currentText += value;
    }

    // Ensure only one decimal point and valid number format
    if (currentText.startsWith('.')) {
      currentText = '0$currentText';
    }
    if (currentText.contains('.') && currentText.split('.').last.length > 2) {
      // Prevent more than 2 decimal places
      return;
    }

    widget.cashController.text = currentText;
    widget.cashController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.cashController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final netTotal = widget.totalAmount - widget.discountAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600), // Max width for the dialog
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cash Payment',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              // Total Amount Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '₱').format(netTotal),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Cash Received Input
              TextFormField(
                controller: widget.cashController,
                keyboardType: TextInputType.none, // Disable native keyboard
                readOnly: true, // Make it read-only to use custom keypad
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Cash Received',
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
              ),
              const SizedBox(height: 24),
              // Change Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '₱').format(_change),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _change >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Numeric Keypad
              _buildNumericKeypad(),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onCancel();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  // Print Receipt Button (uncomment if needed)
                  // FilledButton.tonal(
                  //   onPressed: () async {
                  //     if (_createdTransaction != null) {
                  //       await widget.printReceipt(_createdTransaction!);
                  //     } else {
                  //       Fluttertoast.showToast(msg: "No transaction to print receipt for.");
                  //     }
                  //   },
                  //   child: const Text('Print Receipt'),
                  // ),
                  // const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _change >= 0 ? () {
                      widget.onPay();
                    } : null, // Disable if change is negative
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text('Pay'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    final List<String> keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '.', '0', '00',
      'C', 'DEL', // Clear and Delete
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.7, // Adjust button size
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        Color buttonColor = Colors.grey.shade200;
        Color textColor = Colors.black87;
        IconData? icon;

        if (key == 'C') {
          buttonColor = Colors.red.shade100;
          textColor = Colors.red.shade700;
          icon = Icons.clear_all;
        } else if (key == 'DEL') {
          buttonColor = Colors.orange.shade100;
          textColor = Colors.orange.shade700;
          icon = Icons.backspace_outlined;
        } else if (key == '.') {
          buttonColor = Theme.of(context).primaryColor.withOpacity(0.1);
          textColor = Theme.of(context).primaryColor;
        }

        return ElevatedButton(
          onPressed: () => _onKeypadTap(key),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          child: icon != null ? Icon(icon, size: 28) : Text(key),
        );
      },
    );
  }
}