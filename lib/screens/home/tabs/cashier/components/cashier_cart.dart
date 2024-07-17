
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_cart_header.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_package_builder.dart';
import 'package:mpos/utils/receipt_printer.dart';
import 'package:mpos/utils/utils.dart';

class Cart extends StatefulWidget {
  const Cart({
    Key? key,
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
  Transaction? _createdTransaction;

  @override
  void initState() {
    super.initState();
    initializeTransactionID();
  }

  Widget _itemProductBuilder(Product product, int index) {
    return ListTile(
      title: GestureDetector(
        onTap: () {
          showRemoveProductDialog(product, index);
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                NumberFormat.currency(symbol: '₱')
                    .format(product.unitPrice),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                product.quantity.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                NumberFormat.currency(symbol: '₱')
                    .format(product.totalPrice),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showTransactionCompleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.check_circle, size: 80, color: Colors.green),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Text('Transaction Complete', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.print),
                label: const Text('Print Receipt'),
                onPressed: () async {
                  if (_createdTransaction != null) return await printReceipt(_createdTransaction!);
                  Fluttertoast.showToast(msg: "Not Available");
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.clearCart();
                  _createdTransaction = null;
                  cashController.text = "";
                  referenceController.text = "";
                  initializeTransactionID();
                  Fluttertoast.showToast(msg: "Transaction Complete");
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showRemoveProductDialog(Product product, int index) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Remove from Cart"),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text("Are you sure you want to remove ${product.name} from cart?"),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () { Navigator.of(context).pop(); }, child: const Text("Cancel")),
                    FilledButton(onPressed: () { widget.removeProductFromCart(product, index); }, child: const Text("Remove")),
                  ],
                ),
              )
            ],
          );
        }
      );
  }

  Future<void> openPackageBuilder(PackagedProduct package, int index) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CashierPackageBuilder(
          products: widget.products,
          package: package,
          addPackageToCart: widget.addPackageToCart,
          removePackageFromCart: widget.removePackageFromCart,
          inCart: true,
          packageIndexInCart: index,
        );
      });
  }

  Widget _itemPackageBuilder(PackagedProduct package, int index) {
    return ListTile(
      title: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await openPackageBuilder(package, index);
              widget.calculateTotal();
              setState(() {});
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    package.name,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  child: Text(""),
                ),
                Expanded(
                  child: Text(
                    package.quantity.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(package.price),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          for (var product in package.productsList) Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  NumberFormat.currency(symbol: "₱").format(product.unitPrice),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  product.quantity.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  NumberFormat.currency(symbol: '₱')
                      .format(product.totalPrice),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

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
    _change = int.parse(cashController.text) - (widget.total - widget.discount.toInt());
    setState(() {});
  }

  void cancelPayment() {
    cashController.text = widget.total.toString();
    calculateChange('');
    Navigator.of(context).pop();
  }

  Future<void> pay() async {
    Transaction newTransaction = Transaction(
      transactionID: _transactionID,
      discount: widget.discount.toInt(),
      subTotal: widget.total,
      totalAmount: widget.total - widget.discount.toInt(),
      date: DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())),
      time: DateTime.now(),
      payment: _paymentMethod == "Cash" ? int.parse(cashController.text) : widget.total - widget.discount.toInt(),
      change: _paymentMethod == "Cash" ? _change : 0,
      paymentMethod: _paymentMethod,
      referenceNumber: referenceController.text,
      productsJson: jsonEncode(widget.cartList),
      packagesJson: jsonEncode(widget.cartPackageList)
    );

    newTransaction.user.target = widget.currentAccount as Account;
    for (var product in widget.cartList) {
      Product updateProduct = objectBox.productBox.get(product.id) as Product;
      updateProduct.quantity = updateProduct.quantity - product.quantity;
      updateProduct.totalPrice = updateProduct.quantity * product.unitPrice;
      objectBox.productBox.put(updateProduct);
      newTransaction.products.add(product);
    }
    for (var package in widget.cartPackageList) {
      for (var product in package.productsList) {
        Product updateProduct = objectBox.productBox.get(product.id) as Product;
        updateProduct.quantity = updateProduct.quantity - product.quantity;
        updateProduct.totalPrice = updateProduct.quantity * product.unitPrice;
        objectBox.productBox.put(updateProduct);
      }
    }

    objectBox.transactionBox.put(newTransaction);
    _createdTransaction = newTransaction;
    if (Utils().getServerAccount() != "" && Utils().getStore() != "") await saveTransactionInServer(newTransaction);
    if (mounted) Navigator.of(context).pop();
    showTransactionCompleteDialog();
    setState((){});
  }

  Future<void> saveTransactionInServer(Transaction transaction) async {
    try {
      final serverAccount = Utils().getServerAccount();
      final storeName = Utils().getStore();
      firestore.FirebaseFirestore db = firestore.FirebaseFirestore.instance;
      final snapshot = await db.collection("users").doc(serverAccount).collection("stores").where("storeName", isEqualTo: storeName).get();
      final documentId = snapshot.docs.first.id;
      final transactionRef = db.collection("users").doc(serverAccount).collection("stores").doc(documentId).collection("transactions");
      final jsonTransaction = transaction.toJson();
      jsonTransaction["date"] = firestore.Timestamp.fromDate(transaction.date);
      jsonTransaction["time"] = firestore.Timestamp.fromDate(transaction.time);
      jsonTransaction["cashier"] = "${transaction.user.target!.firstName} ${transaction.user.target!.lastName}";
      await transactionRef.add(jsonTransaction);
    } on firestore.FirebaseException catch(e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  Future<void> showCashPaymentDialog() async {
    _paymentMethod = 'Cash';
    referenceController.text = "";

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Cash Payment'),
          children: [
            HeaderOne(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                text:
                'Total: ${NumberFormat.currency(symbol: '₱').format(widget.total - widget.discount)}'),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextFormFieldWithLabel(
                  label: 'Cash',
                  controller: cashController,
                  padding: EdgeInsets.zero,
                  isPassword: false,
                  isNumber: true,
                  onChanged: (String str) => calculateChange(str),
                ),
              ),
            ),
            HeaderOne(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              text:
              'Change: ${NumberFormat.currency(symbol: '₱').format(_change)}',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          foregroundColor: Colors.red, backgroundColor: Colors.white),
                      onPressed: cancelPayment,
                      child: const Text('Cancel'),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 10),
                  //   child: SizedBox(
                  //     height: MediaQuery.of(context).size.height * 0.06,
                  //     child: FilledButton.tonal(
                  //       onPressed: () async {
                  //         if (_createdTransaction != null) return await printReceipt(_createdTransaction!);
                  //         Fluttertoast.showToast(msg: "Not Available");
                  //       },
                  //       child: const Text('Print Receipt'),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: FilledButton(
                      onPressed: pay,
                      child: const Text('Pay'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showOtherPaymentDialog(String paymentMethod) async {
    _paymentMethod = paymentMethod;
    cashController.text = "";

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('$paymentMethod Payment'),
          children: [
            HeaderOne(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                text:
                'Total: ${NumberFormat.currency(symbol: '₱').format(widget.total - widget.discount)}'),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextFormFieldWithLabel(
                  label: 'Reference Number',
                  controller: referenceController,
                  padding: EdgeInsets.zero,
                  isPassword: false,
                  isNumber: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          foregroundColor: Colors.red, backgroundColor: Colors.white),
                      onPressed: cancelPayment,
                      child: const Text('Cancel'),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 10),
                  //   child: SizedBox(
                  //     height: MediaQuery.of(context).size.height * 0.06,
                  //     child: FilledButton.tonal(
                  //       onPressed: () async {
                  //         if (_createdTransaction != null) return await printReceipt(_createdTransaction!);
                  //         Fluttertoast.showToast(msg: "Not Available");
                  //       },
                  //       child: const Text('Print Receipt'),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: FilledButton(
                      onPressed: pay,
                      child: const Text('Pay'),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> showPaymentMethodDialog() async {
    if (widget.cartList.isEmpty && widget.cartPackageList.isEmpty) {
      Fluttertoast.showToast(msg: "Cart is empty!");
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Payment Method'),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:5, horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: showCashPaymentDialog,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Cash'),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:5, horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => showOtherPaymentDialog("GCash"),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('GCash'),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:5, horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => showOtherPaymentDialog("Foodpanda"),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Foodpanda'),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:5, horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => showOtherPaymentDialog("Grab"),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Grab'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Transaction ID: $_transactionID'),
            ],
          ),
        ),
        const CartHeader(),
        Expanded(
          child: ListView(
            children: [
              ...widget.cartPackageList.asMap().entries.map((e) => _itemPackageBuilder(e.value, e.key)),
              ...widget.cartList.asMap().entries.map((e) => _itemProductBuilder(e.value, e.key)),
              // for (var product in widget.cartList) _itemBuilder(product),
            ],
          )
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.blueGrey, width: 0.2),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sub-Total: ',
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      Text(
                          NumberFormat.currency(symbol: '₱').format(widget.total),
                          style: const TextStyle(
                              fontSize: 18
                          )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discount: ',
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      Text(
                          NumberFormat.currency(symbol: '₱').format(widget.discount),
                          style: const TextStyle(
                              fontSize: 18
                          )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total: ',
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      Text(
                          NumberFormat.currency(symbol: '₱').format(widget.total - widget.discount),
                          style: const TextStyle(
                              fontSize: 18
                          )
                      ),
                    ],
                  ),
                ),
                Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            foregroundColor: Colors.red, backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
                          ),
                          onPressed: widget.voidCart,
                          child: const Text('Void'),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FilledButton.tonal(
                              onPressed: widget.showDiscountsDialog,
                              child: const Text("Discounts")
                          ),
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: showPaymentMethodDialog,
                          child: const Text('Pay'),
                        ),
                      ),
                    ]
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
