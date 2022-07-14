import 'package:flutter/material.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/objectbox.g.dart';

class AttendanceListTile extends StatefulWidget {
  const AttendanceListTile({
    Key? key,
    required this.attendances,
    required this.index,
    required this.attendanceBox,
  }) : super(key: key);

  final List<Attendance> attendances;
  final int index;
  final Box<Attendance> attendanceBox;

  @override
  State<AttendanceListTile> createState() => _AttendanceListTileState();
}

class _AttendanceListTileState extends State<AttendanceListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.index % 2 == 0
            ? Colors.transparent
            : const Color.fromARGB(255, 239, 239, 239),
        border: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 232, 232, 232),
            width: 0.7,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  '${widget.attendances[widget.index].user.target!.lastName}, ${widget.attendances[widget.index].user.target!.firstName}',
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.attendances[widget.index].user.target!.emailAddress,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.attendances[widget.index].dateFormat,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.attendances[widget.index].timeInFormat,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.attendances[widget.index].timeOutFormat,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
