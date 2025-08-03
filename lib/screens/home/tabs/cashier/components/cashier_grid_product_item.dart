
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_variant_selector.dart';

class CashierGridProductItem extends StatefulWidget {
  const CashierGridProductItem({
    Key? key,
    required this.product,
    required this.addToCart,
    required this.quantity,
  }) : super(key: key);

  final Product product;
  final void Function(Product) addToCart;
  final int quantity; // This seems to be the quantity in cart, not product stock

  @override
  State<CashierGridProductItem> createState() => _CashierGridProductItemState();
}

class _CashierGridProductItemState extends State<CashierGridProductItem> {
  @override
  void dispose() {
    super.dispose();
  }

  void _addToCart() {
    // Check if product stock is sufficient for adding one more item
    if (widget.product.quantity > 0) { // Assuming quantity is the available stock
      widget.addToCart(widget.product);
      Fluttertoast.showToast(msg: "${widget.product.name} added to cart!");
    } else {
      _showInsufficientStockToast();
    }
  }

  void _showInsufficientStockToast() {
    Fluttertoast.showToast(
      msg: "Insufficient stock for ${widget.product.name}.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _productItemOnTap() {
    if (widget.product.quantity == 0) {
      _showInsufficientStockToast();
      return;
    }

    if (widget.product.withVariant) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CashierVariantSelector(
            product: widget.product,
            addToCart: widget.addToCart,
            quantity: widget.quantity, // Pass current cart quantity if needed
          );
        },
      );
    } else {
      _addToCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = widget.product.quantity == 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOutOfStock ? BorderSide(color: Colors.red.shade200, width: 1) : BorderSide.none,
      ),
      color: Colors.white, 
      clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
      child: InkWell(
        onTap: _productItemOnTap,
        borderRadius: BorderRadius.circular(12),
        // Apply a visual filter if out of stock
        child: ColorFiltered(
          colorFilter: isOutOfStock
              ? ColorFilter.mode(Colors.grey.withOpacity(0.6), BlendMode.saturation)
              : const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
                children: [
                  // Product Image / Placeholder
                  Expanded(
                    flex: 3, // Takes more space for the image
                    child: Container(
                      color: Colors.grey[100], // Light background for image area
                      child: widget.product.image != null && File(widget.product.image!).existsSync()
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.file(
                                File(widget.product.image!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  // Product Details (Name & Price)
                  Expanded(
                    flex: 2, // Less space for text details
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.product.name,
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
                            NumberFormat.currency(symbol: "₱").format(widget.product.unitPrice),
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
              // Out of Stock Overlay
              if (isOutOfStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // Darker overlay
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.do_not_disturb_alt, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          const Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Variant Indicator
              if (widget.product.withVariant && !isOutOfStock)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune, // Or Icons.category, Icons.layers
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}