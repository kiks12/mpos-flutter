
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

class _EditPackageScreenState extends State<EditPackageScreen> {

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
  bool imageExists = false;

  @override
  void initState() {
    super.initState();
    _categories = getCategories();
    _categories.add("Other");
    _selectedCategory = widget.packagedProduct.category;
    nameTextController.text = widget.packagedProduct.name;
    unitPriceTextController.text = widget.packagedProduct.price.toString();
    quantityTextController.text = widget.packagedProduct.quantity.toString();
    _imageFile = File(widget.packagedProduct.image);
    imageExists = _imageFile!.existsSync();
    setState(() {});
  }

  List<String> getCategories() {
    final query = objectBox.productBox.query().build();
    PropertyQuery<String> pq = query.property(Product_.category);
    pq.distinct = true;
    return pq.find();
  }

  void updatePackage() {
    if (!formKey.currentState!.validate()) return;

    PackagedProduct packageToUpdate =
    objectBox.packagedProductBox.get(widget.packagedProduct.id) as PackagedProduct;

    packageToUpdate.name = nameTextController.text;
    packageToUpdate.price = int.parse(unitPriceTextController.text);
    packageToUpdate.category = (_selectedCategory == "Other") ? categoryTextController.text : _selectedCategory;
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
