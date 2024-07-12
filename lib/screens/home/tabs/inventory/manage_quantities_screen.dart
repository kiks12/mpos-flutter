import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/expiration_dates.dart';
import 'package:mpos/models/inventory.dart';

class ManageQuantitiesScreen extends StatefulWidget {
  const ManageQuantitiesScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  State<ManageQuantitiesScreen> createState() =>
      _ManageQuantitiesScreenState();
}

class _ManageQuantitiesScreenState
    extends State<ManageQuantitiesScreen> {
  List<ExpirationDate> _ongoingDates = [];
  List<ExpirationDate> _expiredDates = [];

  final TextEditingController _totalQuantity = TextEditingController();
  final TextEditingController _soldQuantity = TextEditingController();
  final TextEditingController _expiredQuantity = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    initializeDates();
  }

  void initializeDates() {
    _expiredDates = [];
    _ongoingDates = [];
    final product = objectBox.productBox.get(widget.product.id);
    for (var exp in product!.expirationDates) {
      if (exp.date.isBefore(DateTime.now())) {
        _expiredDates.add(exp);
        continue;
      }

      _ongoingDates.add(exp);
      continue;
    }
    setState(() {});
  }

  _selectDate(BuildContext context, void Function(void Function()) setState) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2040),
    );
      _selectedDate = selected;
    setState(() {});
  }

  _addExpirationDate(BuildContext context) {
    ExpirationDate newExp = ExpirationDate(
      date: _selectedDate as DateTime,
      quantity: int.parse(_quantityController.text),
      expired: 0,
      sold: 0,
    );

    Product product = objectBox.productBox.get(widget.product.id) as Product;

    objectBox.expirationDateBox.put(newExp);

    product.quantity += int.parse(_quantityController.text);
    product.totalPrice = product.unitPrice * product.quantity;
    product.expirationDates.add(newExp);
    objectBox.productBox.put(product);

    Navigator.of(context).pop();
    initializeDates();
  }

  void deleteExpirationDate(BuildContext context, ExpirationDate expirationDate) async {
    try {
      final product = expirationDate.productExp.target;
      final productQuery = objectBox.productBox.get(product!.id);
      productQuery?.expirationDates.remove(expirationDate);
      objectBox.expirationDateBox.remove(expirationDate.id);
      Fluttertoast.showToast(msg: "Successfully deleted expiration date");
      initializeDates();
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> showDeleteExpirationDateConfirmationDialog(ExpirationDate expirationDate) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expiration Date'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                    'Are you sure you want to delete this expiration date?'),
                Text("${expirationDate.productExp.target!.name} - ${expirationDate.date.toString()}")
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
              onPressed: () => deleteExpirationDate(context, expirationDate),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAddDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => SimpleDialog(
            title: const Text('Add Quantity:'),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          TextField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)
                              ),
                              label: const Text('Quantity'),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  width: 0.5,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer
                                )
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    child: Text(_selectedDate != null
                                        ? DateFormat('yyyy-MM-dd')
                                        .format(_selectedDate as DateTime)
                                        : 'No Date Selected'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _selectDate(context, setState),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Text('Choose Date'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          FilledButton(
                            onPressed: () => _addExpirationDate(context),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void setQuantities(BuildContext context, int id) {
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

    Navigator.of(context).pop();
  }

  Container _itemBuilder(BuildContext context, int index) {
    final curr = _ongoingDates[index];
    return Container(
      decoration: BoxDecoration(
        color: curr.quantity == curr.expired + curr.sold
            ? const Color.fromARGB(255, 243, 243, 243)
            : Colors.transparent,
        border: const Border(
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
                onPressed: () => showDeleteExpirationDateConfirmationDialog(curr),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: curr.quantity == curr.expired + curr.sold
                          ? Colors.grey
                          : Colors.red,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: curr.quantity == curr.expired + curr.sold
                    ? () {}
                    : () => showSetDialog(index),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    'Set',
                    style: TextStyle(
                      color: curr.quantity == curr.expired + curr.sold
                          ? Colors.grey
                          : Colors.blueGrey,
                    ),
                  ),
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
                        FilledButton(
                          onPressed: () =>
                              setQuantities(context, _ongoingDates[index].id),
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
        title: const Text('Manage Product Quantities'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              ManageExpirationDateControlPanel(
                refresh: initializeDates,
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
    required this.refresh
  }) : super(key: key);

  final String productName;
  final void Function() showAddDialog;
  final void Function() refresh;

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
            Row(
              children: [
                FilledButton(
                  onPressed: widget.showAddDialog,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text('Add Quantity'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: IconButton.filledTonal(
                    onPressed: widget.refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ],
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
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
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
            flex: 2,
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
