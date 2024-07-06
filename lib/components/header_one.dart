import 'package:flutter/material.dart';

class HeaderOne extends StatefulWidget {
  const HeaderOne({
    Key? key,
    required this.padding,
    required this.text,
  }) : super(key: key);

  final EdgeInsets padding;
  final String text;

  @override
  State<HeaderOne> createState() => _HeaderOneState();
}

class _HeaderOneState extends State<HeaderOne> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
