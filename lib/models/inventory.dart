import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/ingredient.dart';
import 'package:mpos/models/transaction.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Product {
  int id = 0;
  String name;
  String barcode;
  String category;
  int unitPrice;
  int quantity;
  int totalPrice;

  @Backlink('product')
  final ingredients = ToMany<Ingredient>();

  @Backlink('productExp')
  final expirationDates = ToMany<ExpirationDate>();

  @Backlink('product')
  final transation = ToMany<Transaction>();

  Product({
    required this.name,
    required this.barcode,
    required this.category,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  String toString() {
    return 'Product {$id, $name, $barcode, $category,$unitPrice, $quantity, $totalPrice}';
  }
}
