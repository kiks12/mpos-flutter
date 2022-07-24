import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/attendance/components/attendanceListTile.dart';

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
    initializeAttendanceStream();
  }

  @override
  void dispose() {
    _listController.close();
    super.dispose();
  }

  void initializeAttendanceStream() {
    final attendanceQueryBuilder = objectBox.attendanceBox.query()
      ..order(Attendance_.date, flags: Order.descending);
    attendanceStream = attendanceQueryBuilder.watch(triggerImmediately: true);

    _listController.addStream(attendanceStream.map((query) => query.find()));
  }

  AttendanceListTile Function(BuildContext, int) _itemBuilder(
      List<Attendance> attendances) {
    return (BuildContext context, int index) {
      return AttendanceListTile(
        attendances: attendances,
        index: index,
        attendanceBox: objectBox.attendanceBox,
      );
    };
  }

  void refresh() {
    setState(() {
      _listController = StreamController(sync: true);
      initializeAttendanceStream();
      _selectedDate = null;
    });
  }

  void search() {
    String strToSearch = searchController.text;
    final attendanceQueryBuilder = objectBox.attendanceBox.query()
      ..link(
          Attendance_.user,
          Account_.firstName.contains(strToSearch) |
              Account_.lastName.contains(strToSearch) |
              Account_.emailAddress.contains(strToSearch))
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
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Records'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
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
            ElevatedButton(
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
            const ListHeader(),
            Expanded(
              child: StreamBuilder<List<Attendance>>(
                stream: _listController.stream,
                builder: ((context, snapshot) => ListView.builder(
                      itemBuilder: _itemBuilder(snapshot.data ?? []),
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

class AttendanceScreenHeader extends StatefulWidget {
  const AttendanceScreenHeader({
    Key? key,
    required this.searchController,
    required this.onPressed,
    required this.selectDate,
    required this.date,
    required this.refresh,
    required this.deleteAll,
  }) : super(key: key);

  final TextEditingController searchController;
  final void Function() onPressed;
  final void Function() refresh;
  final void Function() deleteAll;
  final dynamic Function(BuildContext context) selectDate;
  final DateTime? date;

  @override
  State<AttendanceScreenHeader> createState() => _AttendanceScreenHeaderState();
}

class _AttendanceScreenHeaderState extends State<AttendanceScreenHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const HeaderOne(padding: EdgeInsets.all(0), text: 'Attendance'),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: TextField(
                        controller: widget.searchController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: widget.onPressed,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.blueGrey,
                    ),
                    onPressed: () => widget.selectDate(context),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text('Select Date'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      widget.date != null
                          ? "Selected Date: ${DateFormat('yyyy-MM-dd').format(widget.date as DateTime)}"
                          : 'Selected Date: No Date Selected',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.blueGrey,
                      ),
                      onPressed: widget.refresh,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        child: Text('Refresh'),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                    onPressed: widget.deleteAll,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text('Delete All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
      child: Row(
        children: const <Widget>[
          Expanded(
            child: Center(
              child: Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Time In',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Time Out',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
