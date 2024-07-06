
import 'package:flutter/material.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart';

class InventoryHeader extends StatefulWidget {
  const InventoryHeader({
    Key? key,
    required this.searchController,
    required this.onPressed,
    required this.refresh,
    required this.deleteAll,
    required this.addProduct,
    required this.inventoryValue,
    required this.showProductWithLessThan,
    required this.onCategoryDropdownChange
  }) : super(key: key);

  final TextEditingController searchController;
  final void Function() onPressed;
  final void Function() refresh;
  final void Function() deleteAll;
  final void Function() addProduct;
  final void Function(int) showProductWithLessThan;
  final void Function(String) onCategoryDropdownChange;
  final String inventoryValue;

  @override
  State<InventoryHeader> createState() => _InventoryHeaderState();
}

class _InventoryHeaderState extends State<InventoryHeader> {
  final quantitiesDropdown = ["All", 100, 50, 25, 15, 10, 5, 0];
  String selectedQuantity = "All";
  final categoriesDropdown = [];
  String selectedCategory = "";

  @override
  void initState() {
    super.initState();
    categoriesDropdown.add("All");
    final allProductCategories = getCategories();
    for (var element in allProductCategories) {categoriesDropdown.add(element); }
    selectedCategory = "All";
    setState(() {});
  }

  List<String> getCategories() {
    final query = objectBox.productBox.query().build();
    PropertyQuery<String> pq = query.property(Product_.category);
    pq.distinct = true;
    return pq.find();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              HeaderOne(
                  padding: const EdgeInsets.all(0),
                  text: 'Inventory  |  ${widget.inventoryValue}'),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 300,
                      height: 40,
                      child: TextFormField(
                        maxLines: 1,
                        minLines: 1,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          labelText: "Search",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)
                          )
                        ),
                        controller: widget.searchController,
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.search),
                    onPressed: widget.onPressed,
                    label: const Text('Search'),
                  ),
                  IconButton.filledTonal(
                      onPressed: widget.refresh,
                      icon: const Icon(Icons.refresh)
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Select Quantity: "),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: DropdownButton(
                            isExpanded: true,
                            value: selectedQuantity,
                            items: quantitiesDropdown.map((e) => DropdownMenuItem<String>(value: e.toString(), child: Text(e.toString()))).toList(),
                            onChanged: (newVal){
                              selectedQuantity = newVal.toString();
                              if (newVal == "All") return widget.refresh();
                              widget.showProductWithLessThan(int.parse(newVal.toString()));
                              setState(() {});
                              return;
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Select Category: "),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: DropdownButton(
                              isExpanded: true,
                              value: selectedCategory,
                              items: categoriesDropdown.map((e) => DropdownMenuItem<String>(value: e.toString(), child: Text(e.toString()))).toList(),
                              onChanged: (newVal){
                                selectedCategory = newVal.toString();
                                if (newVal == "All") return widget.refresh();
                                widget.onCategoryDropdownChange(newVal.toString());
                                setState(() {});
                                return;
                              }
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                    onPressed: widget.addProduct,
                    label: const Text('Add Product'),
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
