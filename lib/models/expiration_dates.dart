
import 'package:mpos/models/ingredient.dart';
import 'package:objectbox/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';

import 'inventory.dart';

part "expiration_dates.g.dart";

@Entity()
@JsonSerializable()
class ExpirationDate {
  int id = 0;

  final productExp = ToOne<Product>();
  final ingredient = ToOne<Ingredient>();

  DateTime date;
  int quantity;
  int sold;
  int expired;

  ExpirationDate({
    required this.date,
    required this.quantity,
    required this.sold,
    required this.expired,
  });

  factory ExpirationDate.fromJson(Map<String, dynamic> json) => _$ExpirationDateFromJson(json);
  Map<String, dynamic> toJson() => _$ExpirationDateToJson(this);

  @override
  String toString() {
    return 'Expiration Date {$id, $productExp, $ingredient, $date, $quantity, $sold, $expired}';
  }
}
