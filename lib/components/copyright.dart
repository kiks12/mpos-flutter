
import 'package:flutter/material.dart';

class Copyright extends StatelessWidget {
  const Copyright({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return const  Center(
      child: Text("Powered by DOS Solutions",
        style: TextStyle(
          fontSize: 16
        ),
      ),
    );
  }
}
