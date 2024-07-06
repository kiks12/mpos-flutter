
import 'package:flutter/material.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/screens/home/tabs/discounts/edit_discount_screen.dart';

class DiscountListHeader extends StatelessWidget {
  const DiscountListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
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
                'Title',
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
                'Operation',
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
                'Value',
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
                'Type',
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
                'Products & Packages',
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


class DiscountListItem extends StatefulWidget {
  const DiscountListItem({Key? key, required this.discount, required this.index}) : super(key : key);

  final Discount discount;
  final int index;

  @override
  State<DiscountListItem> createState() => _DiscountListItemState();
}

class _DiscountListItemState extends State<DiscountListItem> {

  void navigateToEditDiscountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDiscountScreen(discount: widget.discount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: navigateToEditDiscountScreen,
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
                  child: Text(widget.discount.id.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.discount.title),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(widget.discount.operation),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                  Text(widget.discount.value.toString()),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                  Text(widget.discount.type),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                  Text(widget.discount.products.replaceAll("___", " ")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
