import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/sale.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/cashier/components/dialogs/cash_payment_dialog.dart';
import 'package:mpos/screens/home/tabs/cashier/components/dialogs/other_payment_dialog.dart';
import 'package:mpos/screens/home/tabs/cashier/components/dialogs/transaction_complete_dialog.dart';
import 'package:mpos/services/shared_preferences_service.dart';

class Cart extends StatefulWidget {
  const Cart({
    Key? key,
    required this.rootContext,
    required this.cartList,
    required this.cartPackageList,
    required this.total,
    required this.discount,
    required this.voidCart,
    required this.currentAccount,
    required this.clearCart,
    required this.appliedDiscountList,
    required this.discountList,
    required this.selectedDiscount,
    required this.showDiscountsDialog,
    required this.addPackageToCart,
    required this.removePackageFromCart,
    required this.removeProductFromCart,
    required this.calculateTotal,
    required this.products,
  }) : super(key: key);

  final BuildContext rootContext;
  final List<Product> products;
  final List<Product> cartList;
  final List<PackagedProduct> cartPackageList;
  final int total;
  final double discount;
  final void Function() voidCart;
  final Account? currentAccount;
  final void Function() clearCart;
  final void Function() showDiscountsDialog;
  final List<Discount> appliedDiscountList;
  final List<Discount> discountList;
  final String selectedDiscount;
  final void Function(PackagedProduct) addPackageToCart;
  final void Function(PackagedProduct, int) removePackageFromCart;
  final void Function(Product, int) removeProductFromCart;
  final void Function() calculateTotal;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  int _transactionID = 0;
  String _paymentMethod = 'Cash';
  TextEditingController cashController = TextEditingController();
  TextEditingController referenceController = TextEditingController();
  int _change = 0;
  // Transaction? _createdTransaction;
  late Sale? _createdSale;

  @override
  void initState() {
    super.initState();
    initializeTransactionID();
  }

