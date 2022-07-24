import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/manageExpirationDatesScreen.dart';

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
  @override
  void initState() {
    super.initState();
  }

  Container _expiringItemBuilder(BuildContext context, int index) {
    final curr = widget.expiringNotifications[index];
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
              builder: ((context) => ManageExpirationDatesScreen(
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
                    '${curr.quantity - curr.expired - curr.sold}  ${curr.productExp.target!.name} will expire at ${DateFormat('yyyy-MM-dd').format(curr.date)}')
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _expiredItemBuilder(BuildContext context, int index) {
    final curr = widget.expiringNotifications[index];
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
              builder: ((context) => ManageExpirationDatesScreen(
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
                    '${curr.quantity - curr.expired - curr.sold}  ${curr.productExp.target!.name} expired at ${DateFormat('yyyy-MM-dd').format(curr.date)}')
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
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeaderOne(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      text: 'Notifications',
                    ),
                    const HeaderTwo(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      text: 'Expired',
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.2,
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: widget.expiredNotifications.isNotEmpty
                          ? ListView.builder(
                              itemBuilder: _expiredItemBuilder,
                              itemCount: widget.expiredNotifications.length,
                            )
                          : const Center(child: Text('No Expired Products')),
                    ),
                    const HeaderTwo(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      text: 'Expiring',
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.2,
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: widget.expiringNotifications.isNotEmpty
                          ? ListView.builder(
                              itemBuilder: _expiringItemBuilder,
                              itemCount: widget.expiringNotifications.length,
                            )
                          : const Center(child: Text('No Expiring Products')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
