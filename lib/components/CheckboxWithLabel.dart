import 'package:flutter/material.dart';

class CheckboxWithLabel extends StatefulWidget {
  const CheckboxWithLabel({
    Key? key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChange,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final void Function(bool?) onChange;

  @override
  State<CheckboxWithLabel> createState() => _CheckboxWithLabelState();
}

class _CheckboxWithLabelState extends State<CheckboxWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(widget.label),
          Checkbox(
            value: widget.value,
            onChanged: widget.onChange,
          ),
        ],
      ),
    );
  }
}
