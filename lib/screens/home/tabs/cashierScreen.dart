import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/inventory/components/inventoryListTile.dart';
import 'package:mpos/screens/home/tabs/inventory/inventoryScreen.dart';
import 'package:mpos/utils/utils.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({Key? key}) : super(key: key);

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  List<Product> cart = [];

  StreamController<List<Product>> _inventoryController =
      StreamController(sync: true);

  TextEditingController barcodeController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: '1');

  List<Product> _cartList = [];
  int _total = 0;

  Account? currentAccount;

  @override
  void initState() {
    super.initState();
    initializeInventoryStream();
    setState(() {
      currentAccount = Utils().getCurrentAccount(objectBox);
    });
  }

  void initializeInventoryStream() {
    final inventoryQuery = objectBox.productBox.query()
      ..order(Product_.id, flags: Order.descending);
    final inventoryStream = inventoryQuery.watch(triggerImmediately: true);

    _inventoryController
        .addStream(inventoryStream.map((query) => query.find()));
  }

  void searchProduct() {
    final String strToSearch = searchController.text;
    final searchQuery = objectBox.productBox.query(
        Product_.barcode.contains(strToSearch) |
            Product_.name.contains(strToSearch));
    setState(() {
      _inventoryController = StreamController();
      final search = searchQuery.watch(triggerImmediately: true);

      _inventoryController.addStream(search.map((query) => query.find()));
    });
  }

  void voidCart(BuildContext context) {
    clearCart();
    Navigator.of(context).pop();
  }

  void clearCart() {
    setState(() {
      _cartList = [];
      _total = 0;

      _inventoryController = StreamController(sync: true);
      initializeInventoryStream();
    });
  }

  Future<void> showVoidCartConfirmationDialog() async {
    if (_cartList.isEmpty) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Void Transaction'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
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
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () => voidCart(context),
            ),
          ],
        );
      },
    );
  }

  void addToCart(List<Product> products, int index) {
    Product newProduct = Product(
      name: products[index].name,
      barcode: products[index].barcode,
      category: products[index].category,
      unitPrice: products[index].unitPrice,
      quantity: int.parse(quantityController.text),
      totalPrice:
          products[index].unitPrice * int.parse(quantityController.text),
    );

    if (products[index].quantity == 0) return;

    setState(() {
      products[index].quantity -= int.parse(quantityController.text);
    });

    newProduct.id = products[index].id;

    try {
      int prodIdx = _cartList.indexOf(
          _cartList.firstWhere((element) => element.id == newProduct.id));
      setState(() {
        _cartList[prodIdx].quantity += int.parse(quantityController.text);
        _cartList[prodIdx].totalPrice =
            _cartList[prodIdx].quantity * newProduct.unitPrice;

        _total = _cartList.fold(0, (previousValue, element) {
          return previousValue + element.totalPrice;
        });
      });
    } on StateError {
      setState(() {
        _cartList.add(newProduct);
        _total = _cartList.fold(0, (previousValue, element) {
          return previousValue + element.totalPrice;
        });
      });
    }
  }

  InventoryListTile Function(BuildContext, int) _itemBuilder(
      List<Product> products) {
    return (BuildContext context, int index) {
      return InventoryListTile(
        onCashier: true,
        products: products,
        index: index,
        onCashierCallback: () => addToCart(products, index),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.blueGrey, width: 0.2),
              ),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height,
              child: Cart(
                cartList: _cartList,
                total: _total,
                voidCart: showVoidCartConfirmationDialog,
                currentAccount: currentAccount,
                clearCart: clearCart,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.69,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                ProductsControlPanel(
                  barcodeController: barcodeController,
                  searchController: searchController,
                  quantityController: quantityController,
                  searchProduct: searchProduct,
                ),
                const ListHeader(),
                Expanded(
                  child: StreamBuilder<List<Product>>(
                    stream: _inventoryController.stream,
                    builder: ((context, snapshot) => ListView.builder(
                          itemBuilder: _itemBuilder(snapshot.data ?? []),
                          shrinkWrap: true,
                          itemCount:
                              snapshot.hasData ? snapshot.data!.length : 0,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                        )),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ProductsControlPanel extends StatefulWidget {
  const ProductsControlPanel({
    Key? key,
    required this.barcodeController,
    required this.searchController,
    required this.quantityController,
    required this.searchProduct,
  }) : super(key: key);

  final TextEditingController barcodeController;
  final TextEditingController searchController;
  final TextEditingController quantityController;
  final void Function() searchProduct;

  @override
  State<ProductsControlPanel> createState() => ProductsControlPanelState();
}

class ProductsControlPanelState extends State<ProductsControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
            child: TextFormFieldWithLabel(
              controller: widget.quantityController,
              isPassword: false,
              label: 'Qty',
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              textAlign: TextAlign.center,
              isNumber: true,
            ),
          ),
          Expanded(
            child: TextFormFieldWithLabel(
              label: 'Scan Barcode',
              controller: widget.barcodeController,
              padding: const EdgeInsets.all(0),
              isPassword: false,
              onChanged: (String str) {
                print(str);
              },
              // onFieldSubmitted: () {},
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormFieldWithLabel(
                label: 'Search',
                controller: widget.searchController,
                padding: const EdgeInsets.all(0),
                isPassword: false,
                // onFieldSubmitted: () {},
              ),
            ),
          ),
          ElevatedButton(
            onPressed: widget.searchProduct,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: Text('Search'),
            ),
          ),
        ],
      ),
    );
  }
}

