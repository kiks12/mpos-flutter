
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/utils/receipt_printer.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final Transaction transaction;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {

  @override
  void initState() {
    super.initState();
  }

  Widget _itemPackageBuilder(PackagedProduct package) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  package.name,
                  textAlign: TextAlign.left,
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
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          for (var product in package.productsList) Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    product.name,
                    textAlign: TextAlign.left,
                  ),
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
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _itemBuilder(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              product.name,
              textAlign: TextAlign.left,
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
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void addQuantityToProduct(Product product) {
    final productToUpdate = objectBox.productBox.get(product.id);
    if (productToUpdate == null) {
      Fluttertoast.showToast(msg: "Product not found");
      return;
    }
    productToUpdate.quantity = productToUpdate.quantity + product.quantity;
    objectBox.productBox.put(productToUpdate);
  }

  void deleteTransaction(BuildContext context) {
    for (var package in widget.transaction.packages) {
      for (var product in package.productsList) {
        addQuantityToProduct(product);
      }
    }
    for (var product in widget.transaction.products) {
      addQuantityToProduct(product);
    }
    objectBox.transactionBox.remove(widget.transaction.id);
    Fluttertoast.showToast(msg: "Successfully deleted transaction");
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                    'Are you sure you want to delete this transaction record?'),
                Text(
                    '${widget.transaction.transactionID} - ${widget.transaction.totalAmount}'),
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
              onPressed: () => deleteTransaction(context),
            ),
          ],
        );
      },
    );
  }

  void print() async {
    await printReceipt(widget.transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Screen"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Transaction ID:"),
                    Text("${widget.transaction.transactionID}"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Date/Time:"),
                    Text("${widget.transaction.time}"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Cashier:"),
                    Text("${widget.transaction.user.target?.firstName} ${widget.transaction.user.target?.lastName}"),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 30)),
                for (var package in widget.transaction.packages) _itemPackageBuilder(package),
                for (var product in widget.transaction.products) _itemBuilder(product),
                const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Payment Method:"),
                    Text(widget.transaction.paymentMethod),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sub Total:"),
                    Text(NumberFormat.currency(symbol: "₱").format(widget.transaction.subTotal)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Discount:"),
                    Text(NumberFormat.currency(symbol: "₱").format(widget.transaction.discount)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Price:"),
                    Text(NumberFormat.currency(symbol: "₱").format(widget.transaction.totalAmount)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Cash Payment:"),
                    Text(NumberFormat.currency(symbol: "₱").format(widget.transaction.payment)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Change:"),
                    Text(NumberFormat.currency(symbol: "₱").format(widget.transaction.change)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      style: IconButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
                          foregroundColor: Colors.red
                      ),
                      icon: const Icon(Icons.delete),
                      onPressed: showDeleteConfirmationDialog,
                      label: const Text("Delete")
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          print();
                        },
                        icon: const Icon(Icons.print),
                        label: const Text("Print")
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
