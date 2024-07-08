
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_cart_header.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_grid_product_item.dart';

class CashierPackageBuilder extends StatefulWidget {
  const CashierPackageBuilder({Key? key,
    required this.package,
    required this.products,
    required this.addPackageToCart,
    required this.removePackageFromCart,
    this.inCart = false,
    this.packageIndexInCart = -1,
  }) : super(key: key);

  final PackagedProduct package;
  final List<Product> products;
  final void Function(PackagedProduct) addPackageToCart;
  final void Function(PackagedProduct, int) removePackageFromCart;
  final bool inCart;
  final int packageIndexInCart;

  @override
  State<CashierPackageBuilder> createState() => _CashierPackageBuilderState();
}

class _CashierPackageBuilderState extends State<CashierPackageBuilder> {
  late PackagedProduct package;

  @override
  void initState() {
    super.initState();
    package = widget.package;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void removeProductFromPackage(Product product, int index) {
    package.removeProduct(index);
    final removedProduct = widget.products.firstWhere((element) => element.id == product.id);
    removedProduct.quantity += product.quantity;
    calculatePackagePrice();
    setState(() {});
  }

  void calculatePackagePrice() {
    package.price = package.productsList.fold(0, (previousValue, element) => previousValue + element.totalPrice);
    setState(() {});
  }

  void addProductToPackage(Product product, int quantity) {
    if (quantity > package.quantity) {
      Fluttertoast.showToast(msg: "Quantity is bigger than number of items allowed in package: ${package.quantity}");
      return;
    }

    product.quantity -= quantity;
    final newProduct = Product(id: product.id, name: product.name, category: product.category, unitPrice: product.unitPrice, quantity: quantity, totalPrice: product.unitPrice * quantity, image: "");
    final int packageQuantityCount = package.productsList.fold(0, (previousValue, element) => previousValue + element.quantity);
    if (packageQuantityCount == package.quantity) {
      Fluttertoast.showToast(msg: "Package is Full");
      return;
    }

    package.addProduct(newProduct);
    calculatePackagePrice();
    setState((){});
  }

  Future<void> showRemoveProductDialog(Product product, int index) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => SimpleDialog(
              title: const Text("Remove from Cart"),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text("Are you sure you want to remove ${product.name} from cart?"),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () { Navigator.of(context).pop(); }, child: const Text("Cancel")),
                      FilledButton(onPressed: () {
                        Navigator.of(context).pop();
                        removeProductFromPackage(product, index);
                        setState(() {});
                      }, child: const Text("Remove")),
                    ],
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  void close() {
    final int packageQuantity = package.productsList.fold(0, (previousValue, element) => previousValue + element.quantity);
    if (packageQuantity == package.quantity) {
      Navigator.of(context).pop();
      return;
    }
    Fluttertoast.showToast(msg: "Items does not match the package quantity: ${package.quantity}");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final itemHeight = size.height / 2.55;
    final itemWidth = size.width / 8;

    return StatefulBuilder(builder: (context, setState) {
      return Row(
        children: [
          SimpleDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Select ${package.quantity} item: "),
                IconButton(onPressed: close, icon: const Icon(Icons.close)),
              ],
            ),
            children: [
              SizedBox(
                width: 610,
                height: 500,
                child: GridView.count(
                    childAspectRatio: (itemWidth/itemHeight),
                    shrinkWrap: true,
                    crossAxisCount: 5,
                    children:  [
                      for (var product in widget.products) CashierGridProductItem(product: product, addToCart: addProductToPackage),
                    ]
                ),
              ),
            ],
          ),
          SimpleDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Complete your Package"),
                IconButton(onPressed: close, icon: const Icon(Icons.close)),
              ],
            ),
            children: [
              SizedBox(
                width: 180,
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CartHeader(),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                      Flexible(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.package.name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(""),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.package.quantity.toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      NumberFormat.currency(symbol: '₱')
                                          .format(widget.package.price),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...package.productsList.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await showRemoveProductDialog(e.value, e.key);
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e.value.name,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormat.currency(symbol: "₱").format(e.value.unitPrice),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value.quantity.toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormat.currency(symbol: '₱')
                                            .format(e.value.totalPrice),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.inCart) Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilledButton.tonal(onPressed: (){
                              widget.removePackageFromCart(widget.package, widget.packageIndexInCart);
                              calculatePackagePrice();
                              setState((){});
                            }, child: const Text("Remove")),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilledButton.tonal(onPressed: (){
                              package.clear();
                              calculatePackagePrice();
                              setState((){});
                            }, child: const Text("Clear")),
                          ),
                          if (!widget.inCart)
                            Expanded(
                              child: FilledButton(onPressed: (){
                                final int packageQuantity = package.productsList.fold(0, (previousValue, element) => previousValue + element.quantity);
                                if (package.quantity != packageQuantity) {
                                  Fluttertoast.showToast(msg: "Package product quantity not matching items should be ${package.quantity}");
                                  return;
                                }
                                widget.addPackageToCart(package);
                                Navigator.of(context).pop();
                              }, child: const Text("Add to Cart")),
                            ),
                          if (widget.inCart)
                            Expanded(
                              child: FilledButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: const Text("Update")),
                            ),
                        ],
                      ),

                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      );
    });
  }
}
