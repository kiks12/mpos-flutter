import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
    required this.onPaymentMethodValueChange,
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
  State<TransactionScreenHeader> createState() => _TransactionScreenHeaderState();
}

class _TransactionScreenHeaderState extends State<TransactionScreenHeader> {
  static const List<String> _dateRangeItems = [
    'Today',
    'Last 7 Days',
    'Last 30 Days',
    'Quarterly',
    'Semi Annually',
    'Annually',
    'Specific Date',
    'All',
  ];
  static const List<String> _quarters = [
    'First Quarter',
    'Second Quarter',
    'Third Quarter',
    'Fourth Quarter',
  ];
  static const List<String> _halves = [
    'First Half',
    'Second Half',
  ];
  static const List<String> _years = [
    '2025', '2026', '2027', '2028', '2029', '2030', '2031', '2032', '2033', '2034', '2035',
  ];
  static const List<String> _paymentMethods = [
    "All",
    "Cash",
    "GCash",
    "Grab",
    "Foodpanda",
  ];

  Widget _buildSearchAndActions(double maxWidth) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: widget.searchController,
              maxLines: 1,
              minLines: 1,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => widget.onPressed(),
              decoration: InputDecoration(
                hintText: "Search sales...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: const Icon(Icons.search, size: 20),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          width: 48,
          child: IconButton(
            onPressed: widget.refresh,
            icon: const Icon(Icons.refresh),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    double? width,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: width,
            height: 48, // Fixed height for consistency
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: widget.deleteAll,
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('Delete All'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inventory Value and Search/Refresh Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                // Desktop/Tablet layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sales  |  ${NumberFormat.currency(symbol: '₱').format(double.tryParse(widget.totalRevenue.toString()) ?? 0.0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: _buildSearchAndActions(constraints.maxWidth),
                    ),
                  ],
                );
              } else {
                // Mobile layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales  |  ${NumberFormat.currency(symbol: '₱').format(double.tryParse(widget.totalRevenue.toString()) ?? 0.0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchAndActions(constraints.maxWidth),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),
          // Filters and Action Buttons Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                // Desktop/Tablet layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildFilterDropdown(
                          label: "Select Range",
                          value: widget.dropdownValue,
                          items: _dateRangeItems,
                          onChanged: (value) {
                            widget.dropdownOnChange(value ?? "");
                          },
                          width: 200
                        ),
                        widget.dropdownValue == "Quarterly" ?  
                          _buildFilterDropdown(
                            label: "Select Quarter: ",
                            value: widget.whichQuarter,
                            items: _quarters,
                            onChanged: (value) {
                              widget.onQuarterChange(value ?? "");
                            },
                            width: 200
                          ) : Container(),
                        widget.dropdownValue == "Semi Annually" ?  
                          _buildFilterDropdown(
                            label: "Select Half: ",
                            value: widget.whichHalf,
                            items: _halves,
                            onChanged: (value) {
                              widget.onHalfChange(value ?? "");
                            },
                            width: 200
                          ) : Container(),
                        widget.dropdownValue == "Annually" ?  
                          _buildFilterDropdown(
                            label: "Select Year: ",
                            value: widget.whichYear,
                            items: _years,
                            onChanged: (value) {
                              widget.onYearChange(value ?? "");
                            },
                            width: 200
                          ) : Container(),
                        widget.dropdownValue == "Specific Date" ?  
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: FilledButton.tonalIcon(
                              onPressed: () {
                                widget.selectDate(context);
                              }, 
                              icon: Icon(Icons.date_range),
                              label: Text(widget.date != null ? "Selected Date: ${DateFormat('yyyy-MM-dd').format(widget.date as DateTime)}" : "Select Date"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ) : Container(),
                        _buildFilterDropdown(
                          label: "Select Payment Method: ",
                          value: widget.paymentMethodValue,
                          items: _paymentMethods,
                          onChanged: (value) {
                            widget.onPaymentMethodValueChange(value ?? "");
                          },
                          width: 200
                        )
                      ],
                    ),
                    _buildActionButtons(),
                  ],
                );
              } else {
                // Mobile layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildFilterDropdown(
                          label: "Select Range",
                          value: widget.dropdownValue,
                          items: _dateRangeItems,
                          onChanged: (value) {
                            widget.dropdownOnChange(value ?? "");
                          },
                          width: 200
                        ),
                        widget.dropdownValue == "Quarterly" ?  
                          _buildFilterDropdown(
                            label: "Select Quarter: ",
                            value: widget.whichQuarter,
                            items: _quarters,
                            onChanged: (value) {
                              widget.onQuarterChange(value ?? "");
                            },
                            width: 200
                          ) : Container(),
                        widget.dropdownValue == "Semi Annually" ?  
                          _buildFilterDropdown(
                            label: "Select Half: ",
                            value: widget.whichHalf,
                            items: _halves,
                            onChanged: (value) {
                              widget.onHalfChange(value ?? "");
                            },
                            width: 200
                          ) : Container(),
                        widget.dropdownValue == "Annually" ?  
                          _buildFilterDropdown(
                            label: "Select Year: ",
                            value: widget.whichYear,
                            items: _years,
                            onChanged: (value) {
                              widget.onYearChange(value ?? "");
                            },
                            width: 200
                          ) : Container(),
                        widget.dropdownValue == "Specific Date" ?  
                          FilledButton.tonalIcon(
                            onPressed: () {
                              widget.selectDate(context);
                            }, 
                            icon: Icon(Icons.date_range),
                            label: const Text("Select Date")
                          ) : Container(), 
                        widget.dropdownValue == "Specific Date" ?  
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              widget.date != null 
                                ? "Selected Date: ${DateFormat('yyyy-MM-dd').format(widget.date as DateTime)}"
                                : "No Selected Date"
                            ),
                          ) : Container(),
                        _buildFilterDropdown(
                          label: "Select Payment Method: ",
                          value: widget.paymentMethodValue,
                          items: _paymentMethods,
                          onChanged: (value) {
                            widget.onPaymentMethodValueChange(value ?? "");
                          } 
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

}