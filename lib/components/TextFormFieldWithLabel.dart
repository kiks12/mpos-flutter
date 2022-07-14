import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldWithLabel extends StatefulWidget {
  const TextFormFieldWithLabel({
    Key? key,
    required this.label,
    required this.controller,
    required this.padding,
    required this.isPassword,
    this.onChanged,
    this.isNumber = false,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final TextEditingController controller;
  final bool isPassword;
  final void Function(String)? onChanged;
  final bool isNumber;

  @override
  State<TextFormFieldWithLabel> createState() => _TextFormFieldWithLabelState();
}

class _TextFormFieldWithLabelState extends State<TextFormFieldWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            keyboardType:
                widget.isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: widget.isNumber
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                  ]
                : [],
            onChanged: widget.onChanged ?? (String str) {},
            obscureText: widget.isPassword,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: widget.label,
            ),
            controller: widget.controller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please Enter some text";
              }

              return null;
            },
          )
        ],
      ),
    );
  }
}
