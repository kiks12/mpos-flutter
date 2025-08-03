
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/sale.dart';

class TransactionListTile extends StatefulWidget {
  const TransactionListTile({
    Key? key,
    required this.index,
    required this.sale,
  }) : super(key: key);

  final Sale sale;
  final int index;

  @override
  State<TransactionListTile> createState() => _TransactionListTileState();
}

class _TransactionListTileState extends State<TransactionListTile> {

  void navigateToTransactionScreen() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TransactionScreen(transaction: widget.transaction),
    //   ),
    // );
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
                  child: Text(widget.sale.transactionID.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.sale.subTotal),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.sale.discount),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.sale.totalAmount),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.sale.payment),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(widget.sale.change),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.sale.paymentMethod),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.sale.employeeName,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(widget.sale.date),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                  Text(DateFormat('HH:mm a').format(widget.sale.time)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
