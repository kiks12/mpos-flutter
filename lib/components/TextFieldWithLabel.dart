import 'package:flutter/material.dart';

class TextFieldWithLabel extends StatefulWidget {
  const TextFieldWithLabel({
    Key? key,
    required this.label,
    required this.controller,
    required this.padding,
    required this.isPassword,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final TextEditingController controller;
  final bool isPassword;

  @override
  State<TextFieldWithLabel> createState() => _TextFieldWithLabelState();
}

class _TextFieldWithLabelState extends State<TextFieldWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            obscureText: widget.isPassword,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: widget.label,
            ),
            controller: widget.controller,
          )
        ],
      ),
    );
  }
}
