import 'package:mpos/models/account.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/models/expiration_dates.dart';
import 'package:mpos/models/ingredient.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/sale.dart';
import 'package:mpos/models/store_details.dart';
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
  late final Box<Discount> discountBox;
  late final Box<PackagedProduct> packagedProductBox;
  late final Box<ImageProduct> imageBox;
  late final Box<ProductVariant> productVariantBox;
  late final Box<Sale> saleBox;

  ObjectBox._create(this.store) {
    accountBox = store.box<Account>();
    attendanceBox = store.box<Attendance>();
    expirationDateBox = store.box<ExpirationDate>();
    ingredientBox = store.box<Ingredient>();
    productBox = store.box<Product>();
    storeDetailsBox = store.box<StoreDetails>();
    transactionBox = store.box<Transaction>();
    discountBox = store.box<Discount>();
    packagedProductBox = store.box<PackagedProduct>();
    imageBox = store.box<ImageProduct>();
    productVariantBox = store.box<ProductVariant>();
    saleBox = store.box<Sale>();
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }
}
