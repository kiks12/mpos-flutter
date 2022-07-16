import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/inventory.dart';

class ManageExpirationDatesScreen extends StatefulWidget {
  const ManageExpirationDatesScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  State<ManageExpirationDatesScreen> createState() =>
      _ManageExpirationDatesScreenState();
}

class _ManageExpirationDatesScreenState
    extends State<ManageExpirationDatesScreen> {
  final List<ExpirationDate> _ongoingDates = [];
  final List<ExpirationDate> _expiredDates = [];

  final TextEditingController _totalQuantity = TextEditingController();
  final TextEditingController _soldQuantity = TextEditingController();
  final TextEditingController _expiredQuantity = TextEditingController();

  TextEditingController _quantityController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    initializeDates();
  }

  void initializeDates() {
    print(objectBox.expirationDateBox.getAll());
    setState(() {
      for (var exp in widget.product.expirationDates) {
        if (exp.date.isBefore(DateTime.now())) {
          _expiredDates.add(exp);
          return;
        }

        _ongoingDates.add(exp);
        return;
      }
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    setState(() {
      _selectedDate = selected;
    });
  }

  _addExpirationDate() {
    ExpirationDate newExp = ExpirationDate(
      date: _selectedDate as DateTime,
      quantity: int.parse(_quantityController.text),
      expired: 0,
      sold: 0,
    );

    Product product = objectBox.productBox.get(widget.product.id) as Product;

    product.expirationDates.add(newExp);

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> showAddDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Add Expiration Date:'),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.height * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            child: Text('Choose Date'),
                          ),
                        ),
                        Text(_selectedDate != null
                            ? DateFormat('yyyy-MM-dd')
                                .format(_selectedDate as DateTime)
                            : ''),
                        TextField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Quantity'),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _addExpirationDate,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void setQuantities(int id) {
    ExpirationDate expirationDateToUpdate =
        objectBox.expirationDateBox.get(id) as ExpirationDate;
    expirationDateToUpdate.sold = int.parse(_soldQuantity.text);
    expirationDateToUpdate.expired = int.parse(_expiredQuantity.text);

    setState(() {
      ExpirationDate exp =
          _ongoingDates.firstWhere((element) => element.id == id);
      exp.sold = int.parse(_soldQuantity.text);
      exp.expired = int.parse(_expiredQuantity.text);
    });

    objectBox.expirationDateBox.put(expirationDateToUpdate);

    Navigator.pop(context);
  }

  Container _itemBuilder(BuildContext context, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom:
              BorderSide(color: Color.fromARGB(255, 222, 222, 222), width: 0.7),
        ),
      ),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${_ongoingDates[index].id}',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                DateFormat('yyyy-MM-dd').format(_ongoingDates[index].date),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                _ongoingDates[index].quantity.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                _ongoingDates[index].sold.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                _ongoingDates[index].expired.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => showSetDialog(index),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  child: Text('Set'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showSetDialog(int index) async {
    _totalQuantity.text = _ongoingDates[index].quantity.toString();
    _soldQuantity.text = _ongoingDates[index].sold.toString();
    _expiredQuantity.text = _ongoingDates[index].expired.toString();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Set Quantities:'),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.height * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        TextField(
                          controller: _totalQuantity,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Total Quantity'),
                          ),
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: TextField(
                            // onChanged: (String str) {
                            //   if (str.isEmpty) return;
                            //   _expiredQuantity.text =
                            //       (int.parse(_totalQuantity.text) -
                            //               int.parse(_soldQuantity.text))
                            //           .toString();
                            // },
                            controller: _soldQuantity,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Sold Quantity'),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        TextField(
                          controller: _expiredQuantity,
                          // onChanged: (String str) {
                          //   if (str.isEmpty) return;
                          //   _soldQuantity.text = (int.parse(_totalQuantity.text) -
                          //           int.parse(_expiredQuantity.text))
                          //       .toString();
                          // },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Expired Quantity'),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              setQuantities(_ongoingDates[index].id),
                          child: const Text('Set Quantities'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Expiration Dates'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              ManageExpirationDateControlPanel(
                productName: widget.product.name,
                showAddDialog: showAddDialog,
              ),
              const ExpirationDateListHeader(),
              Expanded(
                child: ListView.builder(
                  itemBuilder: _itemBuilder,
                  itemCount: _ongoingDates.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageExpirationDateControlPanel extends StatefulWidget {
  const ManageExpirationDateControlPanel({
    Key? key,
    required this.productName,
    required this.showAddDialog,
  }) : super(key: key);

  final String productName;
  final void Function() showAddDialog;

  @override
  State<ManageExpirationDateControlPanel> createState() =>
      _ManageExpirationDateControlPanelState();
}

class _ManageExpirationDateControlPanelState
    extends State<ManageExpirationDateControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderOne(
              padding: const EdgeInsets.all(15),
              text: widget.productName,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                onPressed: widget.showAddDialog,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  child: Text('Add Expiration Date'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ExpirationDateListHeader extends StatefulWidget {
  const ExpirationDateListHeader({Key? key}) : super(key: key);

  @override
  State<ExpirationDateListHeader> createState() =>
      _ExpirationDateListHeaderState();
}

class _ExpirationDateListHeaderState extends State<ExpirationDateListHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'ID',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Date',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Quantity',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Sold',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Expired',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Action',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