class Cart extends StatefulWidget {
  const Cart({
    Key? key,
    required this.cartList,
    required this.total,
    required this.voidCart,
    required this.currentAccount,
    required this.clearCart,
  }) : super(key: key);

  final List<Product> cartList;
  final int total;
  final void Function() voidCart;
  final Account? currentAccount;
  final void Function() clearCart;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  int _transactionID = 0;
  String _paymentMethod = 'Cash';
  TextEditingController cashController = TextEditingController();
  int _change = 0;
  bool _isLoading = false;

  Widget _itemBuilder(BuildContext context, int index) {
    return Container(
        child: ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.cartList[index].name,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              NumberFormat.currency(symbol: '₱')
                  .format(widget.cartList[index].unitPrice),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              widget.cartList[index].quantity.toString(),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              NumberFormat.currency(symbol: '₱')
                  .format(widget.cartList[index].totalPrice),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ));
  }

  @override
  void initState() {
    super.initState();
    initializeTransactionID();
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
    setState(() {
      _change = int.parse(cashController.text) - widget.total;
    });
  }

  void cancelPayment(BuildContext context) {
    cashController.text = widget.total.toString();
    calculateChange('str');
    Navigator.of(context).pop();
  }

  Future<void> pay(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    widget.cartList.asMap().forEach((index, product) async {
      Transaction newTransaction = Transaction(
        transactionID: _transactionID,
        quantity: product.quantity,
        paymentMethod: _paymentMethod,
        totalAmount: product.totalPrice,
        date: DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())),
        time: DateTime.now(),
      );
      newTransaction.product.target = product;
      newTransaction.user.target = widget.currentAccount as Account;

      objectBox.transactionBox.put(newTransaction);

      Product updateProduct = objectBox.productBox.get(product.id) as Product;
      updateProduct.quantity = updateProduct.quantity - product.quantity;
      updateProduct.totalPrice = updateProduct.quantity * product.unitPrice;
      objectBox.productBox.put(updateProduct);

      if (index == widget.cartList.length - 1) {
        setState(() {
          _isLoading = false;
          widget.clearCart();
          initializeTransactionID();
        });
        Navigator.pop(context);
      }
    });
  }

  Future<void> showCashPaymentDialog(BuildContext context) async {
    _paymentMethod = 'Cash';

    Navigator.pop(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Finalize Payment'),
          children: _isLoading
              ? [
                  const Text('Loading...'),
                ]
              : [
                  HeaderOne(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      text:
                          'Total: ${NumberFormat.currency(symbol: '₱').format(widget.total)}'),
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white, onPrimary: Colors.red),
                        onPressed: () => cancelPayment(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        onPressed: () => pay(context),
                        child: const Text('Pay'),
                      ),
                    ),
                  ),
                ],
        );
      },
    );
  }

  Future<void> showGCashPaymentDialog(BuildContext context) async {
    _paymentMethod = 'Cash';

    Navigator.pop(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Finalize Payment'),
          children: _isLoading
              ? [
                  const Text('Loading...'),
                ]
              : [
                  HeaderOne(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      text:
                          'Total: ${NumberFormat.currency(symbol: '₱').format(widget.total)}'),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: const HeaderOne(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      text: '09482791258',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white, onPrimary: Colors.red),
                        onPressed: () => cancelPayment(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        onPressed: () => pay(context),
                        child: const Text('Pay'),
                      ),
                    ),
                  ),
                ],
        );
      },
    );
  }

  Future<void> showPaymentMethodDialog() async {
    if (widget.cartList.isEmpty) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Payment Method'),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 231, 231, 231),
                              width: 0.7),
                        ),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: TextButton(
                          onPressed: () => showCashPaymentDialog(context),
                          child: const Text(
                            'Cash',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: TextButton(
                        onPressed: () => showGCashPaymentDialog(context),
                        child: const Text(
                          'GCash',
                          textAlign: TextAlign.center,
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
              const HeaderOne(padding: EdgeInsets.all(0), text: 'Cart'),
              Text('Transaction ID: $_transactionID'),
            ],
          ),
        ),
        const CartHeader(),
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemBuilder: _itemBuilder,
            itemCount: widget.cartList.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.blueGrey, width: 0.2),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const HeaderOne(
                        padding: EdgeInsets.all(0),
                        text: 'Total: ',
                      ),
                      HeaderOne(
                        padding: const EdgeInsets.all(0),
                        text: NumberFormat.currency(symbol: '₱')
                            .format(widget.total),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.red,
                      ),
                      onPressed: widget.voidCart,
                      child: const Text('Void'),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: ElevatedButton(
                    onPressed: showPaymentMethodDialog,
                    child: const Text('Pay'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CartHeader extends StatelessWidget {
  const CartHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Row(
        children: const <Widget>[
          Expanded(
            child: Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Price',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'QTY',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Total',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
