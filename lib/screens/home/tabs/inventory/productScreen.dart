import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';

import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/editProductScreen.dart';
import 'package:mpos/screens/home/tabs/inventory/manageExpirationDatesScreen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    // print(objectBox.expirationDateBox.getAll());
    // print(widget.product.expirationDates);
  }

  void navigateToEditProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          product: widget.product,
        ),
      ),
    );
  }

  void navigateToExpirationDates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageExpirationDatesScreen(
          product: widget.product,
        ),
      ),
    );
  }

  void deleteProduct(BuildContext context) {
    objectBox.productBox.remove(widget.product.id);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                    'Are you sure you want to delete this product in inventory?'),
                Text(
                    '${widget.product.id} - ${widget.product.name} - ${widget.product.barcode}'),
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
              onPressed: () => deleteProduct(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Screen: ${widget.product.name}',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              children: [
                ProductInformationRow(
                    label: 'ID', value: '${widget.product.id}'),
                ProductInformationRow(
                    label: 'Name', value: widget.product.name),
                ProductInformationRow(
                    label: 'Barcode', value: widget.product.barcode),
                ProductInformationRow(
                  label: 'Unit Price',
                  value: NumberFormat.currency(symbol: 'PHP')
                      .format(widget.product.unitPrice),
                ),
                ProductInformationRow(
                  label: 'Quantity',
                  value: '${widget.product.quantity}',
                ),
                ProductInformationRow(
                  label: 'Total Price',
                  value: NumberFormat.currency(symbol: 'PHP')
                      .format(widget.product.totalPrice),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: showDeleteConfirmationDialog,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Text('Delete'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: navigateToEditProductScreen,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Text('Edit'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: navigateToExpirationDates,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Text('Manage Expiration Dates'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductInformationRow extends StatefulWidget {
  const ProductInformationRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String label;
  final String value;

  @override
  State<ProductInformationRow> createState() => _ProductInformationRowState();
}

class _ProductInformationRowState extends State<ProductInformationRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                widget.value,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
