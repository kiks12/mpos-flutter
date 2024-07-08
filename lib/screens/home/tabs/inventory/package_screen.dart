import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';

import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/inventory/edit_package_screen.dart';

class PackageScreen extends StatefulWidget {
  const PackageScreen({
    Key? key,
    required this.packagedProduct,
  }) : super(key: key);

  final PackagedProduct packagedProduct;

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  @override
  void initState() {
    super.initState();
  }

  void navigateToEditPackageScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPackageScreen(
          packagedProduct: widget.packagedProduct,
        ),
      ),
    );
  }

  void deletePackage() {
    objectBox.packagedProductBox.remove(widget.packagedProduct.id);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Package'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                    'Are you sure you want to delete this Package in inventory?'),
                Text(
                    '${widget.packagedProduct.id} - ${widget.packagedProduct.name}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: IconButton.styleFrom(
                  foregroundColor: const Color.fromRGBO(255, 230, 230, 1),
                  backgroundColor: Colors.red
              ),
              onPressed: deletePackage,
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = File(widget.packagedProduct.image);
    final imageExists = image.existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Package Screen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              imageExists ? Image.file(image, width: 450, height: 450) : const SizedBox(width: 450, height: 450, child: Center(child: Text("No Image Available"),)),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("PACKAGE ID: ${widget.packagedProduct.id}"),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 30)),
                    Text(widget.packagedProduct.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                    Text(widget.packagedProduct.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                    Text("Number of Items in package: ${widget.packagedProduct.quantity}"),
                    Text("Minimum Price: ${NumberFormat.currency(symbol: "₱").format(widget.packagedProduct.price)}"),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FilledButton.icon(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
                              foregroundColor: Colors.red
                            ),
                            icon: const Icon(Icons.delete),
                            onPressed: showDeleteConfirmationDialog,
                            label: const Text("Delete")
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.edit),
                            onPressed: navigateToEditPackageScreen,
                            label: const Text('Edit'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}