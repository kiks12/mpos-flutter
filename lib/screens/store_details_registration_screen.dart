import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/store_details.dart';
import 'package:objectbox/objectbox.dart';

class StoreDetailsRegistrationScreen extends StatefulWidget {
  const StoreDetailsRegistrationScreen({
    Key? key,
    required this.storeDetailsBox,
  }) : super(key: key);

  final Box<StoreDetails> storeDetailsBox;

  @override
  State<StoreDetailsRegistrationScreen> createState() =>
      _StoreDetailsRegistrationScreenState();
}

class _StoreDetailsRegistrationScreenState
    extends State<StoreDetailsRegistrationScreen> {
  TextEditingController storeNameTextController = TextEditingController();
  TextEditingController contactNumberTextController = TextEditingController();
  TextEditingController contactPersonTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void registerStoreDetails() async {
    if (!formKey.currentState!.validate()) return;

    StoreDetails newStoreDetails = StoreDetails(
      name: storeNameTextController.text,
      contactPerson: contactPersonTextController.text,
      contactNumber: contactNumberTextController.text,
    );

    try {
      widget.storeDetailsBox.put(newStoreDetails);
      // await setupProductsData();
      // await setupPackagesData();
      // await setupDiscountsData();
      // Fluttertoast.showToast(msg: "System Setup Complete");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MyApp()));
    } on UniqueViolationException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 200),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const HeaderOne(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      text: 'Store Details'),
                  TextFormFieldWithLabel(
                      label: 'Store Name',
                      controller: storeNameTextController,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      isPassword: false),
                  TextFormFieldWithLabel(
                      label: 'Contact Person',
                      controller: contactPersonTextController,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      isPassword: false),
                  TextFormFieldWithLabel(
                      label: 'Contact Number',
                      controller: contactNumberTextController,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      isPassword: false),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                          onPressed: registerStoreDetails,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
