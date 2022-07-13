import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/utils/utils.dart';
import 'package:intl/intl.dart';

class TimeInTimeOutScreen extends StatefulWidget {
  const TimeInTimeOutScreen({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  final TabController tabController;

  @override
  State<TimeInTimeOutScreen> createState() => _TimeInTimeOutScreenState();
}

class _TimeInTimeOutScreenState extends State<TimeInTimeOutScreen> {
  final Box<Attendance> attendanceBox = objectBox.attendanceBox;

  Account? curr;
  String _currentOperation = '';
  late DateTime _currentDate;
  List<Attendance> attendanceRecordToday = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      curr = Utils().getCurrentAccount(objectBox);
      String now = DateFormat("yyyy-MM-dd").format(DateTime.now());
      _currentDate = DateTime.parse(now);
    });

    setState(() {
      if (accountHasAttendanceToday()) {
        if (attendanceRecordToday[0]
            .date
            .isAtSameMomentAs(attendanceRecordToday[0].timeOut as DateTime)) {
          _currentOperation = 'Time Out';
          return;
        }
        _currentOperation = 'You have already Timed Out!';
        return;
      }
      _currentOperation = 'Time In';
    });
  }

  bool accountHasAttendanceToday() {
    findRecordToday();
    return attendanceRecordToday.isNotEmpty;
  }

  void timeIn() {
    Attendance newAttendance = Attendance(
      date: _currentDate,
      timeIn: DateTime.now(),
      timeOut: _currentDate,
    );

    newAttendance.user.target = curr as Account;
    attendanceBox.put(newAttendance);

    widget.tabController.index = 0;
  }

  void timeOut() {
    findRecordToday();
    attendanceRecordToday[0].timeOut = DateTime.now();

    attendanceBox.put(attendanceRecordToday[0]);

    GetStorage().remove('id');
    GetStorage().remove('email');

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
  }

  void findRecordToday() {
    QueryBuilder<Attendance> attendanceQueryBuilder = attendanceBox
        .query(Attendance_.date.equals(_currentDate.millisecondsSinceEpoch))
      ..link(Attendance_.user, Account_.id.equals(curr!.id));
    Query<Attendance> attendanceQuery = attendanceQueryBuilder.build();
    final attendanceResults = attendanceQuery.find();
    setState(() {
      attendanceRecordToday = attendanceResults;
    });
  }

  void _onPressed() {
    if (_currentOperation == 'Time In') return timeIn();
    if (_currentOperation == 'Time Out') return timeOut();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeaderOne(
                  padding: const EdgeInsets.all(20), text: _currentOperation),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                    'Date and Time: ${DateFormat('yyyy-MM-dd, hh:mm:a').format(DateTime.now())}'),
              ),
              ElevatedButton(
                onPressed: _onPressed,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  child: Text(_currentOperation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
