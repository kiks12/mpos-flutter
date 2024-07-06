
import 'dart:core';
import 'package:objectbox/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';

part 'discounts.g.dart';

@Entity()
@JsonSerializable()
class Discount {
  int id=0;
  String title;
  String type;
  String category;
  String products;
  String operation;
  int value;

  Discount({
    required this.title,
    required this.operation,
    required this.value,
    required this.type,
    required this.category,
    required this.products,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => _$DiscountFromJson(json);
  Map<String, dynamic> toJson() => _$DiscountToJson(this);

  @override
  String toString() {
    return 'Discount {$id, $title}';
  }
}

// Title name of discount
// Type specific PRODUCT/PACKAGE or TOTAL
// Operation is PERCENTAGE/FIXED
// if TOTAL SKIP PRODUCTS AND CONTINUE TO VALUE
// Products List of all products the discount is applicable to
// Value is the amount to be lessen from the TOTAL AMOUNT
