import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';

import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/edit_product_screen.dart';
import 'package:mpos/screens/home/tabs/inventory/manage_quantities_screen.dart';

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

  void navigateToQuantities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageQuantitiesScreen(
          product: widget.product,
        ),
      ),
    );
  }

  void deleteProduct(BuildContext context) {
    objectBox.productBox.remove(widget.product.id);
    Fluttertoast.showToast(msg: "Successfully deleted product");
    Navigator.of(context).pop();
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
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
                    '${widget.product.id} - ${widget.product.name}'),
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
              onPressed: () => deleteProduct(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = File(widget.product.image);
    final imageExists = image.existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Screen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              imageExists ? Image.file(image, width: 450, height: 450) : const SizedBox(width: 450, height: 450, child: Center(child: Text("No Image Available"),)),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("PRODUCT ID: ${widget.product.id}"),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 30)),
                    Text(widget.product.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                    Text(widget.product.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                    Text("Unit Price: ${NumberFormat.currency(symbol: "₱").format(widget.product.unitPrice)}"),
                    Text("Quantity: ${widget.product.quantity}"),
                    Text("Total Price: ${NumberFormat.currency(symbol: "₱").format(widget.product.totalPrice)}"),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FilledButton.icon(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
                              foregroundColor: Colors.red
                            ),
                            icon: const Icon(Icons.delete),
                            onPressed: showDeleteConfirmationDialog,
                            label: const Text("Delete")
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.edit),
                            onPressed: navigateToEditProductScreen,
                            label: const Text('Edit'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FilledButton(
                            onPressed: navigateToQuantities,
                            child: const Text('Manage Quantities'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}