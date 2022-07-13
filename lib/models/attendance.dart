import 'package:mpos/models/account.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Attendance {
  int id = 0;

  final user = ToOne<Account>();

  DateTime date;
  DateTime timeIn;
  DateTime? timeOut;

  Attendance({required this.date, required this.timeIn, required this.timeOut});

  @override
  String toString() {
    return 'Attendance {$id, $date, $timeIn, $timeOut}';
  }
}
