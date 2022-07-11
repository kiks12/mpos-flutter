import 'package:mpos/models/account.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/ingredient.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/storeDetails.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/objectbox.g.dart';

class ObjectBox {
  late final Store store;
  late final Box<Account> accountBox;
  late final Box<Attendance> attendanceBox;
  late final Box<ExpirationDate> expirationDateBox;
  late final Box<Ingredient> ingredientBox;
  late final Box<Product> productBox;
  late final Box<StoreDetails> storeDetailsBox;
  late final Box<Transaction> transactionBox;

  ObjectBox._create(this.store) {
    accountBox = store.box<Account>();
    attendanceBox = store.box<Attendance>();
    expirationDateBox = store.box<ExpirationDate>();
    ingredientBox = store.box<Ingredient>();
    productBox = store.box<Product>();
    storeDetailsBox = store.box<StoreDetails>();
    transactionBox = store.box<Transaction>();
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }
}
