
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class AddPackageScreen extends StatefulWidget {
  const AddPackageScreen({Key? key}) : super(key: key);

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {

  final formKey = GlobalKey<FormState>();

  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController unitPriceTextController =
  TextEditingController(text: '0');
  final TextEditingController quantityTextController =
  TextEditingController(text: '0');

  final TextEditingController categoryTextController = TextEditingController();

  List<String> _categories = [];
  String _selectedCategory = "";
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    setState(() {
      _categories = getCategories();
      _categories.add("Other");
      _selectedCategory = _categories[0];
    });
  }

  List<String> getCategories() {
    final query = objectBox.productBox.query().build();
    PropertyQuery<String> pq = query.property(Product_.category);
    pq.distinct = true;
    return pq.find();
  }

  Future<void> savePackageInServer(PackagedProduct package) async {
    try {
      final serverAccount = Utils().getServerAccount();
      final storeName = Utils().getStore();
      firestore.FirebaseFirestore db = firestore.FirebaseFirestore.instance;
      final snapshot = await db.collection("users").doc(serverAccount).collection("stores").where("storeName", isEqualTo: storeName).get();
      final documentId = snapshot.docs.first.id;
      final packagesRef = db.collection("users").doc(serverAccount).collection("stores").doc(documentId).collection("packages");
      final packageJson = package.toJson();
      packageJson["POS"] = Utils().getPOS();
      packageJson["type"] = "PACKAGE";
      await packagesRef.add(packageJson);
    } on firestore.FirebaseException catch(e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  void addPackage() async {
    if (!formKey.currentState!.validate()) return;

    PackagedProduct newPackage = PackagedProduct(
      name: nameTextController.text,
      category: (_selectedCategory == "Other") ? categoryTextController.text : _selectedCategory,
      price: int.parse(unitPriceTextController.text),
      quantity: int.parse(quantityTextController.text),
      products: "[]",
      image: _imageFile != null ? _imageFile!.path : "",
    );

    objectBox.packagedProductBox.put(newPackage);
    if (Utils().getServerAccount() != "" && Utils().getStore() != "" && Utils().getPOS() != "") await savePackageInServer(newPackage);
    Fluttertoast.showToast(msg: "Successfully created new package");
    if (mounted) Navigator.of(context).pop();
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
        title: const Text('Add Package'),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          value: _selectedCategory,
                          items: _categories.map((String e) {
                            return DropdownMenuItem<String>(
                                value: e, child: Text(e));
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
                          onPressed: addPackage,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            child: Text('Add Package'),
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
