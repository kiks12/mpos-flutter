
import 'package:flutter/material.dart';

class CashierControlPanel extends StatefulWidget {
  const CashierControlPanel({
    Key? key,
    required this.quantityController,
    required this.searchController,
    required this.searchProduct,
    required this.refresh,
  }) : super(key: key);

  final TextEditingController quantityController;
  final TextEditingController searchController;
  final void Function() searchProduct;
  final void Function() refresh;

  @override
  State<CashierControlPanel> createState() => CashierControlPanelState();
}

class CashierControlPanelState extends State<CashierControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                        maxLines: 1,
                        minLines: 1,
                        controller: widget.searchController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                          labelText: "Search",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)
                          )
                        ),
                      ),
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.search),
                  onPressed: widget.searchProduct,
                  label: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: 40,
                child: TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  keyboardType: TextInputType.number,
                  controller: widget.quantityController,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      labelText: "Quantity",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)
                      )
                  ),

                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton.filledTonal(
              onPressed: widget.refresh,
              icon: const Icon(Icons.refresh)
            ),
          )
        ],
      ),
    );
  }
}
