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
    setState(() {
      _fastMovingProducts = [];
    });

    for (var product in _distinctProducts) {
      final queryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
          now.millisecondsSinceEpoch,
          DateTime(now.year, now.month, now.day - 7).millisecondsSinceEpoch,
        ),
      )..link(Transaction_.product, Product_.name.equals(product));
      final query =
          queryBuilder.build().property(Transaction_.totalAmount).sum();
      _fastMovingProducts.add(Sales(product, query));
    }

    _fastMovingProducts.sort((a, b) => a.sales.compareTo(b.sales));
  }

  void initializeFastMovingProductsByCategory() {
    initializeDistinctCategories();
    setState(() {
      _fastMovingProducts = [];
    });

    for (var category in _distinctCategories) {
      final queryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
          now.millisecondsSinceEpoch,
          DateTime(now.year, now.month, now.day - 7).millisecondsSinceEpoch,
        ),
      )..link(Transaction_.product, Product_.category.equals(category));
      final query =
          queryBuilder.build().property(Transaction_.totalAmount).sum();
      _fastMovingProducts.add(Sales(category, query));
    }

    setState(() {
      _fastMovingProducts.sort((a, b) => a.sales.compareTo(b.sales));
    });
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
          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.65,
              maxHeight: MediaQuery.of(context).size.height * 0.78,
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary:
                                _byCategory ? Colors.blueGrey : Colors.white,
                            onPrimary:
                                _byCategory ? Colors.white : Colors.blueGrey,
                          ),
                          onPressed: byCategoryOnClick,
                          child: const Text('By Category'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary:
                                  _byCategory ? Colors.white : Colors.blueGrey,
                              onPrimary:
                                  _byCategory ? Colors.blueGrey : Colors.white,
                            ),
                            onPressed: byProductOnClick,
                            child: const Text('By Product'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 50),
                  child: SfCircularChart(
                    tooltipBehavior: TooltipBehavior(),
                    legend: Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap),
                    series: <CircularSeries<Sales, String>>[
                      DoughnutSeries(
                        radius: '${MediaQuery.of(context).size.height * 0.18}',
                        dataSource: _fastMovingProducts.take(10).toList(),
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
