
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/models/expiration_dates.dart';
import 'package:mpos/models/inventory.dart';

Future<void> setupProductsData() async {
  final jsonString = await rootBundle.loadString("assets/products.json");
  final jsonList = jsonDecode(jsonString);
  final List<dynamic> entities = jsonList.map((e) => Product.fromJsonSerial(e)).toList();
  final List<Product> products = entities.map((e) {
    final product = e as Product;
    product.id = 0;
    return product;
  }).toList();
  objectBox.productBox.putMany(products);
  Fluttertoast.showToast(msg: "Initialized Products Data");
}

Future<void> setupPackagesData() async {
  final jsonString = await rootBundle.loadString("assets/packages.json");
  final jsonList = jsonDecode(jsonString);
  final List<dynamic> entities = jsonList.map((e) => PackagedProduct.fromJsonSerial(e)).toList();
  final List<PackagedProduct> packages = entities.map((e) {
    final package = e as PackagedProduct;
    package.id = 0;
    return package;
  }).toList();
  objectBox.packagedProductBox.putMany(packages);
  Fluttertoast.showToast(msg: "Initialized Packages Data");
}

Future<void> setupExpirationDatesData() async {
  final jsonString = await rootBundle.loadString("assets/expiration-dates.json");
  final jsonList = jsonDecode(jsonString);
  final entities = jsonList.map((e) => ExpirationDate.fromJson(e)).toList();
  objectBox.expirationDateBox.putMany(entities);
  Fluttertoast.showToast(msg: "Initialized Expiration Dates Data");
}

Future<void> setupDiscountsData() async {
  final jsonString = await rootBundle.loadString("assets/discounts.json");
  final jsonList = jsonDecode(jsonString);
  final List<dynamic> entities = jsonList.map((e) => Discount.fromJson(e)).toList();
  final List<Discount> discounts = entities.map((e) {
    final discount = e as Discount;
    discount.id = 0;
    return discount;
  }).toList();
  objectBox.discountBox.putMany(discounts);
  Fluttertoast.showToast(msg: "Initialized Discounts Data");
}