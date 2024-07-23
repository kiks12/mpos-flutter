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
  DateTime? _expirationDates = DateTime.now();
  DateTime? _selectedDate;
  List<String> _categories = [];
  String _selectedCategory = "";

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    setState(() {
      _categories = _getCategories();
      _categories.add("Other");
      _selectedCategory = _categories[0];
    });
  }

  double _expirationDateListViewHeight() {
    return MediaQuery.of(context).size.height * 0.09 * 1;
  }

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
    );

    ExpirationDate newExpirationDate = ExpirationDate(
      date: _expirationDates as DateTime,
      quantity: int.parse(quantityTextController.text),
      expired: 0,
      sold: 0,
    );

    newProduct.expirationDates.add(newExpirationDate);
    objectBox.productBox.put(newProduct);
    if (Utils().getServerAccount() != "" && Utils().getStore() != "" && Utils().getPOS() != "") await saveProductInServer(newProduct);
    Fluttertoast.showToast(msg: "Successfully created new product");
    if (mounted) Navigator.of(context).pop();
  }

  void _editExpirationDate() async {
    setState(() {
      _selectedDate = _expirationDates;
    });
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != _selectedDate) {
      setState(() {
        _selectedDate = selected;
        _expirationDates = _selectedDate as DateTime;
      });
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

  Padding _expirationDateBuilder(BuildContext context) {
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
                DateFormat('yyyy-MM-dd').format(_expirationDates as DateTime),
              ),
              TextButton(
                onPressed: () => _editExpirationDate(),
                child: const Text('change'),
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
        title: const Text('Add Product'),
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
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
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const HeaderTwo(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          text: 'Expiration Date',
                        ),
                        SizedBox(
                          height: _expirationDateListViewHeight(),
                          child: Column(
                            children: [
                              Expanded(
                                child: _expirationDateBuilder(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
