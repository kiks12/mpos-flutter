import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/transaction.dart';
import 'package:objectbox/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';

part "account.g.dart";

@Entity()
@JsonSerializable()
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

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);

  @override
  String toString() {
    return 'Account {$id, $firstName, $middleName, $lastName, $isAdmin, $emailAddress, $contactNumber, $password, $attendance, $transactions}';
  }
}


