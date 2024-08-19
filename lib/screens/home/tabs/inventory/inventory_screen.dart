import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/inventory/add_package_screen.dart';
import 'package:mpos/screens/home/tabs/inventory/add_product_screen.dart';
import 'package:mpos/screens/home/tabs/inventory/components/inventory_header.dart';
import 'package:mpos/screens/home/tabs/inventory/components/package_table.dart';
import 'package:mpos/screens/home/tabs/inventory/components/product_table.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin{
  List<Product> _productList = [];
  List<PackagedProduct> _packageList = [];

  final TextEditingController _searchController = TextEditingController();
  int _totalInventoryValue = 0;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void calculateInventoryValue() {
    Query<Product> productsQuery = objectBox.productBox.query().build();
    _totalInventoryValue = productsQuery.property(Product_.totalPrice).sum();
    setState(() {});
  }

  void initializeProductStream() async {
    final inventoryQueryBuilder = objectBox.productBox.query()
      ..order(Product_.id, flags: Order.descending);
    final inventoryStream = inventoryQueryBuilder.watch(triggerImmediately: true);

    inventoryStream.listen((event) {
      _productList = event.find();
      setState(() {});
    });
  }

  void initializePackageStream() async {
    final inventoryQueryBuilder = objectBox.packagedProductBox.query()
      ..order(PackagedProduct_.id, flags: Order.descending);
    final inventoryStream = inventoryQueryBuilder.watch(triggerImmediately: true);

    inventoryStream.listen((event) {
      _packageList = event.find();
      setState(() {});
    });
  }

  void refresh() {
    initializeProductStream();
    if (posTier != "FREE_TRIAL" && posTier != "BASIC") initializePackageStream();
    calculateInventoryValue();
  }

  void search() {
    String strToSearch = _searchController.text;
    final productQueryBuilder = objectBox.productBox.query(Product_.name.contains(strToSearch, caseSensitive: false))
      ..order(
        Product_.id,
        flags: Order.descending,
      );
    final packageQueryBuilder = objectBox.packagedProductBox.query(
        PackagedProduct_.name.contains(strToSearch, caseSensitive: false))..order(
        PackagedProduct_.id,
        flags: Order.descending,
      );
    final productQuery = productQueryBuilder.watch(triggerImmediately: true);
    final packageQuery = packageQueryBuilder.watch(triggerImmediately: true);
    productQuery.listen((event) {
      _productList = event.find();
      setState(() {});
    });
    packageQuery.listen((event) {
      _packageList = event.find();
      setState(() {});
    });
    _searchController.text = "";
    setState(() {});
  }

  void showProductWithLessThan(int quantity) {
    final productQueryBuilder =
        objectBox.productBox.query(Product_.quantity.lessOrEqual(quantity));
    final productQuery = productQueryBuilder.watch(triggerImmediately: true);
    productQuery.listen((event) {
      _productList = event.find();
      setState(() {});
    });
  }

  void onCategoryDropdownChange(String category) {
    final productQueryBuilder = objectBox.productBox.query(Product_.category.contains(category, caseSensitive: false))
      ..order(
        Product_.id,
        flags: Order.descending,
      );
    final packageQueryBuilder = objectBox.packagedProductBox.query(
        PackagedProduct_.category.contains(category))..order(
      PackagedProduct_.id,
      flags: Order.descending
    );
    final productQuery = productQueryBuilder.watch(triggerImmediately: true);
    final packageQuery = packageQueryBuilder.watch(triggerImmediately: true);
    productQuery.listen((event) {
      _productList = event.find();
      setState(() {});
    });
    packageQuery.listen((event) {
      _packageList = event.find();
      setState(() {});
    });
    setState(() {});
  }

  void deleteAll(BuildContext context) {
    objectBox.productBox.removeAll();
    objectBox.expirationDateBox.removeAll();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteAllConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Products'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    'Are you sure you want to delete all products in inventory?')
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
              onPressed: () => deleteAll(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAddOptionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose what to add:'),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
              width: MediaQuery.of(context).size.height * 0.75,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: SizedBox(
                        height: double.infinity,
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                          onPressed: navigateToAddProductScreen,
                          child: const Text(
                            'Product\n\n(Donuts, Cakes, etc.)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (posTier != "FREE_TRIAL" && posTier != "BASIC") ...[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: SizedBox(
                          height: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: navigateToAddPackageScreen,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            child: const Text(
                              'Packaged Products\n\n(Box of 3 Donuts)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void navigateToAddProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  }

  void navigateToAddPackageScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPackageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              InventoryHeader(
                onCategoryDropdownChange: onCategoryDropdownChange,
                showProductWithLessThan: showProductWithLessThan,
                inventoryValue: NumberFormat.currency(symbol: '₱')
                    .format(_totalInventoryValue),
                searchController: _searchController,
                onPressed: search,
                refresh: refresh,
                deleteAll: showDeleteAllConfirmationDialog,
                addProduct: showAddOptionDialog,
              ),
              TabBar(
                tabs: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text("Products (${_productList.length})"),
                  ),
                  if (posTier != "FREE_TRIAL" && posTier != "BASIC") ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text("Packages (${_packageList.length})"),
                    ),
                  ]
                ]
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ProductTable(productList: _productList),
                    if (posTier != "FREE_TRIAL" && posTier != "BASIC") PackageTable(packageList: _packageList),
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

