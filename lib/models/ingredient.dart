import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Ingredient {
  int id = 0;
  String name;
  String unitPrice;
  String quantity;

  final product = ToMany<Product>();

  @Backlink('ingredient')
  final expirationDates = ToMany<ExpirationDate>();

  Ingredient({
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  @override
  String toString() {
    return 'Ingredient {$id, $name, $unitPrice, $quantity}';
  }
}
