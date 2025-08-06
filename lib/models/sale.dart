import 'package:mpos/models/inventory.dart';
import 'package:objectbox/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'sale.g.dart';

@Entity()
@JsonSerializable()
class Sale {
  int id = 0;

  String transactionID;

  String employeeId;
  String employeeName; // Instead of linking to Account

  String locationId;
  String locationName;

  String packagesJson;
  String productsJson;

  String paymentMethod;
  String referenceNumber;

  int subTotal;
  int discount;
  int totalAmount;
  int payment;
  int change;

  DateTime date;
  DateTime time;

  bool synced;

  Sale({
    required this.transactionID,
    required this.employeeId,
    required this.employeeName,
    required this.locationId,
    required this.locationName,
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
    this.productsJson = "",
    this.synced = false, 
  });

  // Deserialize packages
  List<PackagedProduct> get packages => (jsonDecode(packagesJson) as List)
      .map((item) => PackagedProduct.fromJson(item))
      .toList();

  // Deserialize products
  List<Product> get products => (jsonDecode(productsJson) as List)
      .map((item) => Product.fromJson(item))
      .toList();

  // JSON serialization
  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
  Map<String, dynamic> toJson() => _$SaleToJson(this);

  @override
  String toString() {
    return 'Sale {$transactionID, $employeeName, $packages, $products, $paymentMethod, $totalAmount, $date, $time , $synced}';
  }
}
