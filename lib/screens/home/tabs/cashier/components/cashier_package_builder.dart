
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_cart_header.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_grid_product_item.dart';

class CashierPackageBuilder extends StatefulWidget {
  const CashierPackageBuilder({
    Key? key,
    required this.package,
    required this.products,
    required this.addPackageToCart,
    required this.removePackageFromCart,
    this.packageIndexInCart = -1,
  }) : super(key: key);

  final PackagedProduct package;
  final List<Product> products;
  final void Function(PackagedProduct) addPackageToCart;
  final void Function(PackagedProduct, int) removePackageFromCart;
  final int packageIndexInCart;

  @override
  State<CashierPackageBuilder> createState() => _CashierPackageBuilderState();
}

class _CashierPackageBuilderState extends State<CashierPackageBuilder> {
  late PackagedProduct _currentPackage;
  final TextEditingController _quantityController = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    _currentPackage = widget.package;
    _calculatePackagePrice(); // Calculate initial price
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _currentPackage.clear();
    super.dispose();
  }

  void _removeProductFromPackage(Product productToRemove, int index) {
    setState(() {
      _currentPackage.removeProduct(index);
      // Find the original product in the available products list and restore its quantity
      final originalProduct = widget.products.firstWhere((p) => p.id == productToRemove.id);
      originalProduct.quantity += productToRemove.quantity;
      _calculatePackagePrice();
    });
  }

  void _calculatePackagePrice() {
    setState(() {
      _currentPackage.price = _currentPackage.productsList.fold(
        0,
        (previousValue, element) => previousValue + element.totalPrice,
      );
    });
  }

  void _addProductToPackage(Product product) {
    final int quantityToAdd = int.tryParse(_quantityController.text) ?? 1;

    if (quantityToAdd <= 0) {
      Fluttertoast.showToast(msg: "Quantity to add must be greater than 0.");
      return;
    }

    final int currentPackageQuantity = _currentPackage.productsList.fold(
      0,
      (previousValue, element) => previousValue + element.quantity,
    );

    if (currentPackageQuantity + quantityToAdd > _currentPackage.quantity) {
      Fluttertoast.showToast(
        msg: "Adding $quantityToAdd items would exceed the package limit of ${_currentPackage.quantity} items.",
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    if (product.quantity < quantityToAdd) {
      Fluttertoast.showToast(
        msg: "Insufficient stock for ${product.name}. Available: ${product.quantity}",
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    setState(() {
      // Decrease stock of the original product
      product.quantity -= quantityToAdd;

      // Create a new product instance for the package with the selected quantity
      final newProductInPackage = Product(
        id: product.id,
        name: product.name,
        category: product.category,
        unitPrice: product.unitPrice,
        quantity: quantityToAdd,
        totalPrice: product.unitPrice * quantityToAdd,
        image: product.image,
      );
      _currentPackage.addProduct(newProductInPackage);
      _calculatePackagePrice();
    });
  }

  Future<void> _showRemoveProductDialog(Product product, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove from Package"),
          content: Text("Are you sure you want to remove ${product.name} from this package?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeProductFromPackage(product, index);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }

  void _closeDialog() {
    final int packageQuantity = _currentPackage.productsList.fold(
      0,
      (previousValue, element) => previousValue + element.quantity,
    );

    if (packageQuantity == _currentPackage.quantity) {
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(
        msg: "Package items (${packageQuantity}) do not match the required quantity (${_currentPackage.quantity}).",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900; // Define a breakpoint for large screens

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? 1200 : screenWidth * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Build Package: ${_currentPackage.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: _closeDialog,
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Flex(
                direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
                children: [
                  // Left Panel: Product Selection Grid
                  Expanded(
                    flex: isLargeScreen ? 2 : 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Items (Required: ${_currentPackage.quantity - _currentPackage.productsList.fold(0, (prev, curr) => prev + curr.quantity)} more)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    labelText: "Qty to Add",
                                    hintText: "1",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onChanged: (value) {
                                    // Optional: Add validation or update UI based on quantity
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Add a search bar here if needed
                              // Expanded(
                              //   child: TextField(
                              //     decoration: InputDecoration(
                              //       labelText: 'Search Products',
                              //       prefixIcon: Icon(Icons.search),
                              //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200, // Max width for each product item
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75, // Adjust aspect ratio for better fit
                              ),
                              itemCount: widget.products.length,
                              itemBuilder: (context, index) {
                                final product = widget.products[index];
                                return CashierGridProductItem(
                                  product: product,
                                  addToCart: _addProductToPackage,
                                  quantity: int.tryParse(_quantityController.text) ?? 1,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right Panel: Package Summary
                  Expanded(
                    flex: isLargeScreen ? 1 : 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: isLargeScreen
                            ? const BorderRadius.horizontal(right: Radius.circular(16))
                            : const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Package Items',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          const CartHeader(), // Reusing CartHeader for column titles
                          Expanded(
                            child: _currentPackage.productsList.isEmpty
                                ? Center(
                                    child: Text(
                                      'No items added to package yet.',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _currentPackage.productsList.length,
                                    itemBuilder: (context, index) {
                                      final product = _currentPackage.productsList[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                NumberFormat.currency(symbol: "₱").format(product.unitPrice),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                product.quantity.toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                NumberFormat.currency(symbol: '₱').format(product.totalPrice),
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                              onPressed: () => _showRemoveProductDialog(product, index),
                                              tooltip: 'Remove item',
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Package Price:',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  NumberFormat.currency(symbol: '₱').format(_currentPackage.price),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    // Restore quantities of products in the original list
                                    for (var itemInPackage in _currentPackage.productsList) {
                                      final originalProduct = widget.products.firstWhere((p) => p.id == itemInPackage.id);
                                      originalProduct.quantity += itemInPackage.quantity;
                                    }
                                    _currentPackage.clear();
                                    _calculatePackagePrice();
                                  });
                                },
                                child: const Text("Clear Package"),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    final int packageQuantity = _currentPackage.productsList.fold(
                                      0,
                                      (previousValue, element) => previousValue + element.quantity,
                                    );
                                    if (_currentPackage.quantity != packageQuantity) {
                                      Fluttertoast.showToast(
                                        msg: "Package requires ${_currentPackage.quantity} items, but has $packageQuantity.",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        backgroundColor: Colors.orangeAccent,
                                        textColor: Colors.white,
                                      );
                                      return;
                                    }
                                    widget.addPackageToCart(_currentPackage);
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.add_shopping_cart),
                                  label: const Text("Add to Cart"),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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