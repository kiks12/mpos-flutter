import 'package:flutter/material.dart';

class HeaderTwo extends StatefulWidget {
  const HeaderTwo({
    Key? key,
    required this.padding,
    required this.text,
  }) : super(key: key);

  final EdgeInsets padding;
  final String text;

  @override
  State<HeaderTwo> createState() => _HeaderTwoState();
}

class _HeaderTwoState extends State<HeaderTwo> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
