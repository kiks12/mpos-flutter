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

  void writeServerAccount(String email) {
    GetStorage().write("SERVER_ACCOUNT", email);
  }

  void removeServerAccount() {
    GetStorage().remove("SERVER_ACCOUNT");
  }

  String getServerAccount() => GetStorage().read("SERVER_ACCOUNT") ?? "";

  void writeStore(String store) => GetStorage().write("STORE", store);

  void removeStore() => GetStorage().remove("STORE");

  String getStore() => GetStorage().read("STORE") ?? "";
}
