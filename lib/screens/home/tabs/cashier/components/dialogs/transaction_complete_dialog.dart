
import 'package:flutter/material.dart';

class TransactionCompleteDialog extends StatelessWidget {
  final VoidCallback onPrintReceipt;
  final VoidCallback onOkay;

  const TransactionCompleteDialog({
    Key? key,
    required this.onPrintReceipt,
    required this.onOkay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450), // Max width for a compact dialog
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Success Icon
              Icon(
                Icons.check_circle_rounded, // A slightly more modern check icon
                size: 90, // Larger icon for emphasis
                color: Colors.green.shade600, // A slightly darker green for better contrast
              ),
              const SizedBox(height: 20), // Increased vertical spacing
              // Main Message
              Text(
                'Transaction Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subtitle/Confirmation Message
              Text(
                'Thank you for your purchase. The transaction has been successfully processed.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32), // More space before buttons
              // Action Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity, // Make button full width
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print_rounded), // Modern print icon
                      label: const Text('Print Receipt'),
                      onPressed: onPrintReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor, // Primary color for main action
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4, // Add some elevation
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Spacing between buttons
                  SizedBox(
                    width: double.infinity, // Make button full width
                    child: OutlinedButton.icon( // Changed to OutlinedButton for secondary action
                      icon: const Icon(Icons.done_all_rounded), // A more conclusive 'done' icon
                      label: const Text('Done'), // Changed 'Okay' to 'Done'
                      onPressed: onOkay,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
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

