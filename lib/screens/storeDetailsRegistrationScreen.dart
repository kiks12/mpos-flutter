import 'package:flutter/material.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/storeDetails.dart';
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

  void registerStoreDetails() {
    if (!formKey.currentState!.validate()) return;

    StoreDetails newStoreDetails = StoreDetails(
      name: storeNameTextController.text,
      contactPerson: contactPersonTextController.text,
      contactNumber: contactNumberTextController.text,
    );

    try {
      widget.storeDetailsBox.put(newStoreDetails);
    } on UniqueViolationException catch (e) {
      print(e);
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
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
                        ElevatedButton(
                          onPressed: registerStoreDetails,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
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
