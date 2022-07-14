import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/attendance/components/attendanceListTile.dart';
import 'package:mpos/screens/home/tabs/inventory/addProductScreen.dart';
import 'package:mpos/screens/home/tabs/inventory/components/inventoryListTile.dart';
import 'package:mpos/screens/home/tabs/inventory/productScreen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Stream<Query<Product>> attendanceStream;

  StreamController<List<Product>> _listController =
      StreamController<List<Product>>(sync: true);

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeAttendanceStream();
  }

  @override
  void dispose() {
    _listController.close();
    super.dispose();
  }

  void initializeAttendanceStream() {
    final attendanceQueryBuilder = objectBox.productBox.query()
      ..order(Product_.id, flags: Order.descending);
    attendanceStream = attendanceQueryBuilder.watch(triggerImmediately: true);

    _listController.addStream(attendanceStream.map((query) => query.find()));
  }

  InventoryListTile Function(BuildContext, int) _itemBuilder(
      List<Product> products) {
    return (BuildContext context, int index) {
      return InventoryListTile(
        products: products,
        index: index,
      );
    };
  }

  void refresh() {
    setState(() {
      _listController = StreamController(sync: true);
      initializeAttendanceStream();
    });
  }

  void search() {
    // String strToSearch = searchController.text;
    // final attendanceQueryBuilder = objectBox.attendanceBox.query()
    //   ..link(
    //       Attendance_.user,
    //       Account_.firstName.contains(strToSearch) |
    //           Account_.lastName.contains(strToSearch) |
    //           Account_.emailAddress.contains(strToSearch))
    //   ..order(
    //     Attendance_.date,
    //     flags: Order.descending,
    //   );
    // final attendanceQuery =
    //     attendanceQueryBuilder.watch(triggerImmediately: true);

    // setState(() {
    //   _listController = StreamController(sync: true);
    //   _listController.addStream(attendanceQuery.map((query) => query.find()));
    //   searchController.text = '';
    // });
  }

  void deleteAll() {
    objectBox.attendanceBox.removeAll();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteAllConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Records'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text('Are you sure you want to delete all attendance Records?')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: deleteAll,
            ),
          ],
        );
      },
    );
  }

  Future<void> showProductOrFinishedGoodsOption() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose what to add:'),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 231, 231, 231),
                              width: 0.7),
                        ),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: TextButton(
                          onPressed: navigateToAddProductScreen,
                          child: const Text(
                            'Product\n\n(No Ingredients, ex. sardines, milk, coke)',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: TextButton(
                        onPressed: navigateToAddFinishedProductScreen,
                        child: const Text(
                          'Finished Goods\n\n(With Ingredients, ex. eggs)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void navigateToProductScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductScreen()));
  }

  void navigateToAddProductScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  }

  void navigateToAddFinishedProductScreen() {
    // Navigator.push()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InventoryScreenHeader(
              searchController: searchController,
              onPressed: search,
              refresh: refresh,
              deleteAll: showDeleteAllConfirmationDialog,
              addProduct: showProductOrFinishedGoodsOption,
            ),
            const ListHeader(),
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _listController.stream,
                builder: ((context, snapshot) => ListView.builder(
                      itemBuilder: _itemBuilder(snapshot.data ?? []),
                      shrinkWrap: true,
                      itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryScreenHeader extends StatefulWidget {
  const InventoryScreenHeader({
    Key? key,
    required this.searchController,
    required this.onPressed,
    required this.refresh,
    required this.deleteAll,
    required this.addProduct,
  }) : super(key: key);

  final TextEditingController searchController;
  final void Function() onPressed;
  final void Function() refresh;
  final void Function() deleteAll;
  final void Function() addProduct;

  @override
  State<InventoryScreenHeader> createState() => _InventoryScreenHeaderState();
}

class _InventoryScreenHeaderState extends State<InventoryScreenHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const HeaderOne(padding: EdgeInsets.all(0), text: 'Inventory'),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: TextField(
                        controller: widget.searchController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: widget.onPressed,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.blueGrey,
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Total Value: '),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.blueGrey,
                      ),
                      onPressed: widget.refresh,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        child: Text('Refresh'),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                    onPressed: widget.deleteAll,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text('Delete All'),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: widget.addProduct,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  child: Text('Add Product'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
      child: Row(
        children: const <Widget>[
          Expanded(
            child: Center(
              child: Text(
                'ID',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Barcode',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Unit Price',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Quantity',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Total Price',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
