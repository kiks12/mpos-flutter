import 'package:flutter/material.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/productScreen.dart';

class InventoryListTile extends StatefulWidget {
  const InventoryListTile({
    Key? key,
    required this.index,
    required this.products,
    this.onCashier = false,
    this.onCashierCallback,
  }) : super(key: key);

  final int index;
  final List<Product> products;
  final bool onCashier;
  final void Function()? onCashierCallback;

  @override
  State<InventoryListTile> createState() => _InventoryListTileState();
}

class _InventoryListTileState extends State<InventoryListTile> {
  void navigateToProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          product: widget.products[widget.index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCashier && widget.onCashierCallback != null
          ? widget.onCashierCallback
          : navigateToProductScreen,
      child: Container(
        decoration: BoxDecoration(
          color: widget.index % 2 == 0
              ? Colors.transparent
              : const Color.fromARGB(255, 239, 239, 239),
          border: const Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 232, 232, 232),
              width: 0.7,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(widget.products[widget.index].id.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.products[widget.index].name),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.products[widget.index].barcode),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      Text(widget.products[widget.index].unitPrice.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      Text(widget.products[widget.index].quantity.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      Text(widget.products[widget.index].totalPrice.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
