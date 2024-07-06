
import 'package:flutter/material.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_categories.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_grid_package_item.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_grid_product_item.dart';

class CashierGrid extends StatefulWidget {
  const CashierGrid({Key? key,
    required this.categoriesList,
    required this.productsList,
    required this.packageList,
    required this.addToCart,
    required this.addPackageToCart,
    required this.setSelectedCategory,
    required this.selectedCategory,
  }) : super(key: key);

  final void Function(Product, int) addToCart;
  final void Function(PackagedProduct) addPackageToCart;
  final void Function(String) setSelectedCategory;
  final List<String> categoriesList;
  final List<Product> productsList;
  final List<PackagedProduct> packageList;
  final String selectedCategory;

  @override
  State<CashierGrid> createState() => _CashierGridState();
}

class _CashierGridState extends State<CashierGrid> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final itemHeight = size.height / 2.7;
    final itemWidth = size.width / 8;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CashierCategories(
            categoriesList: widget.categoriesList,
            selectedCategory: widget.selectedCategory,
            setSelectedCategory: widget.setSelectedCategory
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    childAspectRatio: (itemWidth/itemHeight),
                    shrinkWrap: true,
                    crossAxisCount: 5,
                    children:  [
                      for (var package in widget.packageList) CashierGridPackageItem(
                        products: widget.productsList,
                        package: package,
                        addPackageToCart: widget.addPackageToCart,
                      ),
                      for (var product in widget.productsList) CashierGridProductItem(product: product, addToCart: widget.addToCart),
                    ]
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
