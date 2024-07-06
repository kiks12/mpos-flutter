
import 'package:flutter/material.dart';

class AttendanceListHeader extends StatelessWidget {
  const AttendanceListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
      child: Row(
        children: <Widget>[
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
