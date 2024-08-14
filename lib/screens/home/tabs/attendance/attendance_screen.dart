import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/attendance/components/attendance_header.dart';
import 'package:mpos/screens/home/tabs/attendance/components/attendance_list_header.dart';
import 'package:mpos/screens/home/tabs/attendance/components/attendance_list_item.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Stream<Query<Attendance>> attendanceStream;

  StreamController<List<Attendance>> _listController =
      StreamController<List<Attendance>>(sync: true);

  final TextEditingController searchController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    initializeAttendanceStream();
    _filter();
  }

  @override
  void dispose() {
    super.dispose();
    _listController.close();
  }

  void initializeAttendanceStream() {
    final attendanceQueryBuilder = objectBox.attendanceBox.query()
      ..order(Attendance_.date, flags: Order.descending);
    attendanceStream = attendanceQueryBuilder.watch(triggerImmediately: true);

    _listController.addStream(attendanceStream.map((query) => query.find()));
  }

  AttendanceListItem Function(BuildContext, int) attendanceListItemBuilder(
      List<Attendance> attendances) {
    return (BuildContext context, int index) {
      return AttendanceListItem(
        attendances: attendances,
        index: index,
        attendanceBox: objectBox.attendanceBox,
      );
    };
  }

  void refresh() {
    _listController = StreamController(sync: true);
    initializeAttendanceStream();
    _selectedDate = DateTime.now();
    _filter();
    setState(() {});
  }

  void search() {
    String strToSearch = searchController.text;
    final attendanceQueryBuilder = objectBox.attendanceBox.query()
      ..link(
          Attendance_.user,
          Account_.firstName.contains(strToSearch, caseSensitive: false) |
              Account_.lastName.contains(strToSearch, caseSensitive: false) |
              Account_.emailAddress.contains(strToSearch, caseSensitive: false))
      ..order(
        Attendance_.date,
        flags: Order.descending,
      );
    final attendanceQuery =
        attendanceQueryBuilder.watch(triggerImmediately: true);

    setState(() {
      _listController = StreamController(sync: true);
      _listController.addStream(attendanceQuery.map((query) => query.find()));
      searchController.text = '';
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != _selectedDate) {
      setState(() {
        _selectedDate = selected;
      });
    }

    _filter();
  }

  void _filter() {
    final attendanceQueryBuilder = objectBox.attendanceBox.query(
      Attendance_.date.equals(DateTime.parse(
        DateFormat('yyyy-MM-dd').format(_selectedDate as DateTime),
      ).millisecondsSinceEpoch),
    )..order(
        Attendance_.date,
        flags: Order.descending,
      );
    final attendanceQuery =
        attendanceQueryBuilder.watch(triggerImmediately: true);

    setState(() {
      _listController = StreamController(sync: true);
      _listController.addStream(attendanceQuery.map((query) => query.find()));
    });
  }

  void deleteAll(BuildContext context) {
    objectBox.attendanceBox.removeAll();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteAllConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Records'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Are you sure you want to delete all attendance Records?')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text('Confirm'),
              onPressed: () => deleteAll(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AttendanceScreenHeader(
              searchController: searchController,
              onPressed: search,
              selectDate: _selectDate,
              date: _selectedDate,
              refresh: refresh,
              deleteAll: showDeleteAllConfirmationDialog,
            ),
            const AttendanceListHeader(),
            Expanded(
              child: StreamBuilder<List<Attendance>>(
                stream: _listController.stream,
                builder: ((context, snapshot) => ListView.builder(
                      itemBuilder: attendanceListItemBuilder(snapshot.data ?? []),
                      shrinkWrap: true,
                      itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
