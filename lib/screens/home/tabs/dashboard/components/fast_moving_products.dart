import 'package:flutter/material.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/dashboard/model/sales.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FastMovingProducts extends StatefulWidget {
  const FastMovingProducts({Key? key}) : super(key: key);

  @override
  State<FastMovingProducts> createState() => _FastMovingProductsState();
}

class _FastMovingProductsState extends State<FastMovingProducts> {
  List<String> _distinctCategories = [];
  List<String> _distinctProducts = [];
  List<Sales> _fastMovingProducts = [];
  bool _byCategory = true;
  static final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeFastMovingProductsByCategory();
  }

  void initializeDistinctCategories() {
    final queryBuilder = objectBox.productBox.query();
    final query = queryBuilder.build();
    PropertyQuery<String> pq = query.property(Product_.category);
    pq.distinct = true;

    setState(() {
      _distinctCategories = pq.find();
    });
  }

  void initializeDistinctProducts() {
    final queryBuilder = objectBox.productBox.query();
    final query = queryBuilder.build();
    PropertyQuery<String> pq = query.property(Product_.name);
    pq.distinct = true;

    setState(() {
      _distinctProducts = pq.find();
    });
  }

  void initializeFastMovingProductsByProduct() {
    initializeDistinctProducts();
    _fastMovingProducts = [];

    for (var product in _distinctProducts) {
      final queryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
          now.millisecondsSinceEpoch,
          DateTime(now.year, now.month, now.day - 7).millisecondsSinceEpoch,
        ),
      ).build();
      final transactions = queryBuilder.find();

      var sum = 0;
      for (var transaction in transactions) {
        for (var package in transaction.packages) {
          int packageProductTotal = package.productsList.where((item) => item.name == product).fold(0, (prev, curr) => prev + curr.totalPrice);
          sum += packageProductTotal;
        }

        int productTotal = transaction.products.where((item) => item.name == product).fold(0, (prev, curr) => prev + curr.totalPrice);
        sum += productTotal;
      }

      _fastMovingProducts.add(Sales(product, sum));
    }

    _fastMovingProducts.sort((a, b) => b.sales.compareTo(a.sales));
    setState(() {});
  }

  void initializeFastMovingProductsByCategory() {
    initializeDistinctCategories();
    _fastMovingProducts = [];

    for (var category in _distinctCategories) {
      final queryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
          now.millisecondsSinceEpoch,
          DateTime(now.year, now.month, now.day - 7).millisecondsSinceEpoch,
        ),
      ).build();
      final transactions = queryBuilder.find();

      var sum = 0;
      for (var transaction in transactions) {
        for (var package in transaction.packages) {
          int packageProductTotal = package.productsList.where((product) => product.category == category).fold(0, (prev, curr) => prev + curr.totalPrice);
          sum += packageProductTotal;
        }

        int productTotal = transaction.products.where((product) => product.category == category).fold(0, (prev, curr) => prev + curr.totalPrice);
        sum += productTotal;
      }
      _fastMovingProducts.add(Sales(category, sum));
    }

    _fastMovingProducts.sort((a, b) => b.sales.compareTo(a.sales));
    setState(() {});
  }

  void byCategoryOnClick() {
    setState(() {
      _byCategory = true;
      initializeFastMovingProductsByCategory();
    });
  }

  void byProductOnClick() {
    setState(() {
      _byCategory = false;
      initializeFastMovingProductsByProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.90,
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  blurRadius: 7,
                  color: Color.fromARGB(255, 216, 216, 216),
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text('Fast Moving Products'),
                    ),
                    Row(
                      children: [
                        _byCategory ?
                        FilledButton(onPressed: byCategoryOnClick, child: const Text("Category")) :
                        FilledButton.tonal(onPressed: byCategoryOnClick, child: const Text("Category")),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _byCategory ?
                            FilledButton.tonal(onPressed: byProductOnClick, child: const Text("Product")) :
                            FilledButton(onPressed: byProductOnClick, child: const Text("Product"))
                        ),
                      ],
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 80),
                  child: SfCircularChart(
                    tooltipBehavior: TooltipBehavior(
                      enable: true
                    ),
                    legend: Legend(
                      position: LegendPosition.right,
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.scroll),
                    series: <CircularSeries<Sales, String>>[
                      DoughnutSeries(
                        radius: '${MediaQuery.of(context).size.height * 0.25}',
                        dataSource: _fastMovingProducts.take(5).toList(),
                        xValueMapper: (Sales sales, _) => sales.identifier,
                        yValueMapper: (Sales sales, _) => sales.sales,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
