
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/header_one.dart';

class TransactionScreenHeader extends StatefulWidget {
  const TransactionScreenHeader({
    Key? key,
    required this.searchController,
    required this.onPressed,
    required this.selectDate,
    required this.date,
    required this.refresh,
    required this.deleteAll,
    required this.dropdownValue,
    required this.dropdownOnChange,
    required this.whichQuarter,
    required this.whichHalf,
    required this.whichYear,
    required this.onQuarterChange,
    required this.onHalfChange,
    required this.onYearChange,
    required this.totalRevenue,
    required this.paymentMethodValue,
    required this.onPaymentMethodValueChange
  }) : super(key: key);

  final int totalRevenue;
  final TextEditingController searchController;
  final void Function() onPressed;
  final void Function() refresh;
  final void Function() deleteAll;
  final dynamic Function(BuildContext context) selectDate;
  final DateTime? date;
  final String dropdownValue;
  final void Function(String str) dropdownOnChange;
  final void Function(String str) onQuarterChange;
  final void Function(String str) onHalfChange;
  final void Function(String str) onYearChange;
  final String whichQuarter;
  final String whichHalf;
  final String whichYear;
  final String paymentMethodValue;
  final void Function(String str) onPaymentMethodValueChange;

  @override
  State<TransactionScreenHeader> createState() =>
      _TransactionScreenHeaderState();
}

class _TransactionScreenHeaderState extends State<TransactionScreenHeader> {
  static const items = [
    'Today',
    'Last 7 Days',
    'Last 30 Days',
    'Quarterly',
    'Semi Annually',
    'Annually',
    'Specific Date',
    'All',
  ];

  static const quarters = [
    'First Quarter',
    'Second Quarter',
    'Third Quarter',
    'Fourth Quarter',
  ];

  static const halves = [
    'First Half',
    'Second Half',
  ];

  static const years = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
  ];

  static const paymentMethods = [
    "All",
    "Cash",
    "GCash",
    "Grab",
    "Foodpanda"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15,15,15,5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              HeaderOne(
                  padding: const EdgeInsets.all(0), text: 'Transactions  |  ${NumberFormat.currency(symbol: "₱").format(widget.totalRevenue)}'),
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
                    icon: const Icon(Icons.search),
                    onPressed: widget.onPressed,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Range: "),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<String>(
                          value: widget.dropdownValue,
                          onChanged: (String? newValue) {
                            widget.dropdownOnChange(newValue as String);
                          },
                          items:
                          items.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  widget.dropdownValue == 'Quarterly'
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Select Quarter: "),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 1, 10, 1),
                            child: DropdownButton<String>(
                            value: widget.whichQuarter,
                            onChanged: (String? newValue) {
                              widget.onQuarterChange(newValue as String);
                            },
                            items: quarters.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      )
                      : Container(),
                  widget.dropdownValue == 'Semi Annually'
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Select Half: "),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 1, 10, 1),
                            child: DropdownButton<String>(
                            value: widget.whichHalf,
                            onChanged: (String? newValue) {
                              widget.onHalfChange(newValue as String);
                            },
                            items: halves.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      )
                      : Container(),
                  widget.dropdownValue == 'Annually'
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Select Year: "),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 1, 10, 1),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.10,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: widget.whichYear,
                                onChanged: (String? newValue) {
                                  widget.onYearChange(newValue as String);
                                },
                                items: years.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                              ),
                            ),
                        ],
                      )
                      : Container(),
                  widget.dropdownValue == 'Specific Date'
                      ? FilledButton.tonalIcon(
                          icon: const Icon(Icons.date_range),
                          onPressed: () { widget.selectDate(context); },
                          label: const Text('Select Date')
                        )
                      : Container(),
                  widget.dropdownValue == 'Specific Date'
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      widget.date != null
                          ? "Selected Date: ${DateFormat('yyyy-MM-dd').format(widget.date as DateTime)}"
                          : 'Selected Date: No Date Selected',
                    ),
                  )
                      : Container(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Payment Method: "),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: widget.paymentMethodValue,
                            onChanged: (String? newValue) {
                              widget.onPaymentMethodValueChange(newValue as String);
                            },
                            items:
                            paymentMethods.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
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
