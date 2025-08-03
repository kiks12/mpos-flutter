
// import 'dart:io';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_package_builder.dart';

class CashierGridPackageItem extends StatefulWidget {
  const CashierGridPackageItem({
    Key? key,
    required this.package,
    required this.products,
    required this.addPackageToCart,
  }) : super(key: key);

  final PackagedProduct package;
  final List<Product> products;
  final void Function(PackagedProduct) addPackageToCart;

  @override
  State<CashierGridPackageItem> createState() => _CashierGridPackageItemState();
}

class _CashierGridPackageItemState extends State<CashierGridPackageItem> {
  Future<void> _openPackageBuilder() async {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        // Filter products based on package category (assuming category contains product names)
        // This logic might need adjustment based on your actual data structure
        final relevantProducts = widget.products
            .where((element) => widget.package.category.toLowerCase().contains(element.name.toLowerCase()))
            .toList();

        return CashierPackageBuilder(
          products: relevantProducts,
          package: widget.package,
          addPackageToCart: widget.addPackageToCart,
          removePackageFromCart: (package, index) {}, // Placeholder for remove functionality
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1, // Standard elevation for a distinct card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1.5), // Highlight packages
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
      child: InkWell(
        onTap: _openPackageBuilder,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
              children: [
                // Package Image / Placeholder
                Expanded(
                  flex: 3, // Takes more space for the image
                  child: Container(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Light background for image area
                    child: widget.package.image != null && File(widget.package.image!).existsSync()
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.file(
                              File(widget.package.image!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.collections_bookmark_outlined, // Package specific icon
                                size: 60,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.collections_bookmark_outlined, // Package specific icon
                            size: 60,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          ),
                  ),
                ),
                // Package Details (Name & Price)
                Expanded(
                  flex: 2, // Less space for text details
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.package.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(symbol: "₱").format(widget.package.price),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // "Package" Badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Package',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}