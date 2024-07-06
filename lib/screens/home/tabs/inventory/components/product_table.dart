
import 'package:flutter/material.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/components/inventory_product_list_item.dart';
import 'package:mpos/screens/home/tabs/inventory/components/inventory_product_list_header.dart';

class ProductTable extends StatefulWidget {
  const ProductTable({Key? key, required this.productList}) : super(key: key);

  final List<Product> productList;

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {

  InventoryProductListItem Function(BuildContext, int) _itemBuilder(
      List<Product> products) {
    return (BuildContext context, int index) {
      return InventoryProductListItem(
        product: products[index],
        index: index,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const InventoryProductListHeader(),
        Expanded(
          child: ListView.builder(
            itemBuilder: _itemBuilder(widget.productList),
            shrinkWrap: true,
            itemCount: widget.productList.length,
            padding: const EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
      ]
    );
  }
}
