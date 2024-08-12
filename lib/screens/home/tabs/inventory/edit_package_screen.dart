
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class EditPackageScreen extends StatefulWidget {
  const EditPackageScreen({Key? key, required this.packagedProduct}) : super(key: key);

  final PackagedProduct packagedProduct;

  @override
  State<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends State<EditPackageScreen> with TickerProviderStateMixin {

  final formKey = GlobalKey<FormState>();

  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController unitPriceTextController =
  TextEditingController(text: '0');
  final TextEditingController quantityTextController =
  TextEditingController(text: '0');

  final TextEditingController categoryTextController = TextEditingController();

  late TabController _categoriesTabController;
  List<String> _categories = [];
  List<String> _products = [];
  String _selectedProducts = "";
  File? _imageFile;
  bool imageExists = false;



  @override
  void initState() {
    super.initState();
    // _categories = getCategories();
    // _categories.add("Other");
    // _selectedCategory = widget.packagedProduct.category;
    initializeCategories();
    _categoriesTabController = TabController(length: _categories.length, initialIndex: 0, vsync: this);
    _categoriesTabController.addListener(() {
      initializeProductsAndPackages();
    });
    initializeProductsAndPackages();
    nameTextController.text = widget.packagedProduct.name;
    unitPriceTextController.text = widget.packagedProduct.price.toString();
    quantityTextController.text = widget.packagedProduct.quantity.toString();
    _imageFile = File(widget.packagedProduct.image);
    imageExists = _imageFile!.existsSync();
    _selectedProducts = widget.packagedProduct.category;
    setState(() {});
  }

  void initializeCategories() {
    _categories = [];
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
    if (category == "All") {
      productQuery.find().forEach((product) { _products.add(product.name); });
    } else {
      productQuery.find().where((element) => element.category == category).forEach((product) { _products.add(product.name); });
    }
    setState(() {});
  }

  // List<String> getCategories() {
  //   final query = objectBox.productBox.query().build();
  //   PropertyQuery<String> pq = query.property(Product_.category);
  //   pq.distinct = true;
  //   return pq.find();
  // }

  void updatePackage() {
    if (!formKey.currentState!.validate()) return;

    PackagedProduct packageToUpdate =
    objectBox.packagedProductBox.get(widget.packagedProduct.id) as PackagedProduct;

    packageToUpdate.name = nameTextController.text;
    packageToUpdate.price = int.parse(unitPriceTextController.text);
    packageToUpdate.category = _selectedProducts;
    packageToUpdate.image = _imageFile != null ? _imageFile!.path : "";
    packageToUpdate.quantity = int.parse(quantityTextController.text);

    objectBox.packagedProductBox.put(packageToUpdate);
    Fluttertoast.showToast(msg: "Successfully updated product information");

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> pickAndSaveImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = path.join(directory.path, '${DateTime.now()}.png');

        final savedImage = await imageFile.copy(imagePath);
        _imageFile = savedImage;
        imageExists = _imageFile!.existsSync();
        setState(() {});
      } else {
        Fluttertoast.showToast(msg: "No image selected");
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error picking and saving image: $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Package'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const HeaderTwo(
                        padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        text: 'Package Identifiers',
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          imageExists ?
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Image.file(_imageFile!, width: 150,),
                          ) : Container(),
                          FilledButton.tonalIcon(
                            onPressed: pickAndSaveImage,
                            icon: const Icon(Icons.image),
                            label: const Text("Select Image"),
                          ),
                        ],
                      ),
                      TextFormFieldWithLabel(
                        label: 'Package Name',
                        controller: nameTextController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        isPassword: false,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const HeaderTwo(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          text: 'Pricing and Quantity',
                        ),
                        TextFormFieldWithLabel(
                          label: 'Unit Price',
                          controller: unitPriceTextController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          isPassword: false,
                          isNumber: true,
                        ),
                        TextFormFieldWithLabel(
                          label: 'Quantity of Items in Package',
                          controller: quantityTextController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          isPassword: false,
                          isNumber: true,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.45,
                  child: DefaultTabController(
                      length: _categories.length,
                      child: Column(
                        children: [
                          TabBar(
                              isScrollable: true,
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
                  ),
                ),
                // SizedBox(
                //   width: MediaQuery
                //       .of(context)
                //       .size
                //       .width * 0.45,
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const HeaderTwo(
                //         padding:
                //         EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //         text: 'Category',
                //       ),
                //       DropdownButton(
                //           isExpanded: true,
                //           padding: const EdgeInsets.symmetric(
                //               horizontal: 10, vertical: 10),
                //           value: _selectedCategory,
                //           items: _categories.map((String e) {
                //             return DropdownMenuItem<String>(
                //                 value: e, child: Text(e));
                //           }).toList(),
                //           onChanged: (String? newValue) {
                //             setState(() {
                //               _selectedCategory = newValue!;
                //             });
                //           }
                //       ),
                //       if (_selectedCategory == "Other")
                //         TextFormFieldWithLabel(
                //           label: 'Category',
                //           controller: categoryTextController,
                //           padding: const EdgeInsets.symmetric(
                //               vertical: 20, horizontal: 20),
                //           isPassword: false,
                //         ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            child: Text('Back'),
                          ),
                        ),
                        FilledButton(
                          onPressed: updatePackage,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            child: Text('Update Package'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
