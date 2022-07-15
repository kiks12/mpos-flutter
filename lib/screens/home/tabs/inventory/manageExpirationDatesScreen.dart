import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    initializeDates();

    print(_ongoingDates);
    print(_expiredDates);
  }

  void initializeDates() {
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
        title: const Text('Manage Expiration Dates  | '),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
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
