import 'dart:convert';

import 'package:mpos/models/account.dart';
import 'package:mpos/models/inventory.dart';
import 'package:objectbox/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@Entity()
@JsonSerializable()
class Transaction {
  int id = 0;
  int transactionID;

  String packagesJson;
  String productsJson;
  final user = ToOne<Account>();

  String paymentMethod;
  String referenceNumber;
  int subTotal;
  int discount;
  int totalAmount;
  int payment;
  int change;
  DateTime date;
  DateTime time;

  List<PackagedProduct> get packages => (jsonDecode(packagesJson) as List)
      .map((item) => PackagedProduct.fromJson(item))
      .toList();

  List<Product> get products => (jsonDecode(productsJson) as List)
      .map((item) => Product.fromJson(item))
      .toList();

  Transaction({
    required this.transactionID,
    required this.paymentMethod,
    required this.subTotal,
    required this.discount,
    required this.totalAmount,
    required this.payment,
    required this.change,
    required this.date,
    required this.time,
    this.referenceNumber = "",
    this.packagesJson = "",
    this.productsJson = ""
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  @override
  String toString() {
    return 'Transaction {$transactionID, $packages, $products, $paymentMethod, $totalAmount, $date, $time}';
  }
}
