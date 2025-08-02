import 'package:flutter/material.dart';
import 'package:mpos/main.dart';

class AddOptionDialog extends StatefulWidget {
  const AddOptionDialog({
    Key? key,
    required this.navigateToAddProductScreen,
    required this.navigateToAddPackageScreen,
  }) : super(key: key);

  final VoidCallback navigateToAddProductScreen;
  final VoidCallback navigateToAddPackageScreen;

  @override
  State<AddOptionDialog> createState() => _AddOptionDialogState();
}

class _AddOptionDialogState extends State<AddOptionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600), // Max width for larger screens
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Choose what to add',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Options Grid/Row
            LayoutBuilder(
              builder: (context, constraints) {
                // Adjust layout based on available width
                if (constraints.maxWidth > 400 && posTier != "FREE_TRIAL" && posTier != "BASIC") {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          icon: Icons.fastfood,
                          title: 'Product',
                          description: '(e.g., Donuts, Cakes)',
                          onTap: widget.navigateToAddProductScreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOptionCard(
                          icon: Icons.inventory_2,
                          title: 'Packaged Product',
                          description: '(e.g., Box of 3 Donuts)',
                          onTap: widget.navigateToAddPackageScreen,
                        ),
                      ),
                    ],
                  );
                } else {
                  // Stack vertically on smaller screens or if only one option
                  return Column(
                    children: [
                      _buildOptionCard(
                        icon: Icons.fastfood,
                        title: 'Product',
                        description: '(e.g., Donuts, Cakes)',
                        onTap: widget.navigateToAddProductScreen,
                      ),
                      if (posTier != "FREE_TRIAL" && posTier != "BASIC") ...[
                        const SizedBox(height: 16),
                        _buildOptionCard(
                          icon: Icons.inventory_2,
                          title: 'Packaged Product',
                          description: '(e.g., Box of 3 Donuts)',
                          onTap: widget.navigateToAddPackageScreen,
                        ),
                      ],
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Close Button
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
