import 'package:flutter/material.dart';

class TextFormFieldWithLabel extends StatefulWidget {
  const TextFormFieldWithLabel({
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
