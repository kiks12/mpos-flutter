import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/transaction.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Account {
  int id = 0;
  String firstName;
  String middleName;
  String lastName;
  bool isAdmin;

  @Unique()
  String emailAddress;

  String contactNumber;
  String password;

  @Backlink('user')
  final attendance = ToMany<Attendance>();

  @Backlink('user')
  final transactions = ToMany<Transaction>();

  Account({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.isAdmin,
    required this.emailAddress,
    required this.contactNumber,
    required this.password,
  });

  @override
  String toString() {
    return 'Account {$id, $firstName, $middleName, $lastName, $isAdmin, $emailAddress, $contactNumber, $password, $attendance, $transactions}';
  }
}
