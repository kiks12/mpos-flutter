
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_package_builder.dart';

class CashierGridPackageItem extends StatefulWidget {
  const CashierGridPackageItem({Key? key,
    required this.package,
    required this.products,
    required this.addPackageToCart,
  }) : super(key: key);

  final PackagedProduct package;
  final List<Product> products;
  final void Function(PackagedProduct) addPackageToCart;

  @override
  State<CashierGridPackageItem> createState() => _CashierGridPackageItemState();
}

class _CashierGridPackageItemState extends State<CashierGridPackageItem> {

  Future<void> openPackageBuilder() async {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CashierPackageBuilder(
          products: widget.products.where((element) => widget.package.category.toLowerCase().contains(element.name)).toList(),
          package: widget.package,
          addPackageToCart: widget.addPackageToCart,
          removePackageFromCart: (package, index) {},
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    // final file = File(widget.package.image);
    // final bool fileExists = file.existsSync();

    return GestureDetector(
      onTap: openPackageBuilder,
      child: Column(
        children: [
          SizedBox(
              width: double.infinity,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: Text(widget.package.name)),
                  ],
                ),
              )
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 10),
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Flexible(child: Text(widget.package.name)),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
