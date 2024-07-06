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

  int _totalPrice = 0;
  final List<DateTime> _expirationDates = [];
  final TextEditingController categoryTextController = TextEditingController();
  List<String> _categories = [];
  String _selectedCategory = "";

  File? _imageFile;
  bool imageExists = false;

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
    _categories = _getCategories();
    _categories.add("Other");
    _imageFile = File(widget.product.image);
    imageExists = _imageFile!.existsSync();
    setState(() {});
  }

  double _expirationDateListViewHeight() {
    return MediaQuery.of(context).size.height * 0.1 * _expirationDates.length;
  }

  void updateProduct() {
    if (!formKey.currentState!.validate()) return;

    Product productToUpdate =
        objectBox.productBox.get(widget.product.id) as Product;

    productToUpdate.name = nameTextController.text;
    productToUpdate.unitPrice = int.parse(unitPriceTextController.text);
    productToUpdate.totalPrice = _totalPrice;
    productToUpdate.category = (_selectedCategory == "Other") ? categoryTextController.text : _selectedCategory;
    productToUpdate.image = _imageFile != null ? _imageFile!.path : "";

    objectBox.productBox.put(productToUpdate);
    Fluttertoast.showToast(msg: "Successfully updated product information");

    Navigator.of(context).pop();
    Navigator.of(context).pop();
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

  Padding _expirationDateBuilder(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 213, 213, 213),
            width: 0.7,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(_expirationDates[index]),
              ),
            ],
          ),
        ),
      ),
    );
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
        title: const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
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
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
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
                        readOnly: true,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const HeaderTwo(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        text: 'Expiration Date',
                      ),
                      SizedBox(
                        height: _expirationDateListViewHeight(),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: _expirationDates.length,
                                itemBuilder: _expirationDateBuilder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
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
