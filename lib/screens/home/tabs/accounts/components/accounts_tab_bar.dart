
import 'package:flutter/material.dart';

class AccountsScreenTabBar extends StatefulWidget {
  const AccountsScreenTabBar({Key? key}) : super(key: key);

  @override
  State<AccountsScreenTabBar> createState() => _AccountsScreenTabBarState();
}

class _AccountsScreenTabBarState extends State<AccountsScreenTabBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: const TabBar(
        tabs: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Employees',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Admins',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
