
import 'package:flutter/material.dart';

import 'card_data.dart';

class HomeScreenCard extends StatefulWidget {
  const HomeScreenCard({Key? key, required this.cardData}) : super(key: key);

  final CardData cardData;

  @override
  State<HomeScreenCard> createState() => _HomeScreenCardState();
}

class _HomeScreenCardState extends State<HomeScreenCard> {

  void navigateToScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget.cardData.widget));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: navigateToScreen,
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.cardData.icon, size: 50),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(widget.cardData.text, style: const TextStyle(fontSize: 20),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
