
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/inventory.dart';

class CashierVariantSelector extends StatefulWidget {
  const CashierVariantSelector({Key? key, required this.product, required this.addToCart, required this.quantity}) : super(key: key);

  final Product product;
  final void Function(Product) addToCart;
  final int quantity;

  @override
  State<CashierVariantSelector> createState() => _CashierVariantSelectorState();
}

class _CashierVariantSelectorState extends State<CashierVariantSelector> {

  void variantOnPressed(ProductVariant variant) {
    if (variant.quantity <= 0 || variant.quantity < widget.quantity) {
      Fluttertoast.showToast(msg: "Insufficient Stock");
      return;
    }
    final newProduct = Product(
      id: widget.product.id,
      name: "${widget.product.name}---${variant.name}",
      category: widget.product.category,
      unitPrice: variant.unitPrice,
      quantity: widget.product.quantity,
      totalPrice: variant.totalPrice,
      image: variant.image,
      withVariant: widget.product.withVariant,
    );
    newProduct.variants.addAll(widget.product.variants);
    widget.addToCart(newProduct);
    final variantToUpdate = widget.product.variants.where((element) => element.id == variant.id).first;
    variantToUpdate.quantity = variantToUpdate.quantity - widget.quantity;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return SimpleDialog(
        title: const Row(
          children: [
            Text("Choose Variant")
          ],
        ),
        children: [
          for (var variant in widget.product.variants) ...[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: FilledButton.tonal(
                  onPressed: () => variantOnPressed(variant),
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(variant.name)),
                        Expanded(child: Text(NumberFormat.currency(symbol: "₱").format(variant.unitPrice))),
                      ],
                    ),
                  ),
                ),
              )
            )
          ]
        ],
      );
    });
  }
}
