import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpos/screens/home/tabs/cashier/components/dialogs/cashier_selection_dialog.dart';

class CashierControlPanel extends StatefulWidget {
  const CashierControlPanel({
    Key? key,
    required this.scaffoldContext,
    required this.quantityController,
    required this.searchController,
    required this.searchProduct,
    required this.refresh,
    this.isLoading = false,
    this.onQuantityChanged,
  }) : super(key: key);

  final BuildContext scaffoldContext;
  final TextEditingController quantityController;
  final TextEditingController searchController;
  final void Function() searchProduct;
  final void Function() refresh;
  final bool isLoading;
  final void Function(String)? onQuantityChanged;

  @override
  State<CashierControlPanel> createState() => CashierControlPanelState();
}

class CashierControlPanelState extends State<CashierControlPanel> {
  bool _isSearchFocused = false;
  bool _isQuantityFocused = false;

  @override
  void initState() {
    super.initState();
    widget.quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    widget.quantityController.removeListener(_onQuantityChanged);
    super.dispose();
  }

  void _onQuantityChanged() {
    if (widget.onQuantityChanged != null) {
      widget.onQuantityChanged!(widget.quantityController.text);
    }
  }

  void _incrementQuantity() {
    final currentValue = int.tryParse(widget.quantityController.text) ?? 0;
    widget.quantityController.text = (currentValue + 1).toString();
  }

  void _decrementQuantity() {
    final currentValue = int.tryParse(widget.quantityController.text) ?? 0;
    if (currentValue > 0) {
      widget.quantityController.text = (currentValue - 1).toString();
    }
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isSearchFocused = hasFocus;
                });
              },
              child: TextFormField(
                controller: widget.searchController,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => widget.searchProduct(),
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: Icon(
                    Icons.search,
                    color: _isSearchFocused 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: widget.isLoading ? null : widget.searchProduct,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      const Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Decrease button
          Container(
            width: 40,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                onTap: _decrementQuantity,
                child: const Icon(
                  Icons.remove,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          
          // Quantity input
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isQuantityFocused = hasFocus;
                });
              },
              child: TextFormField(
                controller: widget.quantityController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  hintText: "Qty",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          // Increase button
          Container(
            width: 40,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                onTap: _incrementQuantity,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.refresh,
          child: Icon(
            Icons.refresh,
            color: Colors.grey[600],
            size: 24,
          ),
        ),
      ),
    );
  }

  Future<void> showCashierSelectionDialog() async {
    return showDialog(
      context: context, 
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return CashierSelectionDialog(rootContext: widget.scaffoldContext,);
      });
  }

  Widget _buildCashierButton() {
    return Container(
      width: 120,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: showCashierSelectionDialog,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 2,),
              Text("Cashier")
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout based on screen width
          if (constraints.maxWidth > 600) {
            // Desktop/Tablet layout
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSearchSection(),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 140,
                  child: _buildQuantitySection(),
                ),
                const SizedBox(width: 16),
                _buildRefreshButton(),
                const SizedBox(width: 16),
                _buildCashierButton()
              ],
            );
          } else {
            // Mobile layout
            return Column(
              children: [
                _buildSearchSection(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuantitySection(),
                    ),
                    const SizedBox(width: 12),
                    _buildRefreshButton(),
                    const SizedBox(width: 12),
                    _buildCashierButton()
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}