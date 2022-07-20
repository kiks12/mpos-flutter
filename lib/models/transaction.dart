import 'package:mpos/models/account.dart';
import 'package:mpos/models/inventory.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Transaction {
  int id = 0;
  int transactionID;

  final product = ToOne<Product>();
  final user = ToOne<Account>();

  int quantity;
  String paymentMethod;
  int totalAmount;
  DateTime date;
  DateTime time;

  Transaction({
    required this.transactionID,
    required this.quantity,
    required this.paymentMethod,
    required this.totalAmount,
    required this.date,
    required this.time,
  });

  @override
  String toString() {
    return 'Transaction {$transactionID, $product, $user, $quantity, $paymentMethod, $totalAmount, $date, $time}';
  }
}
