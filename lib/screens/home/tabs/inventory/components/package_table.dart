
import 'package:flutter/material.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/components/inventory_package_list_header.dart';
import 'package:mpos/screens/home/tabs/inventory/components/inventory_package_list_item.dart';

class PackageTable extends StatefulWidget {
  const PackageTable({Key? key, required this.packageList}) : super(key: key);

  final List<PackagedProduct> packageList;

  @override
  State<PackageTable> createState() => _PackageTableState();
}

class _PackageTableState extends State<PackageTable> {

  InventoryPackageListItem Function(BuildContext, int) _itemBuilder(
      List<PackagedProduct> packageProducts) {
    return (BuildContext context, int index) {
      return InventoryPackageListItem(
        package: packageProducts[index],
        index: index,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const InventoryPackageListHeader(),
          Expanded(
            child: ListView.builder(
              itemBuilder: _itemBuilder(widget.packageList),
              shrinkWrap: true,
              itemCount: widget.packageList.length,
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ]
    );
  }
}
