import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/product_screen.dart';

class InventoryProductListItem extends StatefulWidget {
  const InventoryProductListItem({
    Key? key,
    required this.index,
    required this.product,
  }) : super(key: key);

  final int index;
  final Product product;

  @override
  State<InventoryProductListItem> createState() => _InventoryProductListItemState();
}

class _InventoryProductListItemState extends State<InventoryProductListItem> {
  void navigateToProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          product: widget.product,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: navigateToProductScreen,
      child: Container(
        decoration: BoxDecoration(
          color: widget.index % 2 == 0
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondaryContainer,
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
                  child: Text(widget.product.id.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.product.name),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.product.category),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      Text(NumberFormat.currency(symbol: "₱").format(widget.product.unitPrice)),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      Text(widget.product.quantity.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      Text(NumberFormat.currency(symbol: "₱").format(widget.product.totalPrice)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
