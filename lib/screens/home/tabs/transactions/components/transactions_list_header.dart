
import 'package:flutter/material.dart';

class TransactionsListHeader extends StatelessWidget {
  const TransactionsListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
      // padding: const EdgeInsets.5
      child: Row(
        children: <Widget>[
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
                'Sub-Total',
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
                'Discount',
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
                'Total',
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
                'Payment',
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
                'Change',
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
                'Payment Method',
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
                'Cashier',
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
                'Date',
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
                'Time',
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
                'Synced',
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
