import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/CheckboxWithLabel.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/adminRegistrationScreen.dart';
import 'package:mpos/screens/home/homeScreen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();
  String _error = '';

  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController barcodeTextController = TextEditingController();
  final TextEditingController unitPriceTextController =
      TextEditingController(text: '0');
  final TextEditingController quantityTextController =
      TextEditingController(text: '0');

  int _totalPrice = 0;
  List<DateTime> _expirationDates = [];
  DateTime? _selectedDate;

  double _expirationDateListViewHeight() {
    return MediaQuery.of(context).size.height * 0.1 * _expirationDates.length;
  }

  void addProduct() {
    if (!formKey.currentState!.validate()) return;

    Product newProduct = Product(
      name: nameTextController.text,
      barcode: barcodeTextController.text,
      unitPrice: int.parse(unitPriceTextController.text),
      quantity: int.parse(quantityTextController.text),
      totalPrice: _totalPrice,
    );

    ExpirationDate newExpirationDate = ExpirationDate(
      date: _expirationDates[0],
      quantity: int.parse(quantityTextController.text),
      expired: 0,
      sold: 0,
    );

    newProduct.expirationDates.add(newExpirationDate);
    objectBox.productBox.put(newProduct);

    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _removeExpirationDate(int index) {
    setState(() {
      _expirationDates.removeAt(index);
    });
  }

  void _editExpirationDate(int index) async {
    setState(() {
      _selectedDate = _expirationDates[index];
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
        _expirationDates[index] = _selectedDate as DateTime;
      });
    }
  }

  void _calculateTotalPrice() {
    setState(() {
      _totalPrice = int.parse(unitPriceTextController.text) *
          int.parse(quantityTextController.text);
    });
  }

  GestureDetector _expirationDateBuilder(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _editExpirationDate(index),
      child: Padding(
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
                TextButton(
                  onPressed: () => _removeExpirationDate(index),
                  child: const Text(
                    'remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != _selectedDate) {
      setState(() {
        _selectedDate = selected;
        _expirationDates.add(_selectedDate as DateTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Add Expiration Date'),
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
