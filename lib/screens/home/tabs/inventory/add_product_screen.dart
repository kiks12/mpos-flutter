import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/expiration_dates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/inventory/edit_product_screen.dart';
import 'package:mpos/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController barcodeTextController = TextEditingController();
  final TextEditingController unitPriceTextController =
      TextEditingController(text: '0');
  final TextEditingController quantityTextController =
      TextEditingController(text: '0');

  final TextEditingController categoryTextController = TextEditingController();

  int _totalPrice = 0;
  final DateTime _expirationDates = DateTime.now();
  // DateTime? _selectedDate;
  List<String> _categories = [];
  String _selectedCategory = "";

  File? _imageFile;

  final List<ProductVariantControllers> _variants = [];
  bool _withVariant = false;

  @override
  void initState() {
    super.initState();
    _categories = _getCategories();
    _categories.add("Other");
    _selectedCategory = _categories[0];
    setState(() {});
  }

  // double _expirationDateListViewHeight() {
  //   return MediaQuery.of(context).size.height * 0.09 * 1;
  // }

  Future<void> saveProductInServer(Product product) async {
    try {
      final serverAccount = Utils().getServerAccount();
      final storeName = Utils().getStore();
      firestore.FirebaseFirestore db = firestore.FirebaseFirestore.instance;
      final snapshot = await db.collection("users").doc(serverAccount).collection("stores").where("storeName", isEqualTo: storeName).get();
      final documentId = snapshot.docs.first.id;
      final productsRef = db.collection("users").doc(serverAccount).collection("stores").doc(documentId).collection("products");
      final productJson = product.toJson();
      productJson["POS"] = Utils().getPOS();
      productJson["type"] = "PRODUCT";
      await productsRef.add(productJson);
    } on firestore.FirebaseException catch(e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  void addProduct() async {
    if (!formKey.currentState!.validate()) return;

    Product newProduct = Product(
      name: nameTextController.text,
      category: (_selectedCategory == "Other") ? categoryTextController.text : _selectedCategory,
      unitPrice: int.parse(unitPriceTextController.text),
      quantity: int.parse(quantityTextController.text),
      totalPrice: _totalPrice,
      image: _imageFile != null ? _imageFile!.path : "",
      withVariant: _withVariant,
    );

    ExpirationDate newExpirationDate = ExpirationDate(
      date: _expirationDates,
      quantity: int.parse(quantityTextController.text),
      expired: 0,
      sold: 0,
    );

    for (var variant in _variants) {
      final productVariant = ProductVariant(
          name: variant.nameController.text,
          unitPrice: int.parse(variant.unitPriceController.text),
          quantity: int.parse(variant.quantityController.text),
          totalPrice: int.parse(variant.totalPriceController.text),
          image: ""
      );
      newProduct.variants.add(productVariant);
    }

    newProduct.expirationDates.add(newExpirationDate);
    objectBox.productBox.put(newProduct);
    if (Utils().getServerAccount() != "" && Utils().getStore() != "" && Utils().getPOS() != "") await saveProductInServer(newProduct);
    Fluttertoast.showToast(msg: "Successfully created new product");
    if (mounted) Navigator.of(context).pop();
  }

  // void _editExpirationDate() async {
  //   setState(() {
  //     _selectedDate = _expirationDates;
  //   });
  //   final DateTime? selected = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2010),
  //     lastDate: DateTime(2025),
  //   );
  //   if (selected != null && selected != _selectedDate) {
  //     setState(() {
  //       _selectedDate = selected;
  //       _expirationDates = _selectedDate as DateTime;
  //     });
  //   }
  // }

  void _calculateTotalPrice() {
    setState(() {
      _totalPrice = int.parse(unitPriceTextController.text) *
          int.parse(quantityTextController.text);
    });
  }

  List<String> _getCategories() {
    final query = objectBox.productBox.query().build();
    PropertyQuery<String> pq = query.property(Product_.category);
    pq.distinct = true;
    return pq.find();
  }

  // Padding _expirationDateBuilder(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: const Color.fromARGB(255, 213, 213, 213),
  //           width: 0.7,
  //         ),
  //         borderRadius: BorderRadius.circular(40),
  //       ),
  //       child: ListTile(
  //         title: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               DateFormat('yyyy-MM-dd').format(_expirationDates as DateTime),
  //             ),
  //             TextButton(
  //               onPressed: () => _editExpirationDate(),
  //               child: const Text('change'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> pickAndSaveImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = path.join(directory.path, '${DateTime.now()}.png');

        final savedImage = await imageFile.copy(imagePath);
        _imageFile = savedImage;
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

  void withVariantOnChange() {
    _withVariant = !_withVariant;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const HeaderTwo(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        text: 'Product Identifiers',
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _imageFile != null ?
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
                        label: 'Product Name',
                        controller: nameTextController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        isPassword: false,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HeaderTwo(
                              padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              text: 'Category',
                            ),
                            DropdownButton(
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                value: _selectedCategory,
                                items: _categories.map((String e) {
                                  return DropdownMenuItem<String>(value: e, child: Text(e));
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue!;
                                  });
                                }
                            ),
                            if (_selectedCategory == "Other")
                              TextFormFieldWithLabel(
                                label: 'Category',
                                controller: categoryTextController,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                isPassword: false,
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: GestureDetector(
                          onTap: withVariantOnChange,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(value: _withVariant, onChanged: (e) => withVariantOnChange()),
                              const Text("Product with Variants")
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_withVariant) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const HeaderTwo(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            text: 'Pricing and Stock',
                          ),
                          TextFormFieldWithLabel(
                            onChanged: (String str) =>
                                str.isNotEmpty ? _calculateTotalPrice() : () {},
                            label: 'Unit Price',
                            controller: unitPriceTextController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            isPassword: false,
                            isNumber: true,
                          ),
                          TextFormFieldWithLabel(
                            onChanged: (String str) =>
                                str.isNotEmpty ? _calculateTotalPrice() : () {},
                            label: 'Quantity',
                            controller: quantityTextController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            isPassword: false,
                            isNumber: true,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 7, 20, 50),
                            child: HeaderTwo(
                              padding: const EdgeInsets.all(0),
                              text:
                                  'Total Price: ${NumberFormat.currency(symbol: '₱').format(_totalPrice)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const HeaderTwo(padding: EdgeInsets.fromLTRB(10, 30, 10, 10), text: "Variants"),
                  for (var productVariantController in _variants) ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.60,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormFieldWithLabel(
                                readOnly: false,
                                label: 'Name',
                                controller: productVariantController.nameController,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                isPassword: false,
                                isNumber: false,
                              ),
                            ),
                            Expanded(
                              child: TextFormFieldWithLabel(
                                readOnly: false,
                                label: 'Quantity',
                                controller: productVariantController.quantityController,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                isPassword: false,
                                isNumber: true,
                              ),
                            ),
                            Expanded(
                              child: TextFormFieldWithLabel(
                                readOnly: false,
                                label: 'UnitPrice',
                                controller: productVariantController.unitPriceController,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                isPassword: false,
                                isNumber: true,
                              ),
                            ),
                            Expanded(
                              child: TextFormFieldWithLabel(
                                readOnly: true,
                                label: 'TotalPrice',
                                controller: productVariantController.totalPriceController,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                isPassword: false,
                                isNumber: true,
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.delete), onPressed: () {
                              _variants.removeWhere((variant) => variant.index == productVariantController.index);
                              setState((){});
                            },),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.60,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: OutlinedButton(
                            onPressed: () {
                              final nameController = TextEditingController();
                              final quantityController = TextEditingController();
                              final unitPriceController = TextEditingController();
                              final totalPriceController = TextEditingController();
                              _variants.add(ProductVariantControllers(
                                  index: _variants.length + 1,
                                  nameController: nameController,
                                  quantityController: quantityController,
                                  unitPriceController: unitPriceController,
                                  totalPriceController: totalPriceController
                              ));
                              setState(() {});
                            },
                            child: const Text("Add Variant")
                        ),
                      )
                  )
                ],
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 30),
                //   child: SizedBox(
                //     width: MediaQuery.of(context).size.width * 0.45,
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: <Widget>[
                //         const HeaderTwo(
                //           padding: EdgeInsets.symmetric(
                //               horizontal: 20, vertical: 10),
                //           text: 'Expiration Date',
                //         ),
                //         SizedBox(
                //           height: _expirationDateListViewHeight(),
                //           child: Column(
                //             children: [
                //               Expanded(
                //                 child: _expirationDateBuilder(context),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                          onPressed: addProduct,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            child: Text('Add Product'),
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
