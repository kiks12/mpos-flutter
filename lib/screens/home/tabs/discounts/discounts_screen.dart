
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/discounts/add_discount_screen.dart';
import 'package:mpos/screens/home/tabs/discounts/components/discount_list_item.dart';
import 'package:mpos/screens/home/tabs/discounts/components/discount_header.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({Key? key}) : super(key: key);

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  late Stream<Query<Discount>> discountStream;
  List<Discount> discountList = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDiscountStream();
  }

  void navigateToAddDiscountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDiscountScreen(),
      ),
    );
  }

  void initializeDiscountStream() {
    final discountQueryBuilder = objectBox.discountBox.query()
      ..order(Discount_.id, flags: Order.descending);
    discountStream = discountQueryBuilder.watch(triggerImmediately: true);
    discountStream.listen((event) {
      discountList = event.find();
      setState(() {});
    });
  }

  void search() {
    final discountQueryBuilder = objectBox.discountBox.query(
      Discount_.title.contains(searchController.text, caseSensitive: false)
    )..order(Discount_.id, flags: Order.descending);
    discountStream = discountQueryBuilder.watch(triggerImmediately: true);
    discountStream.listen((event) {
      discountList = event.find();
      setState(() {});
    });
  }

  DiscountListItem _itemBuilder(Discount discount, int index) {
    return DiscountListItem(
      discount: discount,
      index: index,
    );
  }

  void refresh() {
    initializeDiscountStream();
    setState(() {});
  }

  void deleteAll() {
    objectBox.discountBox.removeAll();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteAllConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Discounts'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    'Are you sure you want to delete all discounts in the record?')
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
            FilledButton(
              onPressed: deleteAll,
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DiscountScreenHeader(
              search: search,
              searchController: searchController,
              refresh: refresh,
              addDiscount: navigateToAddDiscountScreen,
              deleteAll: showDeleteAllConfirmationDialog,
            ),
            const DiscountListHeader(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => _itemBuilder(discountList[index], index),
                shrinkWrap: true,
                itemCount: discountList.length,
                padding: const EdgeInsets.symmetric(horizontal: 15),
              )
            ),
          ],
        ),
      )
    );
  }
}