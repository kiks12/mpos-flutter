import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProductVariantControllers {
  int index;
  int id;
  TextEditingController nameController;
  TextEditingController quantityController;
  TextEditingController unitPriceController;
  TextEditingController totalPriceController;

  void calculateTotalPrice() {
    final quantity = quantityController.text;
    final unitPrice = unitPriceController.text;
    if (quantity.isEmpty || unitPrice.isEmpty) return;
    totalPriceController.text = (int.parse(quantity) * int.parse(unitPrice)).toString();
  }

  void dispose() {
    
  }

  ProductVariantControllers({
    this.id = 0,
    required this.index,
    required this.nameController,
    required this.quantityController,
    required this.unitPriceController,
    required this.totalPriceController
  }) {
    quantityController.addListener(calculateTotalPrice);
    unitPriceController.addListener(calculateTotalPrice);
  }
}

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController barcodeTextController = TextEditingController();
  final TextEditingController unitPriceTextController =
      TextEditingController(text: '0');
  final TextEditingController quantityTextController =
      TextEditingController(text: '0');

  bool _withVariant = false;
  int _totalPrice = 0;
  final List<DateTime> _expirationDates = [];
  final TextEditingController categoryTextController = TextEditingController();
  List<String> _categories = [];
  String _selectedCategory = "";

  File? _imageFile;
  bool imageExists = false;

  List<ProductVariantControllers> _variants = [];

  @override
  void initState() {
    super.initState();
    for (var exp in widget.product.expirationDates) {
      _expirationDates.add(exp.date);
    }
    nameTextController.text = widget.product.name;
    unitPriceTextController.text = widget.product.unitPrice.toString();
    quantityTextController.text = widget.product.quantity.toString();
    _selectedCategory = widget.product.category;
    _totalPrice = widget.product.totalPrice;
    _withVariant = widget.product.withVariant;
    _categories = _getCategories();
    _categories.add("Other");
    _imageFile = File(widget.product.image);
    imageExists = _imageFile!.existsSync();

    _variants = [];
    for (var variant in widget.product.variants) {
      final nameController = TextEditingController(text: variant.name);
      final quantityController = TextEditingController(text: variant.quantity.toString());
      final unitPriceController = TextEditingController(text: variant.unitPrice.toString());
      final totalPriceController = TextEditingController(text: variant.totalPrice.toString());
      _variants.add(ProductVariantControllers(
        id: variant.id,
        index: _variants.length + 1,
        nameController: nameController,
        quantityController: quantityController,
        unitPriceController: unitPriceController,
        totalPriceController: totalPriceController
      ));
    }

    setState(() {});
  }

  // double _expirationDateListViewHeight() {
  //   return MediaQuery.of(context).size.height * 0.1 * _expirationDates.length;
  // }

  void updateProduct() {
    if (!formKey.currentState!.validate()) return;

    Product productToUpdate =
        objectBox.productBox.get(widget.product.id) as Product;

    productToUpdate.name = nameTextController.text;
    productToUpdate.quantity = _withVariant ? _variants.fold(0, (prev, curr) => prev + int.parse(curr.quantityController.text)): int.parse(quantityTextController.text);
    productToUpdate.unitPrice = _withVariant ? int.parse(_variants.reduce((a, b) => int.parse(a.unitPriceController.text) < int.parse(b.unitPriceController.text) ? a : b).unitPriceController.text) : int.parse(unitPriceTextController.text);
    productToUpdate.totalPrice = _withVariant ? _variants.fold(0, (prev, curr) => prev + int.parse(curr.totalPriceController.text)): _totalPrice;
    productToUpdate.category = (_selectedCategory == "Other") ? categoryTextController.text : _selectedCategory;
    productToUpdate.image = _imageFile != null ? _imageFile!.path : "";
    productToUpdate.withVariant = _withVariant;

    for (var variant in _variants) {
      if (variant.id == 0) {
        final productVariant = ProductVariant(
          name: variant.nameController.text,
          unitPrice: int.parse(variant.unitPriceController.text),
          quantity: int.parse(variant.quantityController.text),
          totalPrice: int.parse(variant.totalPriceController.text),
          image: ""
        );
        productToUpdate.variants.add(productVariant);
      } else {
        final productVariant = objectBox.productVariantBox.get(variant.id) as ProductVariant;
        productVariant.name = variant.nameController.text;
        productVariant.unitPrice = int.parse(variant.unitPriceController.text);
        productVariant.quantity = int.parse(variant.quantityController.text);
        productVariant.totalPrice = int.parse(variant.totalPriceController.text);
        objectBox.productVariantBox.put(productVariant);
      }
    }

    objectBox.productBox.put(productToUpdate);
    Fluttertoast.showToast(msg: "Successfully updated product information");

    if (context.mounted){
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

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

  // Padding _expirationDateBuilder(BuildContext context, int index) {
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
  //               DateFormat('yyyy-MM-dd').format(_expirationDates[index]),
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

  void withVariantOnChange() {
    _withVariant = !_withVariant;
    setState(() {});
  }

  void deleteVariant(ProductVariant productVariant) {
    objectBox.productVariantBox.remove(productVariant.id);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
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
                          children: <Widget>[
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const HeaderTwo(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          readOnly: false,
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
                              if (productVariantController.id != 0) {
                                final productVariant = objectBox.productVariantBox.get(productVariantController.id) as ProductVariant;
                                deleteVariant(productVariant);
                              }
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
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.45,
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       const HeaderTwo(
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //         text: 'Expiration Date',
                //       ),
                //       SizedBox(
                //         height: _expirationDateListViewHeight(),
                //         child: Column(
                //           children: [
                //             Expanded(
                //               child: ListView.builder(
                //                 itemCount: _expirationDates.length,
                //                 itemBuilder: _expirationDateBuilder,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
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
                          onPressed: updateProduct,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            child: Text('Update'),
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
