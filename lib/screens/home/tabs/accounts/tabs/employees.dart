
import 'package:flutter/material.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/screens/home/tabs/accounts/components/account_list_item.dart';

class EmployeesAccountsTab extends StatefulWidget {
  const EmployeesAccountsTab({Key? key, required this.employeeList}) : super(key: key);

  final List<Account> employeeList;

  @override
  State<EmployeesAccountsTab> createState() => _EmployeesAccountsTabState();
}

class _EmployeesAccountsTabState extends State<EmployeesAccountsTab> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _itemBuilder(Account account) {
      return AccountListTile(account: account);
  }

  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
      itemBuilder: (context, index) => _itemBuilder(widget.employeeList[index]),
      shrinkWrap: true,
      itemCount: widget.employeeList.length,
      padding: const EdgeInsets.all(10),
    );
  }
}
