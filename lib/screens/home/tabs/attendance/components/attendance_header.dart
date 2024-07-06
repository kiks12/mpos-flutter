

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/header_one.dart';

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
          padding: const EdgeInsets.fromLTRB(15,15,15,5),
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
                      child: TextFormField(
                        maxLines: 1,
                        minLines: 1,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            labelText: "Search",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)
                            )
                        ),
                        controller: widget.searchController,
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: widget.onPressed,
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.refresh),
                    onPressed: widget.refresh,
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
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => widget.selectDate(context),
                    label: const Text('Select Date'),
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
                  FilledButton.icon(
                    icon: const Icon(Icons.delete),
                    style: FilledButton.styleFrom(
                      foregroundColor: Colors.red, backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
                    ),
                    onPressed: widget.deleteAll,
                    label: const Text('Delete All'),
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
