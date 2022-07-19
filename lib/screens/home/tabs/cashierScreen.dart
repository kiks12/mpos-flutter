import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/inventory/components/inventoryListTile.dart';
import 'package:mpos/screens/home/tabs/inventory/inventoryScreen.dart';

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

  @override
  void initState() {
    super.initState();
    initializeInventoryStream();
  }

  void initializeInventoryStream() {
    final inventoryQuery = objectBox.productBox.query()
      ..order(Product_.id, flags: Order.descending);
    final inventoryStream = inventoryQuery.watch(triggerImmediately: true);

    _inventoryController
        .addStream(inventoryStream.map((query) => query.find()));
  }

  void voidCart() {
    setState(() {
      _cartList = [];
      _total = 0;
    });

    Navigator.pop(context);
  }

  Future<void> showVoidCartConfirmationDialog() async {
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
              onPressed: voidCart,
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
      tags: products[index].tags,
      unitPrice: products[index].unitPrice,
      quantity: int.parse(quantityController.text),
      totalPrice:
          products[index].unitPrice * int.parse(quantityController.text),
    );

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
    } on StateError catch (e) {
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
  }) : super(key: key);

  final TextEditingController barcodeController;
  final TextEditingController searchController;
  final TextEditingController quantityController;

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
            onPressed: () {},
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
  }) : super(key: key);

  final List<Product> cartList;
  final int total;
  final void Function() voidCart;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: HeaderOne(padding: EdgeInsets.all(0), text: 'Cart'),
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
                        padding: EdgeInsets.all(0),
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
                      child: Text('Void'),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Pay'),
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
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
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
