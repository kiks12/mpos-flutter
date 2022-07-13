import 'dart:async';

import 'package:flutter/material.dart';
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

  final StreamController<List<Attendance>> _listController =
      StreamController<List<Attendance>>(sync: true);

  final TextEditingController searchController = TextEditingController();

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
    attendanceStream = attendanceQueryBuilder.watch();

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
    final attendanceQuery = attendanceQueryBuilder.build();
    final attendanceResult = attendanceQuery.find();
    _listController.sink.add(attendanceResult);
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
  }) : super(key: key);

  final TextEditingController searchController;
  final void Function() onPressed;

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
      ],
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
