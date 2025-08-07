// Updated CashierScreen with optimized discount system
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/managers/discount_manager.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_cart.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_grid.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_control_panel.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({Key? key}) : super(key: key);

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  List<Product> _productList = [];
  List<PackagedProduct> _packageList = [];
  List<String> _categoriesList = [];
  String _selectedCategory = "All";
  TextEditingController searchController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: '1');
  List<PackagedProduct> _cartPackageList = [];
  List<Product> _cartList = [];
  double _subtotal = 0.0;
  
  // Optimized discount management
  final DiscountManager _discountManager = DiscountManager();
  List<Discount> _availableDiscounts = [];
  String _selectedDiscount = "";
  
  Account? currentAccount;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    initializeCategories();
    _selectedCategory = "All";
    quantityController.text = "1";
    initializeDiscounts();
    initializeProductStream("All");
    initializePackageStream("All");
  }

  void initializeCategories() {
    _categoriesList = [];
    _categoriesList.add("All");
    final query = objectBox.productBox.query().build();
    PropertyQuery<String> pq = query.property(Product_.category);
    pq.distinct = true;
    pq.find().forEach((element) { _categoriesList.add(element); });
    setState(() {});
  }

  void initializeDiscounts() {
    _availableDiscounts = [];
    final query = objectBox.discountBox.query().build();
    query.find().forEach((element) { _availableDiscounts.add(element); });
    if (_availableDiscounts.isNotEmpty) _selectedDiscount = _availableDiscounts[0].title;
    setState(() {});
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    initializeProductStream(category);
    initializePackageStream(category);
    setState(() {});
  }

  void initializeProductStream(String category) {
    if (category == "All") {
      _productList = objectBox.productBox.getAll();
    } else {
      final query = objectBox.productBox.query().build();
      _productList = query.find().where((element) => element.category == category).toList();
    }
    setState(() {});
  }

  void initializePackageStream(String category) {
    if (category == "All") {
      _packageList = objectBox.packagedProductBox.getAll();
    } else {
      final query = objectBox.packagedProductBox.query().build();
      _packageList = query.find().where((element) => element.category.contains(category)).toList();
    }
    setState(() {});
  }

  void searchProduct() {
    final String strToSearch = searchController.text;
    final productSearchQuery = objectBox.productBox.query(Product_.name.contains(strToSearch, caseSensitive: false));
    final packageSearchQuery = objectBox.packagedProductBox.query(PackagedProduct_.name.contains(strToSearch, caseSensitive: false));
    _productList = productSearchQuery.build().find();
    _packageList = packageSearchQuery.build().find();
    setState((){});
  }

  void voidCart(BuildContext context) {
    clearCart();
    Navigator.of(context).pop();
  }

  void clearCart() {
    _cartList = [];
    _cartPackageList = [];
    _discountManager.clearDiscounts();
    _subtotal = 0.0;
    initializeProductStream("All");
    initializePackageStream("All");
    setState(() {});
  }

  Future<void> showVoidCartConfirmationDialog() async {
    if (_cartList.isEmpty && _cartPackageList.isEmpty) {
      Fluttertoast.showToast(msg: "Cart is Empty, no need to void");
      return;
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Void Transaction'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Are you sure you want to void this transaction?')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text('Confirm'),
              onPressed: () => voidCart(context),
            ),
          ],
        );
      },
    );
  }

  // Optimized discount methods
  void addDiscount(Discount discount) {
    final success = _discountManager.addDiscount(discount);
    if (success) {
      _recalculateDiscounts();
    } else {
      Fluttertoast.showToast(msg: "${discount.title} is already applied");
    }
  }

  void removeDiscount(String discountTitle) {
    final success = _discountManager.removeDiscount(discountTitle);
    if (success) {
      _recalculateDiscounts();
    }
  }

  void clearAppliedDiscounts() {
    _discountManager.clearDiscounts();
    setState(() {});
  }

  void _recalculateDiscounts() {
    final result = _discountManager.calculateDiscounts(
      cartProducts: _cartList,
      cartPackages: _cartPackageList,
      subtotal: _subtotal,
    );
    
    // Show errors if any
    if (result.errors.isNotEmpty) {
      for (final error in result.errors) {
        Fluttertoast.showToast(msg: error);
      }
    }
    
    setState(() {});
  }

  // Enhanced discount dialog with better error handling
  Future<void> showDiscountsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.discount_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Apply Discounts",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      "Select and manage discount options",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Total Discount Display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.savings_outlined,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Discount",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.currency(symbol: "₱").format(_discountManager.totalDiscount),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add Discount Section
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDiscount.isNotEmpty ? _selectedDiscount : null,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      hintText: "Select a discount...",
                                    ),
                                    items: _availableDiscounts.map((discount) {
                                      return DropdownMenuItem(
                                        value: discount.title,
                                        child: Text(discount.title),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      _selectedDiscount = val ?? "";
                                      setDialogState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _selectedDiscount.isNotEmpty
                                      ? () {
                                          final selected = _availableDiscounts.firstWhere(
                                            (element) => element.title == _selectedDiscount,
                                          );
                                          addDiscount(selected);
                                          setDialogState(() {});
                                        }
                                      : null,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text("Add"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Applied Discounts
                            Text(
                              "Applied Discounts (${_discountManager.appliedDiscounts.length})",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),

                            Flexible(
                              child: _discountManager.appliedDiscounts.isEmpty
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "No discounts applied",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _discountManager.appliedDiscounts.length,
                                      itemBuilder: (context, index) {
                                        final discount = _discountManager.appliedDiscounts[index];
                                        final discountAmount = _discountManager.discountBreakdown[discount.title] ?? 0.0;
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.local_offer,
                                                  size: 16,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        discount.title,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      Text(
                                                        NumberFormat.currency(symbol: "₱").format(discountAmount),
                                                        style: TextStyle(
                                                          color: Colors.green.shade600,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                TextButton.icon(
                                                  onPressed: () {
                                                    removeDiscount(discount.title);
                                                    setDialogState(() {});
                                                  },
                                                  icon: const Icon(Icons.remove_circle_outline, size: 16),
                                                  label: const Text("Remove"),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _discountManager.appliedDiscounts.isNotEmpty
                                  ? () {
                                      clearAppliedDiscounts();
                                      setDialogState(() {});
                                    }
                                  : null,
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: const Text("Clear All"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text("Apply Discounts"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void calculateSubTotal() {
    _subtotal = _cartList.fold(0.0, (previousValue, element) {
      return previousValue + element.totalPrice;
    });
    _subtotal += _cartPackageList.fold(0.0, (previousValue, element) => previousValue + element.price);
    
    // Recalculate discounts when subtotal changes
    _recalculateDiscounts();
  }

  // Rest of your existing methods remain the same...
  void addPackageToCart(PackagedProduct package) {
    PackagedProduct newPackage = PackagedProduct(
      name: package.name,
      category: package.category,
      quantity: package.quantity,
      products: package.products,
      price: package.price,
      image: "",
    );
    newPackage.id = package.id;
    _cartPackageList.add(newPackage);
    setState(() {});
    calculateSubTotal();
  }

  void removePackageFromCart(PackagedProduct package, int index) {
    final package = _cartPackageList[index];
    for (var product in package.productsList) {
      final removedProduct = _productList.firstWhere((element) => element.id == product.id);
      removedProduct.quantity += product.quantity;
      setState(() {});
    }
    _cartPackageList.removeAt(index);
    calculateSubTotal();
    setState(() {});
  }

  void addToCart(Product product) {
    final quantity = int.parse(quantityController.text);
    if (quantity == 0) {
      Fluttertoast.showToast(msg: "Invalid quantity of 0");
      return;
    }
    Product newProduct = Product(
      name: product.name,
      category: product.category,
      unitPrice: product.unitPrice,
      quantity: quantity,
      totalPrice: product.unitPrice * quantity,
      image: "",
    );
    if (product.quantity == 0) return;
    product.quantity -= quantity;
    setState(() {});
    newProduct.id = product.id;
    try {
      int prodIdx = _cartList.indexOf(
          _cartList.firstWhere((element) => element.name == newProduct.name));
      _cartList[prodIdx].quantity += quantity;
      _cartList[prodIdx].totalPrice =
          _cartList[prodIdx].quantity * newProduct.unitPrice;
      calculateSubTotal();
      setState(() {});
    } on StateError {
      _cartList.add(newProduct);
      calculateSubTotal();
      setState(() {});
    }
  }

  void removeProductFromCart(Product product, int index) {
    final variantName = product.name.split("---").last;
    final removedProduct = _productList.firstWhere((element) => element.id == product.id);
    if (removedProduct.withVariant) {
      final removedVariant = removedProduct.variants.firstWhere((element) => element.name == variantName);
      removedVariant.quantity += product.quantity;
    }
    removedProduct.quantity += product.quantity;
    _cartList.removeAt(index);
    calculateSubTotal();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.57,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  CashierControlPanel(
                    scaffoldContext: context,
                    quantityController: quantityController,
                    searchController: searchController,
                    searchProduct: searchProduct,
                    refresh: refresh,
                  ),
                  CashierGrid(
                    productsList: _productList,
                    packageList: _packageList,
                    categoriesList: _categoriesList,
                    selectedCategory: _selectedCategory,
                    quantity: quantityController.text != "" ? int.parse(quantityController.text) : 0,
                    addToCart: addToCart,
                    addPackageToCart: addPackageToCart,
                    setSelectedCategory: setSelectedCategory,
                  )
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.blueGrey, width: 0.2),
                ),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.428,
                height: MediaQuery.of(context).size.height,
                child: Cart(
                  rootContext: context,
                  products: _productList,
                  calculateTotal: calculateSubTotal,
                  addPackageToCart: addPackageToCart,
                  removePackageFromCart: removePackageFromCart,
                  removeProductFromCart: removeProductFromCart,
                  showDiscountsDialog: showDiscountsDialog,
                  discountList: _availableDiscounts,
                  selectedDiscount: _selectedDiscount,
                  appliedDiscountList: _discountManager.appliedDiscounts,
                  cartList: _cartList,
                  cartPackageList: _cartPackageList,
                  total: _subtotal.toInt(),
                  discount: _discountManager.totalDiscount,
                  voidCart: showVoidCartConfirmationDialog,
                  currentAccount: currentAccount,
                  clearCart: clearCart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}