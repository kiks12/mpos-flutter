import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_cart.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_grid.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_control_panel.dart';
import 'package:mpos/utils/utils.dart';

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
  int _total = 0;

  List<Discount> _discountList = [];
  List<Discount> _appliedDiscountList = [];
  String _selectedDiscount = "";
  double _discount = 0.0;

  Account? currentAccount;

  @override
  void initState() {
    super.initState();
    getCurrentAccount();
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

  void getCurrentAccount() {
    setState(() {
      currentAccount = Utils().getCurrentAccount(objectBox);
    });
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
    _discountList = [];
    final query = objectBox.discountBox.query().build();
    query.find().forEach((element) { _discountList.add(element); });
    if (_discountList.isNotEmpty) _selectedDiscount = _discountList[0].title;
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
    _appliedDiscountList = [];
    _discount = 0;
    _total = 0;

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
      barrierDismissible: false, // user must tap button!
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

  void calculateDiscount(Discount discount) {
    if (discount.type == "TOTAL" && discount.operation == "FIXED") {
      _discount += discount.value;
      setState(() {});
    }
    if (discount.type == "TOTAL" && discount.operation == "PERCENTAGE") {
      _discount += _total * (discount.value / 100);
    }
    if (discount.type == "SPECIFIC" && discount.operation == "FIXED") {
      for (var element in _cartPackageList) {
        if (discount.products.contains(element.name)) _discount += discount.value;
        for (var product in element.productsList) {
          if (discount.products.contains(product.name)) _discount += discount.value * product.quantity;
        }
      }
      for (var element in _cartList) {
        if (discount.products.contains(element.name)) _discount += (discount.value * element.quantity);
      }
    }
    if (discount.type == "SPECIFIC" && discount.operation == "PERCENTAGE") {
      for (var element in _cartPackageList) {
        if (discount.products.contains(element.name)) _discount += element.price * (discount.value / 100);
        for (var product in element.productsList) {
          if (discount.products.contains(product.name)) _discount += product.totalPrice * (discount.value / 100);
        }
      }
      for (var element in _cartList) {
        if (discount.products.contains(element.name)) _discount += element.totalPrice * (discount.value / 100);
      }
    }
    setState(() {});
  }

  // void calculateDiscount(Discount discount) {
  //   if (discount.type == "TOTAL" && discount.operation == "FIXED") {
  //     _discount += discount.value;
  //     setState(() {});
  //   }
  //   if (discount.type == "TOTAL" && discount.operation == "PERCENTAGE") {
  //     _discount += _total * (discount.value / 100);
  //   }
  //   if (discount.type == "SPECIFIC" && discount.operation == "FIXED") {
  //     for (var element in _cartPackageList) {
  //       if (discount.products.contains(element.name)) _discount += discount.value;
  //     }
  //     for (var element in _cartList) {
  //       if (discount.products.contains(element.name)) _discount += (discount.value * element.quantity);
  //     }
  //   }
  //   if (discount.type == "SPECIFIC" && discount.operation == "PERCENTAGE") {
  //     for (var element in _cartPackageList) {
  //       if (discount.products.contains(element.name)) _discount += element.price * (discount.value / 100);
  //     }
  //     for (var element in _cartList) {
  //       if (discount.products.contains(element.name)) _discount += element.totalPrice * (discount.value / 100);
  //     }
  //   }
  //   setState(() {});
  // }

  void calculateDiscountSubtract(Discount discount) {
    if (discount.type == "TOTAL" && discount.operation == "FIXED") {
      _discount -= discount.value;
      setState(() {});
    }
    if (discount.type == "TOTAL" && discount.operation == "PERCENTAGE") {
      _discount -= _total * (discount.value / 100);
    }
    if (discount.type == "SPECIFIC" && discount.operation == "FIXED") {
      for (var element in _cartPackageList) {
        if (discount.products.contains(element.name)) _discount -= discount.value;
        for (var product in element.productsList) {
          if (discount.products.contains(product.name)) _discount -= discount.value * product.quantity;
        }
      }
      for (var element in _cartList) {
        if (discount.products.contains(element.name)) _discount -= (discount.value * element.quantity);
      }
    }
    if (discount.type == "SPECIFIC" && discount.operation == "PERCENTAGE") {
      for (var element in _cartPackageList) {
        if (discount.products.contains(element.name)) _discount -= element.price * (discount.value / 100);
        for (var product in element.productsList) {
          if (discount.products.contains(product.name)) _discount -= product.totalPrice * (discount.value / 100);
        }
      }
      for (var element in _cartList) {
        if (discount.products.contains(element.name)) _discount -= element.totalPrice * (discount.value / 100);
      }
    }
    setState(() {});
  }

  // void calculateDiscountSubtract(Discount discount) {
  //   if (discount.type == "TOTAL" && discount.operation == "FIXED") {
  //     _discount -= discount.value;
  //     setState(() {});
  //   }
  //   if (discount.type == "TOTAL" && discount.operation == "PERCENTAGE") {
  //     _discount -= _total * (discount.value / 100);
  //   }
  //   if (discount.type == "SPECIFIC" && discount.operation == "FIXED") {
  //     for (var element in _cartPackageList) {
  //       if (discount.products.contains(element.name)) _discount -= discount.value;
  //     }
  //     for (var element in _cartList) {
  //       if (discount.products.contains(element.name)) _discount -= (discount.value * element.quantity);
  //     }
  //   }
  //   if (discount.type == "SPECIFIC" && discount.operation == "PERCENTAGE") {
  //     for (var element in _cartPackageList) {
  //       if (discount.products.contains(element.name)) _discount -= element.price * (discount.value / 100);
  //     }
  //     for (var element in _cartList) {
  //       if (discount.products.contains(element.name)) _discount -= element.totalPrice * (discount.value / 100);
  //     }
  //   }
  //   setState(() {});
  // }

  void clearAppliedDiscounts() {
    _appliedDiscountList = [];
    _discount = 0;
    setState(() {});
  }

  Future<void> showDiscountsDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Row(
                children: [
                  const Text("Apply Discounts"),
                  Padding(
                    padding: const EdgeInsets.only(left: 55),
                    child: Text("Total Discount: ${NumberFormat.currency(symbol: "₱").format(_discount)}"),
                  )
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton(
                            isExpanded: true,
                            value: _selectedDiscount,
                            items: _discountList.map((e) {
                              return DropdownMenuItem(
                                  value: e.title,
                                  child: Text(e.title)
                              );
                            }).toList(),
                            onChanged: (val) {
                              _selectedDiscount = val.toString();
                              setState(() {});
                            }
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:15),
                          child: FilledButton.tonal(onPressed: (){
                            final selected = _discountList.firstWhere((element) => element.title == _selectedDiscount);
                            _appliedDiscountList.add(selected);
                            calculateDiscount(selected);
                            setState(() {});
                          }, child: const Text("Add")),
                        )
                      ],
                    ),
                    for (var discount in _appliedDiscountList) Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.black26)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(discount.title),
                              TextButton(
                                onPressed: (){
                                  _appliedDiscountList = _appliedDiscountList.where((element) => element.title != discount.title).toList();
                                  calculateDiscountSubtract(discount);
                                  setState(() {});
                                },
                                child: const Text("Remove")
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                FilledButton.tonal(
                  child: const Text('Clear'),
                  onPressed: () {
                    clearAppliedDiscounts();
                    setState((){});
                  },
                ),
                FilledButton(
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  void calculateSubTotal() {
    _total = _cartList.fold(0, (previousValue, element) {
      return previousValue + element.totalPrice;
    });
    _total += _cartPackageList.fold(0, (previousValue, element) => previousValue + element.price);
    setState(() {});
  }

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
    Navigator.of(context).pop();
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
      totalPrice:
          product.unitPrice * quantity,
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
    Navigator.of(context).pop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.57,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                CashierControlPanel(
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
                products: _productList,
                calculateTotal: calculateSubTotal,
                addPackageToCart: addPackageToCart,
                removePackageFromCart: removePackageFromCart,
                removeProductFromCart: removeProductFromCart,
                showDiscountsDialog: showDiscountsDialog,
                discountList: _discountList,
                selectedDiscount: _selectedDiscount,
                appliedDiscountList: _appliedDiscountList,
                cartList: _cartList,
                cartPackageList: _cartPackageList,
                total: _total,
                discount: _discount,
                voidCart: showVoidCartConfirmationDialog,
                currentAccount: currentAccount,
                clearCart: clearCart,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

