import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/inventory.dart';

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
  final String _error = '';

  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController barcodeTextController = TextEditingController();
  final TextEditingController unitPriceTextController =
      TextEditingController(text: '0');
  final TextEditingController quantityTextController =
      TextEditingController(text: '0');

  int _totalPrice = 0;
  final List<DateTime> _expirationDates = [];
  final TextEditingController categoryTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      for (var exp in widget.product.expirationDates) {
        _expirationDates.add(exp.date);
      }
      nameTextController.text = widget.product.name;
      barcodeTextController.text = widget.product.barcode;
      unitPriceTextController.text = widget.product.unitPrice.toString();
      quantityTextController.text = widget.product.quantity.toString();
      categoryTextController.text = widget.product.category;
      _totalPrice = widget.product.totalPrice;
    });
  }

  double _expirationDateListViewHeight() {
    return MediaQuery.of(context).size.height * 0.1 * _expirationDates.length;
  }

  void updateProduct() {
    if (!formKey.currentState!.validate()) return;

    Product productToUpdate =
        objectBox.productBox.get(widget.product.id) as Product;

    productToUpdate.name = nameTextController.text;
    productToUpdate.barcode = barcodeTextController.text;
    productToUpdate.unitPrice = int.parse(unitPriceTextController.text);
    productToUpdate.totalPrice = _totalPrice;
    productToUpdate.category = categoryTextController.text;

    objectBox.productBox.put(productToUpdate);

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void _calculateTotalPrice() {
    setState(() {
      _totalPrice = int.parse(unitPriceTextController.text) *
          int.parse(quantityTextController.text);
    });
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
                      TextFormFieldWithLabel(
                        label: 'Product Name',
                        controller: nameTextController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        isPassword: false,
                      ),
                      TextFormFieldWithLabel(
                        label: 'Barcode',
                        controller: barcodeTextController,
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
                        ElevatedButton(
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
