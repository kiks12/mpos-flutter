
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class OtherPaymentDialog extends StatefulWidget {
  final TextEditingController referenceController;
  final String paymentMethod;
  final double totalAmount;
  final double discountAmount;
  final VoidCallback onPay;
  final VoidCallback onCancel;
  // final Future<void> Function(dynamic) printReceipt; // Assuming printReceipt takes a transaction object

  const OtherPaymentDialog({
    Key? key,
    required this.paymentMethod,
    required this.totalAmount,
    required this.discountAmount,
    required this.referenceController,
    required this.onPay,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<OtherPaymentDialog> createState() => _OtherPaymentDialogState();
}

class _OtherPaymentDialogState extends State<OtherPaymentDialog> {

  @override
  void dispose() {
    widget.referenceController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final netTotal = widget.totalAmount - widget.discountAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500), // Max width for the dialog
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.paymentMethod} Payment',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
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
              // Reference Number Input
              TextFormField(
                controller: widget.referenceController,
                decoration: InputDecoration(
                  labelText: 'Reference Number',
                  hintText: 'Enter transaction ID or reference',
                  labelStyle: Theme.of(context).textTheme.titleMedium,
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => widget.onPay(), // Trigger pay on done
              ),
              const SizedBox(height: 32),
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
                    onPressed: () {
                      if (widget.referenceController.text.trim().isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter a reference number.");
                        return;
                      }
                      widget.onPay();
                    },
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
}
