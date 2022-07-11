import 'package:mpos/models/ingredient.dart';
import 'package:objectbox/objectbox.dart';

import 'inventory.dart';

@Entity()
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

  @override
  String toString() {
    return 'Expiration Date {$id, $productExp, $ingredient, $date, $quantity, $sold, $expired}';
  }
}
