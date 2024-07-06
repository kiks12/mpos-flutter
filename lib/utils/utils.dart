import 'package:get_storage/get_storage.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/object_box.dart';
import 'package:mpos/objectbox.g.dart';

class Utils {
  Utils();

  Account? getCurrentAccount(ObjectBox objectBox) {
    String email = GetStorage().read('email');

    final accountQuery =
        objectBox.accountBox.query(Account_.emailAddress.equals(email)).build();
    Account? currentAccount = accountQuery.findFirst();

    return currentAccount;
  }
}
