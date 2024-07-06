import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/models/expiration_dates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/manage_quantities_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    Key? key,
    required this.expiringNotifications,
    required this.expiredNotifications,
  }) : super(key: key);

  final List<ExpirationDate> expiringNotifications;
  final List<ExpirationDate> expiredNotifications;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<ExpirationDate> expiredNotifications = [];
  List<ExpirationDate> expiringNotifications = [];

  @override
  void initState() {
    super.initState();

    expiredNotifications = widget.expiredNotifications.where((element) => element.productExp.target != null).toList();
    expiringNotifications = widget.expiringNotifications.where((element) => element.productExp.target != null).toList();
    setState(() {});
  }

  Container _expiringItemBuilder(BuildContext context, ExpirationDate expirationDate) {
    final curr = expirationDate;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.blueGrey,
            width: 0.2,
          ),
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => ManageQuantitiesScreen(
                    product: curr.productExp.target as Product,
                  )),
            ),
          );
        },
        title: Column(
          children: [
            Row(
              children: [
                Text(
                    '${curr.quantity - curr.expired - curr.sold} ${curr.productExp.target!.name} will expire at ${DateFormat('yyyy-MM-dd').format(curr.date)}')
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _expiredItemBuilder(BuildContext context, ExpirationDate expirationDate) {
    final curr = expirationDate;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.blueGrey,
            width: 0.2,
          ),
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => ManageQuantitiesScreen(
                    product: curr.productExp.target as Product,
                  )),
            ),
          );
        },
        title: Column(
          children: [
            Row(
              children: [
                Text(
                    '${curr.quantity - curr.expired - curr.sold} ${curr.productExp.target!.name} expired at ${DateFormat('yyyy-MM-dd').format(curr.date)}')
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderOne(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  text: 'Notifications',
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const HeaderTwo(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            text: 'Expired',
                          ),
                          if (expiredNotifications.isEmpty) const Center(child: Text('No Expired Products')),
                          for (var expired in expiredNotifications) if (expired.productExp.target != null) _expiredItemBuilder(context, expired),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const HeaderTwo(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            text: 'Expiring',
                          ),
                          if (expiringNotifications.isEmpty) const Center(child: Text('No Expiring Products')),
                          for (var expiring in expiringNotifications) if (expiring.productExp.target != null) _expiringItemBuilder(context, expiring),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
