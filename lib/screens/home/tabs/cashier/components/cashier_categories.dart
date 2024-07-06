
import 'package:flutter/material.dart';

class CashierCategories extends StatefulWidget {
  const CashierCategories({Key? key,
    required this.categoriesList,
    required this.selectedCategory,
    required this.setSelectedCategory
  }) : super(key: key);

  final List<String> categoriesList;
  final String selectedCategory;
  final void Function(String) setSelectedCategory;

  @override
  State<CashierCategories> createState() => _CashierCategoriesState();
}

class _CashierCategoriesState extends State<CashierCategories> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.categoriesList.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: widget.selectedCategory == category ?
              FilledButton(
                onPressed: () => widget.setSelectedCategory(category),
                child: Text(category)
              ) :
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.primary
                  )
                ),
                onPressed: () => widget.setSelectedCategory(category),
                child: Text(category)
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
