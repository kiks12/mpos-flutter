
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mpos/firebase/pos.dart';
import 'package:mpos/firebase/store.dart';
import 'package:mpos/utils/utils.dart';

class LoginServerAccountScreen extends StatefulWidget {
  const LoginServerAccountScreen({Key? key}) : super(key: key);

  @override
  State<LoginServerAccountScreen> createState() => _LoginServerAccountScreenState();
}

class _LoginServerAccountScreenState extends State<LoginServerAccountScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool _showPassword = false;
  String _serverAccount = "";
  final formKey = GlobalKey<FormState>();
  List<Store> _stores = [];
  String _selectedStore = "";
  List<POS> _pos = [];
  String _selectedPOS = "";

  TextEditingController emailAddressTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  @override
  void initState() {
    _serverAccount = Utils().getServerAccount();

    if (_serverAccount != "") getStores();
    super.initState();
  }

  void loginServerAccount() async {
    try {
      final email = emailAddressTextController.value.text;
      final password = passwordTextController.value.text;
      final signInResponse = await auth.signInWithEmailAndPassword(email: email, password: password);
      if (signInResponse.user != null) {
        Utils().writeServerAccount(email);
        Fluttertoast.showToast(msg: "Logged in as $email");
        _serverAccount = Utils().getServerAccount();
        getStores();
        setState((){});
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  void getStores() async {
    final snapshot = await firestore.collection("users").doc(_serverAccount).collection("stores").withConverter(fromFirestore: Store.fromFirestore, toFirestore: (Store store, _) => store.toFirestore()).get();
    _stores = snapshot.docs.map((document) => document.data()).toList();
    _selectedStore = _stores.first.storeName;
    setState(() {});
  }

  void getPOS() async {
    final snapshot = await firestore.collection("users").doc(_serverAccount).collection("stores").where("storeName", isEqualTo: _selectedStore).get();
    final storeID = snapshot.docs.first.id;
    final posSnapshot = await firestore.collection("users").doc(_serverAccount).collection("stores").doc(storeID).collection("POS").withConverter(fromFirestore: POS.fromFirestore, toFirestore: (POS pos, _) => pos.toFirestore()).get();
    _pos = posSnapshot.docs.map((document) => document.data()).toList();
    _selectedPOS = _pos.first.name;
    setState(() {});
  }

  void logoutServerAccount() async {
    try {
      await FirebaseAuth.instance.signOut();
      Utils().removeServerAccount();
      Utils().removeStore();
      Utils().removePOS();
      Fluttertoast.showToast(msg: "Logged out Server Account");
      _serverAccount = Utils().getServerAccount();
      _selectedStore = "";
      setState(() {});
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  void confirmSelectedStore() {
    Utils().writeStore(_selectedStore);
    Fluttertoast.showToast(msg: "Store Selected $_selectedStore");
    getPOS();
  }

  void confirmSelectedPOS() {
    Utils().writePOS(_selectedPOS);
    Fluttertoast.showToast(msg: "POS Selected $_selectedPOS");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: (_serverAccount == "") ? Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          HeaderOne(
                            padding: EdgeInsets.symmetric(vertical: 0),
                            text: 'Login Server Account',
                          ),
                          Text('Please fill in the form to login to server')
                        ],
                      ),
                    ),
                    TextFormFieldWithLabel(
                      label: 'Email Address',
                      controller: emailAddressTextController,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      isPassword: false,
                    ),
                    TextFormFieldWithLabel(
                      label: 'Password',
                      controller: passwordTextController,
                      padding: const EdgeInsets.only(top: 15),
                      isPassword: !_showPassword,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: GestureDetector(
                            onTap: () {
                              _showPassword = !_showPassword;
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Checkbox(value: _showPassword, onChanged: (newVal) {
                                  _showPassword = newVal!;
                                  setState(() {});
                                }),
                                const Text("Show Password")
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          border: Border.all(color: Theme.of(context).colorScheme.onSecondaryContainer, width: 0.5),
                          borderRadius: BorderRadius.circular(50)
                        ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('NOTE: Logging in to the server will require the system to always be connected to the internet'),
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed: loginServerAccount,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ) : Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const HeaderTwo(padding: EdgeInsets.zero, text: "Select Store"),
                  const Text("Select the corresponding store for this Point of Sale System"),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  DropdownButton(
                    value: _selectedStore,
                    isExpanded: true,
                    items: _stores.map((store) => DropdownMenuItem<String>(value: store.storeName, child: Text(store.storeName))).toList(),
                    onChanged: (newVal) {
                      _selectedStore = newVal.toString();
                      setState(() {});
                    }
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: confirmSelectedStore,
                        child: const Text("Confirm Store"),
                      ),
                    )
                  ),
                  if (_selectedStore != "") Column(
                    children: [
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                      const HeaderTwo(padding: EdgeInsets.zero, text: "Select POS"),
                      const Text("Select the corresponding device for this Point of Sale System"),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                      DropdownButton(
                          value: _selectedPOS,
                          isExpanded: true,
                          items: _pos.map((store) => DropdownMenuItem<String>(value: store.name, child: Text(store.name))).toList(),
                          onChanged: (newVal) {
                            _selectedPOS = newVal.toString();
                            setState(() {});
                          }
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: confirmSelectedPOS,
                              child: const Text("Confirm POS"),
                            ),
                          )
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 30)),
                  Text("Logged in as $_serverAccount"),
                  TextButton(
                    onPressed: logoutServerAccount,
                    child: const Text("Logout"),
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}
