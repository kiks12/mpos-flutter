import 'package:get_storage/get_storage.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/objectBox.dart';
import 'package:mpos/objectbox.g.dart';

class Utils {
  Utils();

  Account? getCurrentAccount(ObjectBox objectBox) {
    int id = GetStorage().read('id');

    final accountQuery =
        objectBox.accountBox.query(Account_.id.equals(id)).build();
    Account? currentAccount = accountQuery.findFirst();

    return currentAccount;
  }
}
