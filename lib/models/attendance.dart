import 'package:intl/intl.dart';
import 'package:mpos/models/account.dart';
import 'package:objectbox/objectbox.dart';
import 'package:json_annotation/json_annotation.dart';

part "attendance.g.dart";

@Entity()
@JsonSerializable()
class Attendance {
  int id = 0;

  final user = ToOne<Account>();

  DateTime date;
  DateTime timeIn;
  DateTime? timeOut;

  Attendance({required this.date, required this.timeIn, required this.timeOut});

  String get dateFormat => DateFormat('yyyy-MM-dd').format(date);
  String get timeInFormat => DateFormat('HH:mm:a').format(timeIn);
  String get timeOutFormat => DateFormat('HH:mm:a').format(timeOut as DateTime);

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  @override
  String toString() {
    return 'Attendance {$id, $date, $timeIn, $timeOut}';
  }
}
