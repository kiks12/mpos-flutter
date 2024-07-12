
import 'package:flutter/material.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/objectbox.g.dart';

class EditDiscountScreen extends StatefulWidget {
  const EditDiscountScreen({Key? key, required this.discount}) : super(key: key);

  final Discount discount;

  @override
  State<EditDiscountScreen> createState() => _EditDiscountScreenState();
}

class _EditDiscountScreenState extends State<EditDiscountScreen> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  late TabController _categoriesTabController;
  final List<String> _categories = [];
  List<String> _products = [];
  static const discountOperations = ['PERCENTAGE', 'FIXED'];
  static const discountTypes = ['SPECIFIC', 'TOTAL'];
  var _selectedOperation = "";
  var _selectedDiscountType = "";
  var _selectedProducts = "";

  @override
  void initState() {
    super.initState();
    initializeCategories();
    _categoriesTabController = TabController(length: _categories.length, initialIndex: 0, vsync: this);
    _categoriesTabController.addListener(() {
      initializeProductsAndPackages();
    });
    initializeProductsAndPackages();
    titleController.text = widget.discount.title;
    valueController.text = widget.discount.value.toString();
    _selectedDiscountType = widget.discount.type;
    _selectedOperation = widget.discount.operation;
    _selectedProducts = widget.discount.products;
    setState(() {});
  }

  void initializeCategories() {
    _categories.add("All");
    final query = objectBox.productBox.query().build();
    PropertyQuery<String> pq = query.property(Product_.category);
    pq.distinct = true;
    pq.find().forEach((element) { _categories.add(element); });
    setState(() {});
  }

  void initializeProductsAndPackages() {
    _products = [];
    final category = _categories[_categoriesTabController.index];
    final productQuery = objectBox.productBox.query().build();
    final packageQuery = objectBox.packagedProductBox.query().build();
    if (category == "All") {
      packageQuery.find().forEach((package) { _products.add(package.name); });
      productQuery.find().forEach((product) { _products.add(product.name); });
    } else {
      packageQuery.find().where((element) => element.category.contains(category)).forEach((package) { _products.add(package.name); });
      productQuery.find().where((element) => element.category == category).forEach((product) { _products.add(product.name); });
    }
    setState(() {});
  }

  void navigateToPreviousScreen() {
    Navigator.of(context).pop();
  }

  void updateDiscount() {
    if (!formKey.currentState!.validate()) return;

    Discount? discountToUpdate = objectBox.discountBox.get(widget.discount.id);

    if (discountToUpdate != null) {
      discountToUpdate.value = int.parse(valueController.text);
      discountToUpdate.type = _selectedDiscountType;
      discountToUpdate.title = titleController.text;
      discountToUpdate.operation = _selectedOperation;
      discountToUpdate.products = _selectedProducts;

      objectBox.discountBox.put(discountToUpdate);

      Navigator.of(context).pop();
    }
  }

  void deleteDiscount() {
    objectBox.discountBox.remove(widget.discount.id);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Discount'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    'Are you sure you want to delete this discount in the record?')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              onPressed: deleteDiscount,
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Edit Discount'),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red
              ),
              onPressed: showDeleteConfirmationDialog,
              child: const Text("Delete"),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 25, 0,0),
                    child: Text("Enter the name of the discount: "),
                  ),
                  TextFormFieldWithLabel(
                    label: "Title",
                    controller: titleController,
                    padding: const EdgeInsets.all(10),
                    isPassword: false,
                    isNumber: false,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 25, 0,0),
                    child: Text("Select the operation of discount: "),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedOperation,
                      items: discountOperations.map((e) {
                        return DropdownMenuItem<String>(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (String? newVal) {
                        setState(() {
                          _selectedOperation = newVal!;
                        });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 25, 0,0),
                    child: Text("Select the type of discount: "),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButton(
                      isExpanded: true,
                      value: _selectedDiscountType,
                      items: discountTypes.map((e) {
                        return DropdownMenuItem<String>(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (value) {
                        _selectedDiscountType = value.toString();
                        setState(() {});
                      },
                    ),
                  ),
                  _selectedDiscountType == "SPECIFIC" ? const Padding(
                    padding: EdgeInsets.fromLTRB(0, 25, 0,0),
                    child: Text("Products and Packages"),
                  ) : Container(),
                  _selectedDiscountType == "SPECIFIC" ? DefaultTabController(
                      length: _categories.length,
                      child: Column(
                        children: [
                          TabBar(
                              controller: _categoriesTabController,
                              tabs: _categories.map((e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical:10),
                                child: Text(e),
                              )).toList()
                          ),
                          SizedBox(
                            height: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Select all that applies from the choices below"),
                                Row(
                                  children: [
                                    TextButton(
                                        onPressed: (){
                                          _selectedProducts = "";
                                          setState(() {});
                                        },
                                        child: const Text("Clear")
                                    ),
                                    FilledButton.tonal(
                                        onPressed: (){
                                          final productList = [];
                                          for (var element in _products) {
                                            productList.add(element);
                                          }
                                          _selectedProducts = productList.join("___");
                                          setState(() {});
                                        },
                                        child: const Text("Select All")
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 250,
                            child: TabBarView(
                                children: _categories.map((e) {
                                  return GridView.count(
                                    childAspectRatio: (1/.3),
                                    crossAxisCount: 3,
                                    children: _products.map((e) =>
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: GestureDetector(
                                            onTap: () {
                                              final productsList = _selectedProducts.split("___");
                                              if (productsList.contains(e)) {
                                                productsList.remove(e);
                                              } else {
                                                productsList.add(e);
                                              }
                                              _selectedProducts = productsList.join("___");
                                              setState(() {});
                                            },
                                            child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                decoration: BoxDecoration(
                                                    color: _selectedProducts.contains(e) ? Theme.of(context).colorScheme.secondaryContainer : Colors.transparent,
                                                    border: Border.all(width: 0.5, color: _selectedProducts.contains(e) ? Theme.of(context).colorScheme.secondary : Colors.black26),
                                                    borderRadius: BorderRadius.circular(50)
                                                ),
                                                child: Row(
                                                  children: [
                                                    Checkbox(value: _selectedProducts.contains(e), onChanged: (val) {}),
                                                    Flexible(child: Text(e)),
                                                  ],
                                                )
                                            ),
                                          ),
                                        )
                                    ).toList(),
                                  );
                                }).toList()
                            ),
                          )
                        ],
                      )
                  ) : Container(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 25, 0,0),
                    child: Text("Enter the value of the discount: "),
                  ),
                  TextFormFieldWithLabel(
                    label: "Value",
                    controller: valueController,
                    padding: const EdgeInsets.all(10),
                    isPassword: false,
                    isNumber: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: TextButton(onPressed: navigateToPreviousScreen, child: const Text("Cancel")),
                        ),
                        FilledButton(onPressed: updateDiscount, child: const Text("Update"))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
