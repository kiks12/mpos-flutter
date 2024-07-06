
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/package_screen.dart';

class InventoryPackageListItem extends StatefulWidget {
  const InventoryPackageListItem({Key? key, required this.index, required this.package}) : super(key: key);

  final int index;
  final PackagedProduct package;

  @override
  State<InventoryPackageListItem> createState() => _InventoryPackageListItemState();
}

class _InventoryPackageListItemState extends State<InventoryPackageListItem> {

  void navigateToPackageScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageScreen(
          packagedProduct: widget.package,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: navigateToPackageScreen,
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
                  child: Text(widget.package.id.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.package.name),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.package.category),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.package.quantity.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                  Text(NumberFormat.currency(symbol: "₱").format(widget.package.price)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
