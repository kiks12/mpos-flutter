import 'package:flutter/material.dart';
import 'package:mpos/models/inventory.dart';

class InventoryListTile extends StatefulWidget {
  const InventoryListTile({
    Key? key,
    required this.index,
    required this.products,
  }) : super(key: key);

  final int index;
  final List<Product> products;

  @override
  State<InventoryListTile> createState() => _InventoryListTileState();
}

class _InventoryListTileState extends State<InventoryListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Text(widget.products[widget.index].unitPrice.toString()),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(widget.products[widget.index].quantity.toString()),
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
    );
  }
}
