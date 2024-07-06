
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/inventory.dart';

class CashierGridProductItem extends StatefulWidget {
  const CashierGridProductItem({Key? key, required this.product, required this.addToCart}) : super(key: key);
  
  final Product product;
  final void Function(Product, int) addToCart;

  @override
  State<CashierGridProductItem> createState() => _CashierGridProductItemState();
}

class _CashierGridProductItemState extends State<CashierGridProductItem> {
  final quantityController = TextEditingController(text: "1");

  void lessQuantity() {
    int value = int.parse(quantityController.text) - 1;
    value = value < 1 ? 1 : value;
    quantityController.text = value.toString();
  }

  void addQuantity() {
    int value = int.parse(quantityController.text) + 1;
    value = value > widget.product.quantity ? widget.product.quantity : value;
    quantityController.text = value.toString();
  }

  @override
  void dispose() {
    super.dispose();
    quantityController.text = "1";
  }

  Future<void> showQuantityAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to Cart'),
          content: SizedBox(
            height: 120,
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        FilledButton.tonal(child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text("-", style: TextStyle(fontSize: 26),),
                        ), onPressed: lessQuantity),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              textAlign: TextAlign.center,
                              controller: quantityController,
                              decoration: InputDecoration(
                                labelText: "Quantity",
                                floatingLabelAlignment: FloatingLabelAlignment.center,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)
                                )
                              ),
                            ),
                          ),
                        ),
                        FilledButton.tonal(child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text("+", style: TextStyle(fontSize: 26),),
                        ), onPressed: addQuantity),
                      ],
                    ),
                  )
                ],
              ),
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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text('Add'),
              ),
              onPressed: () {
                if (widget.product.quantity >= int.parse(quantityController.text)) {
                  widget.addToCart(widget.product, int.parse(quantityController.text));
                  Navigator.of(context).pop();
                  return;
                }

                showInsufficientStockToast();
              }
            ),
          ],
        );
      },
    );
  }

  void showInsufficientStockToast() {
    Fluttertoast.showToast(msg: "Insufficient stock for this item.");
    return;
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.product.image);
    final bool fileExists = file.existsSync();

    return GestureDetector(
      onTap: widget.product.quantity == 0 ? showInsufficientStockToast : showQuantityAlertDialog,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 120,
              child: !fileExists ?
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black12,
                ),
                child: const Center(child: Text("No Image"))
              ) :
              Image.file(file, width: double.infinity)
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text(widget.product.name)),
                    ],
                  ),
                  Text(NumberFormat.currency(symbol: "₱").format(widget.product.unitPrice)),
                  Text(
                    "Stock: ${widget.product.quantity}",
                    style: const TextStyle(fontSize: 11),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
