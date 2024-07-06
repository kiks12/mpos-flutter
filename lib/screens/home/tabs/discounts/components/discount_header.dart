
import 'package:flutter/material.dart';
import 'package:mpos/components/header_one.dart';

class DiscountScreenHeader extends StatefulWidget {
  const DiscountScreenHeader({
    Key? key,
    required this.searchController,
    required this.refresh,
    required this.search,
    required this.deleteAll,
    required this.addDiscount,
  }) : super(key: key);

  final TextEditingController searchController;
  final void Function() refresh;
  final void Function() search;
  final void Function() deleteAll;
  final void Function() addDiscount;

  @override
  State<DiscountScreenHeader> createState() => _DiscountScreenHeaderState();
}

class _DiscountScreenHeaderState extends State<DiscountScreenHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const HeaderOne(
                  padding: EdgeInsets.all(0),
                  text: 'Discounts'
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 300,
                      height: 40,
                      child: TextFormField(
                        maxLines: 1,
                        minLines: 1,
                        controller: widget.searchController,
                        decoration: InputDecoration(
                            labelText: "Search",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)
                            )
                        ),
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.search),
                    onPressed: widget.search,
                    label: const Text('Search'),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.refresh),
                    onPressed: widget.refresh,
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.delete),
                      style: FilledButton.styleFrom(
                        foregroundColor: Colors.red, backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
                      ),
                      onPressed: widget.deleteAll,
                      label: const Text('Delete All'),
                    ),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: widget.addDiscount,
                    label: const Text('Add Discount'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
