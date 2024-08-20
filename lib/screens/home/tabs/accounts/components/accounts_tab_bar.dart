
import 'package:flutter/material.dart';

class AccountsScreenTabBar extends StatefulWidget {
  const AccountsScreenTabBar({Key? key, required this.employeesCount, required this.adminsCount}) : super(key: key);

  final int employeesCount;
  final int adminsCount;

  @override
  State<AccountsScreenTabBar> createState() => _AccountsScreenTabBarState();
}

class _AccountsScreenTabBarState extends State<AccountsScreenTabBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TabBar(
        tabs: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Employees (${widget.employeesCount})',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Admins (${widget.adminsCount})',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
