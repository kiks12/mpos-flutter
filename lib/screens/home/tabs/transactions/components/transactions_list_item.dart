
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/screens/home/tabs/transactions/transaction_screen.dart';

class TransactionListTile extends StatefulWidget {
  const TransactionListTile({
    Key? key,
    required this.index,
    required this.transaction,
  }) : super(key: key);

  final Transaction transaction;
  final int index;

  @override
  State<TransactionListTile> createState() => _TransactionListTileState();
}

class _TransactionListTileState extends State<TransactionListTile> {

  void navigateToTransactionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionScreen(transaction: widget.transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: navigateToTransactionScreen,
      child: Container(
        decoration: BoxDecoration(
          color: widget.index % 2 == 0
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondaryContainer,
          border: const Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 232, 232, 232),
              width: 0.7,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(widget.transaction.transactionID.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.transaction.subTotal),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.transaction.discount),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.transaction.totalAmount),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.transaction.payment),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.transaction.change),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.transaction.paymentMethod),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.transaction.user.target != null ? '${widget.transaction.user.target?.lastName}, ${widget.transaction.user.target?.firstName}' : "NOT FOUND",
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(widget.transaction.date),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                  Text(DateFormat('HH:mm a').format(widget.transaction.time)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
