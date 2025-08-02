import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController unitPriceTextController = TextEditingController(text: '0.00');
  final TextEditingController quantityTextController = TextEditingController(text: '0');
  final TextEditingController categoryTextController = TextEditingController();

  double _totalPrice = 0.0;
  DateTime _expirationDate = DateTime.now();
  List<String> _categories = [];
  String _selectedCategory = "";
  File? _imageFile;
  final List<ProductVariantControllers> _variants = [];
  bool _withVariant = false;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    unitPriceTextController.addListener(_calculateTotalPrice);
    quantityTextController.addListener(_calculateTotalPrice);
  }

  @override
  void dispose() {
    nameTextController.dispose();
    barcodeTextController.dispose();
    unitPriceTextController.removeListener(_calculateTotalPrice);
    unitPriceTextController.dispose();
    quantityTextController.removeListener(_calculateTotalPrice);
    quantityTextController.dispose();
    categoryTextController.dispose();
    for (var variant in _variants) {
      variant.dispose();
    }
    super.dispose();
  }

  void _initializeCategories() {
    _categories = _getCategories();
    if (!_categories.contains("Other")) {
      _categories.add("Other");
    }
    _selectedCategory = _categories.isNotEmpty ? _categories[0] : "Other";
    setState(() {});
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
    } on firestore.FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  void addProduct() async {
    if (!formKey.currentState!.validate()) return;

    double finalUnitPrice;
    int finalQuantity;
    double finalTotalPrice;

    if (_withVariant) {
      if (_variants.isEmpty) {
        Fluttertoast.showToast(msg: "Please add at least one variant.");
        return;
      }
      for (var variant in _variants) {
        if (!variant.nameController.text.isNotEmpty ||
            (int.tryParse(variant.quantityController.text) ?? 0) <= 0 ||
            (double.tryParse(variant.unitPriceController.text) ?? 0.0) <= 0) {
          Fluttertoast.showToast(msg: "Please fill all variant fields correctly.");
          return;
        }
      }
      finalUnitPrice = _variants.map((v) => double.parse(v.unitPriceController.text)).reduce((a, b) => a < b ? a : b);
      finalQuantity = _variants.fold(0, (prev, curr) => prev + (int.tryParse(curr.quantityController.text) ?? 0));
      finalTotalPrice = _variants.fold(0.0, (prev, curr) => prev + (double.tryParse(curr.totalPriceController.text) ?? 0.0));
    } else {
      finalUnitPrice = double.tryParse(unitPriceTextController.text) ?? 0.0;
      finalQuantity = int.tryParse(quantityTextController.text) ?? 0;
      finalTotalPrice = _totalPrice;
      if (finalUnitPrice <= 0 || finalQuantity <= 0) {
        Fluttertoast.showToast(msg: "Unit Price and Quantity must be greater than 0.");
        return;
      }
    }

    Product newProduct = Product(
      name: nameTextController.text,
      category: (_selectedCategory == "Other") ? categoryTextController.text : _selectedCategory,
      unitPrice: finalUnitPrice.toInt(),
      quantity: finalQuantity,
      totalPrice: finalTotalPrice.toInt(),
      image: _imageFile?.path ?? "",
      withVariant: _withVariant,
    );

    if (!_withVariant) {
      ExpirationDate newExpirationDate = ExpirationDate(
        date: _expirationDate,
        quantity: finalQuantity,
        expired: 0,
        sold: 0,
      );
      newProduct.expirationDates.add(newExpirationDate);
    }

    for (var variantController in _variants) {
      final productVariant = ProductVariant(
        name: variantController.nameController.text,
        unitPrice: int.parse(variantController.unitPriceController.text),
        quantity: int.parse(variantController.quantityController.text),
        totalPrice: int.parse(variantController.totalPriceController.text),
        image: "", // Assuming variant images are not supported yet
      );
      newProduct.variants.add(productVariant);
    }

    objectBox.productBox.put(newProduct);
    if (Utils().getServerAccount() != "" && Utils().getStore() != "" && Utils().getPOS() != "") {
      await saveProductInServer(newProduct);
    }
    Fluttertoast.showToast(msg: "Successfully created new product");
    if (mounted) Navigator.of(context).pop();
  }

  void _calculateTotalPrice() {
    setState(() {
      final unitPrice = double.tryParse(unitPriceTextController.text) ?? 0.0;
      final quantity = int.tryParse(quantityTextController.text) ?? 0;
      _totalPrice = unitPrice * quantity;
    });
  }

  List<String> _getCategories() {
    try {
      final query = objectBox.productBox.query().build();
      PropertyQuery<String> pq = query.property(Product_.category);
      pq.distinct = true;
      return pq.find();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  Future<void> pickAndSaveImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = path.join(directory.path, '${DateTime.now().millisecondsSinceEpoch}.png');
        final savedImage = await imageFile.copy(imagePath);
        setState(() {
          _imageFile = savedImage;
        });
      } else {
        Fluttertoast.showToast(msg: "No image selected");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error picking and saving image: $e');
    }
  }

  void withVariantOnChange(bool? value) {
    setState(() {
      _withVariant = value ?? false;
      if (!_withVariant) {
        for (var variant in _variants) {
          variant.dispose();
        }
        _variants.clear();
      }
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool isNumber = false,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        onChanged: onChanged,
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isNumber && (double.tryParse(value) ?? 0) <= 0 && label != 'Quantity') {
            return '$label must be greater than 0';
          }
          return null;
        },
        textInputAction: textInputAction,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
          ),
          if (_selectedCategory == "Other")
            _buildTextFormField(
              controller: categoryTextController,
              label: 'New Category Name',
              hintText: 'e.g., Beverages',
              textInputAction: TextInputAction.done,
            ),
        ],
      ),
    );
  }

  Widget _buildVariantInputRow(ProductVariantControllers variantController, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: _buildTextFormField(
              controller: variantController.nameController,
              label: 'Variant Name',
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildTextFormField(
              controller: variantController.quantityController,
              label: 'Qty',
              isNumber: true,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildTextFormField(
              controller: variantController.unitPriceController,
              label: 'Unit Price',
              isNumber: true,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildTextFormField(
              controller: variantController.totalPriceController,
              label: 'Total',
              readOnly: true,
              isNumber: true,
              textInputAction: TextInputAction.done,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                variantController.dispose();
                _variants.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add New Product'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Max width for the form
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Identifiers Section
                  _buildSectionHeader('Product Identifiers'),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Image Picker
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: _imageFile != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.image_outlined,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: pickAndSaveImage,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text("Select Image"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            controller: nameTextController,
                            label: 'Product Name',
                            hintText: 'e.g., Glazed Donut',
                          ),
                          _buildTextFormField(
                            controller: barcodeTextController,
                            label: 'Barcode (Optional)',
                            hintText: 'Scan or enter barcode',
                            textInputAction: TextInputAction.next,
                          ),
                          _buildCategoryDropdown(),
                          const SizedBox(height: 16),
                          // With Variant Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _withVariant,
                                onChanged: withVariantOnChange,
                                activeColor: Theme.of(context).primaryColor,
                              ),
                              GestureDetector(
                                onTap: () => withVariantOnChange(!_withVariant),
                                child: const Text(
                                  "Product has Variants (e.g., Small, Medium, Large)",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pricing and Stock Section (Conditional)
                  if (!_withVariant) ...[
                    _buildSectionHeader('Pricing and Stock'),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildTextFormField(
                              controller: unitPriceTextController,
                              label: 'Unit Price',
                              isNumber: true,
                              onChanged: (str) => _calculateTotalPrice(),
                            ),
                            _buildTextFormField(
                              controller: quantityTextController,
                              label: 'Quantity',
                              isNumber: true,
                              onChanged: (str) => _calculateTotalPrice(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                if ((int.tryParse(value) ?? 0) < 0) {
                                  return 'Quantity cannot be negative';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Price:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.currency(symbol: '₱').format(_totalPrice),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Expiration Date
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expiration Date',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _selectExpirationDate(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat('yyyy-MM-dd').format(_expirationDate),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          Icon(
                                            Icons.calendar_today,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // Variants Section (Conditional)
                  if (_withVariant) ...[
                    _buildSectionHeader('Product Variants'),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (_variants.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'No variants added yet. Click "Add Variant" to start.',
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ..._variants.asMap().entries.map((entry) {
                              return _buildVariantInputRow(entry.value, entry.key);
                            }).toList(),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _variants.add(ProductVariantControllers(
                                      index: _variants.length + 1,
                                      nameController: TextEditingController(),
                                      quantityController: TextEditingController(text: '0'),
                                      unitPriceController: TextEditingController(text: '0.00'),
                                      totalPriceController: TextEditingController(text: '0.00'),
                                    ));
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Add Variant"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: addProduct,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}