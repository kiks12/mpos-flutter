
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueSplitFigures extends StatefulWidget {
  const RevenueSplitFigures({Key? key, required this.revenues}) : super(key: key);

  final List<int> revenues;

  @override
  State<RevenueSplitFigures> createState() => _RevenueSplitFiguresState();
}

class _RevenueSplitFiguresState extends State<RevenueSplitFigures> {
  final currencyFormatter = NumberFormat.currency(symbol: "₱");
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(
                  width: 5, color: Theme.of(context).colorScheme.primary
                ),
              ),
              borderRadius: BorderRadius.circular(10),
              // boxShadow: const <BoxShadow>[
              //   BoxShadow(
              //     blurRadius: 7,
              //     color: Color.fromARGB(255, 216, 216, 216),
              //     offset: Offset(0, 10),
              //   )
              // ],
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cash:"),
                Text(currencyFormatter.format(widget.revenues[1])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                    left: BorderSide(
                        width: 5, color: Colors.blue
                    )
                ),
                borderRadius: BorderRadius.circular(10),
                // boxShadow: const <BoxShadow>[
                //   BoxShadow(
                //     blurRadius: 7,
                //     color: Color.fromARGB(255, 216, 216, 216),
                //     offset: Offset(0, 10),
                //   )
                // ],
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("GCash:"),
                  Text(currencyFormatter.format(widget.revenues[2])),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                  left: BorderSide(
                      width: 5, color: Colors.pink
                  )
              ),
              borderRadius: BorderRadius.circular(10),
              // boxShadow: const <BoxShadow>[
              //   BoxShadow(
              //     blurRadius: 7,
              //     color: Color.fromARGB(255, 216, 216, 216),
              //     offset: Offset(0, 10),
              //   )
              // ],
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Foodpanda:"),
                Text(currencyFormatter.format(widget.revenues[3])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                    left: BorderSide(
                        width: 5, color: Colors.green
                    )
                ),
                borderRadius: BorderRadius.circular(10),
                // boxShadow: const <BoxShadow>[
                //   BoxShadow(
                //     blurRadius: 7,
                //     color: Color.fromARGB(255, 216, 216, 216),
                //     offset: Offset(0, 10),
                //   )
                // ],
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Grab:"),
                  Text(currencyFormatter.format(widget.revenues[4])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