  Widget _buildProductItem(Product product, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showRemoveProductDialog(product, index),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Product Details
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unit: ${NumberFormat.currency(symbol: '₱').format(product.unitPrice)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quantity
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'x${product.quantity}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Total Price
              Text(
                NumberFormat.currency(symbol: '₱').format(product.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageItem(PackagedProduct package, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          showRemovePackageDialog(package, index);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  // Package Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Package Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PACKAGE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'x${package.quantity}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Package Price
                  Text(
                    NumberFormat.currency(symbol: '₱').format(package.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              
              // Package Items
              if (package.productsList.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: package.productsList.map((product) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Text(
                              'x${product.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              NumberFormat.currency(symbol: '₱').format(product.totalPrice),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Cart is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Sub-Total', widget.total.toDouble()),
          const SizedBox(height: 8),
          _buildSummaryRow('Discount', widget.discount, isDiscount: true),
          const Divider(height: 20),
          _buildSummaryRow(
            'Total',
            widget.total - widget.discount,
            isTotal: true,
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${NumberFormat.currency(symbol: '₱').format(amount)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal 
                ? Theme.of(context).primaryColor 
                : isDiscount 
                    ? Colors.red 
                    : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.voidCart,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Void'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (posTier != "FREE_TRIAL") ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.showDiscountsDialog,
              icon: const Icon(Icons.local_offer_outlined, size: 18),
              label: const Text('Discounts'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: showPaymentMethodDialog,
            icon: const Icon(Icons.payment, size: 18),
            label: const Text('Pay Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernPaymentDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Payment Methods Grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildPaymentMethodCard(
                  'Cash',
                  Icons.money,
                  Colors.green,
                  () => showCashPaymentDialog(context: context),
                ),
                _buildPaymentMethodCard(
                  'GCash',
                  Icons.phone_android,
                  Colors.blue,
                  () => showOtherPaymentDialog(paymentMethod: 'GCash', context: context),
                ),
                _buildPaymentMethodCard(
                  'Foodpanda',
                  Icons.delivery_dining,
                  Colors.pink,
                  () => showOtherPaymentDialog(paymentMethod: 'Foodpanda', context: context),
                ),
                _buildPaymentMethodCard(
                  'Grab',
                  Icons.local_taxi,
                  Colors.green[700]!,
                  () => showOtherPaymentDialog(paymentMethod: 'Grab', context: context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep existing methods but update showPaymentMethodDialog
  Future<void> showPaymentMethodDialog() async {
    if (widget.cartList.isEmpty && widget.cartPackageList.isEmpty) {
      Fluttertoast.showToast(msg: "Cart is empty!");
      return;
    }
    
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _buildModernPaymentDialog(),
    );
  }

  // Keep all existing methods (initializeTransactionID, calculateChange, etc.)
  void initializeTransactionID() {
    final all = objectBox.transactionBox.query()
      ..order(Transaction_.id, flags: Order.descending);
    final allBuilder = all.build();
    allBuilder.limit = 1;
    setState(() {
      if (allBuilder.find().isEmpty) {
        _transactionID = 1;
        return;
      }
      _transactionID = allBuilder.find()[0].transactionID + 1;
    });
  }

  void calculateChange(String str) {
    if (cashController.text.isEmpty) return;
    _change = int.parse(cashController.text) - (widget.total - widget.discount.toInt());
    setState(() {});
  }

  void cancelPayment() {
    cashController.text = widget.total.toString();
    calculateChange('');
  }

  Future<void> showCashPaymentDialog({
    required BuildContext context,
  }) async {

    if (context.mounted) Navigator.of(context).pop(); // This might pop the wrong dialog if not careful

    setState(() {
      _paymentMethod = "Cash";
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) { // Use dialogContext to avoid confusion
        return CashPaymentDialog(
          totalAmount: widget.total.toDouble(),
          discountAmount: widget.discount,
          onPay: pay,
          onCancel: cancelPayment,
          cashController: cashController,
        );
      },
    );
  }

  // This is your original function, now calling the new dialog widget
  Future<void> showOtherPaymentDialog({
    required BuildContext context,
    required String paymentMethod,
  }) async {
    // Ensure context is still valid before popping
    if (context.mounted)Navigator.of(context).pop(); // This might pop the wrong dialog if not careful

    cashController.text = ""; 
    setState(() {
      _paymentMethod = paymentMethod;
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) { // Use dialogContext to avoid confusion
        return OtherPaymentDialog(
          paymentMethod: paymentMethod,
          totalAmount: widget.total.toDouble(),
          discountAmount: widget.discount.toDouble(),
          onPay: pay,
          onCancel: cancelPayment,
          referenceController: referenceController,
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(widget.rootContext).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> pay() async {
    final employeeId = await SharedPreferencesService.get('employee_id');
    final employeeName = await SharedPreferencesService.get('employee_name');
    if (employeeName == null || employeeId == null) {
      _showSnackBar("Cashier not found. Please select a cashier first", isError: true);
      return;
    }
    final now = DateTime.now();

    final Sale newSale = Sale(
      transactionID: _transactionID,
      employeeId: employeeId, // implement later
      employeeName: employeeName, // e.g., passed as a string to this widget
      discount: widget.discount.toInt(),
      subTotal: widget.total,
      totalAmount: widget.total - widget.discount.toInt(),
      date: DateTime.parse(DateFormat('yyyy-MM-dd').format(now)),
      time: now,
      payment: _paymentMethod == "Cash"
          ? int.parse(cashController.text)
          : widget.total - widget.discount.toInt(),
      change: _paymentMethod == "Cash" ? _change : 0,
      paymentMethod: _paymentMethod,
      referenceNumber: referenceController.text,
      productsJson: jsonEncode(widget.cartList),
      packagesJson: jsonEncode(widget.cartPackageList),
    );

    for (var product in widget.cartList) {
      final updateProduct = objectBox.productBox.get(product.id);
      if (updateProduct != null) {
        if (updateProduct.withVariant) {
          final variantName = product.name.split("---").last;
          final updateVariant = updateProduct.variants
              .firstWhere((v) => v.name == variantName);
          updateVariant.quantity -= product.quantity;
          updateVariant.totalPrice = updateVariant.quantity * updateVariant.unitPrice;
          objectBox.productVariantBox.put(updateVariant);
        }

        updateProduct.quantity -= product.quantity;
        updateProduct.totalPrice = updateProduct.quantity * product.unitPrice;
        objectBox.productBox.put(updateProduct);
      }
    }

    for (var package in widget.cartPackageList) {
      for (var product in package.productsList) {
        final updateProduct = objectBox.productBox.get(product.id);
        if (updateProduct != null) {
          updateProduct.quantity -= product.quantity;
          updateProduct.totalPrice = updateProduct.quantity * product.unitPrice;
          objectBox.productBox.put(updateProduct);
        }
      }
    }

    objectBox.saleBox.put(newSale);
    // _createdTransaction = newSale; // Optional: rename this var to _createdSale
    _createdSale = newSale;

    if (mounted) {
      Navigator.of(context).pop();
      showTransactionCompleteDialog(context: context);
    }
    setState(() {});
  }

  Future<void> showTransactionCompleteDialog({
    required BuildContext context,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Usually not dismissible by tapping outside for confirmation dialogs
      builder: (BuildContext dialogContext) {
        return TransactionCompleteDialog(
          onPrintReceipt: () async {
            if (_createdSale != null) {
              // await printReceipt(_createdSale);
            } else {
              Fluttertoast.showToast(msg: "No transaction data available to print receipt.");
            }
          },
          onOkay: () {
            Navigator.of(dialogContext).pop(); // Use dialogContext to pop this specific dialog
            widget.clearCart();
            _createdSale = null; // This state update should be handled by the parent
            referenceController.text = "";
            initializeTransactionID();
            Fluttertoast.showToast(msg: "Transaction Complete"); // This toast might be redundant if the dialog itself is the confirmation
          },
        );
      },
    );
  }
    
  Future<void> showRemoveProductDialog(Product product, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Remove from Cart"),
          content: Text("Are you sure you want to remove ${product.name} from cart?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                widget.removeProductFromCart(product, index);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Remove", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> showRemovePackageDialog(PackagedProduct package, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Remove from Cart"),
          content: Text("Are you sure you want to remove ${package.name} from cart?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                widget.removePackageFromCart(package, index);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Remove", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Keep other existing methods...

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.cartList.isNotEmpty || widget.cartPackageList.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Cart (${widget.cartList.length + widget.cartPackageList.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Cart Items
          Expanded(
            child: hasItems
                ? ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      ...widget.cartPackageList.asMap().entries.map(
                        (e) => _buildPackageItem(e.value, e.key),
                      ),
                      ...widget.cartList.asMap().entries.map(
                        (e) => _buildProductItem(e.value, e.key),
                      ),
                    ],
                  )
                : _buildEmptyCart(),
          ),
          
          // Cart Summary
          if (hasItems) _buildCartSummary(),
        ],
      ),
    );
  }
}