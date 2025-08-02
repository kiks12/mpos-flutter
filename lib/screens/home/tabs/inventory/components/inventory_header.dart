
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart'; // For objectBox and Product_

class InventoryHeader extends StatefulWidget {
  const InventoryHeader({
    Key? key,
    required this.searchController,
    required this.onPressed,
    required this.refresh,
    required this.deleteAll,
    required this.addProduct,
    required this.inventoryValue,
    required this.showProductWithLessThan,
    required this.onCategoryDropdownChange,
  }) : super(key: key);

  final TextEditingController searchController;
  final void Function() onPressed;
  final void Function() refresh;
  final void Function() deleteAll;
  final void Function() addProduct;
  final void Function(int) showProductWithLessThan;
  final void Function(String) onCategoryDropdownChange;
  final String inventoryValue;

  @override
  State<InventoryHeader> createState() => _InventoryHeaderState();
}

class _InventoryHeaderState extends State<InventoryHeader> {
  final List<String> quantitiesDropdown = ["All", "100", "50", "25", "15", "10", "5", "0"];
  String selectedQuantity = "All";
  List<String> categoriesDropdown = [];
  String selectedCategory = "";

  @override
  void initState() {
    super.initState();
    _initializeCategories();
  }

  void _initializeCategories() {
    categoriesDropdown.add("All");
    final allProductCategories = _getCategories();
    for (var element in allProductCategories) {
      categoriesDropdown.add(element);
    }
    selectedCategory = "All";
    setState(() {});
  }

  List<String> _getCategories() {
    // This part depends on your ObjectBox setup.
    // Assuming objectBox and Product_ are correctly imported and accessible.
    try {
      final query = objectBox.productBox.query().build();
      final PropertyQuery<String> pq = query.property(Product_.category);
      pq.distinct = true;
      return pq.find();
    } catch (e) {
      // Handle error if ObjectBox is not initialized or Product_ is missing
      print("Error fetching categories: $e");
      return [];
    }
  }

  Widget _buildSearchAndActions(double maxWidth) {
    return Row(
      children: [
        Expanded(
          child: Container(
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
            child: TextFormField(
              controller: widget.searchController,
              maxLines: 1,
              minLines: 1,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => widget.onPressed(),
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: const Icon(Icons.search, size: 20),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          width: 48,
          child: IconButton(
            onPressed: widget.refresh,
            icon: const Icon(Icons.refresh),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    double? width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          height: 48, // Fixed height for consistency
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: widget.deleteAll,
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('Delete All'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: widget.addProduct,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inventory Value and Search/Refresh Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                // Desktop/Tablet layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inventory  |  ${NumberFormat.currency(symbol: '₱').format(double.tryParse(widget.inventoryValue) ?? 0.0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: _buildSearchAndActions(constraints.maxWidth),
                    ),
                  ],
                );
              } else {
                // Mobile layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory  |  ${NumberFormat.currency(symbol: '₱').format(double.tryParse(widget.inventoryValue) ?? 0.0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchAndActions(constraints.maxWidth),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),
          // Filters and Action Buttons Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                // Desktop/Tablet layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildFilterDropdown(
                          label: "Select Quantity:",
                          value: selectedQuantity,
                          items: quantitiesDropdown,
                          onChanged: (newVal) {
                            setState(() {
                              selectedQuantity = newVal.toString();
                            });
                            if (newVal == "All") {
                              widget.refresh();
                            } else {
                              widget.showProductWithLessThan(int.parse(newVal.toString()));
                            }
                          },
                          width: 180, // Fixed width for desktop dropdowns
                        ),
                        const SizedBox(width: 24),
                        _buildFilterDropdown(
                          label: "Select Category:",
                          value: selectedCategory,
                          items: categoriesDropdown,
                          onChanged: (newVal) {
                            setState(() {
                              selectedCategory = newVal.toString();
                            });
                            if (newVal == "All") {
                              widget.refresh();
                            } else {
                              widget.onCategoryDropdownChange(newVal.toString());
                            }
                          },
                          width: 180, // Fixed width for desktop dropdowns
                        ),
                      ],
                    ),
                    _buildActionButtons(),
                  ],
                );
              } else {
                // Mobile layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterDropdown(
                            label: "Select Quantity:",
                            value: selectedQuantity,
                            items: quantitiesDropdown,
                            onChanged: (newVal) {
                              setState(() {
                                selectedQuantity = newVal.toString();
                              });
                              if (newVal == "All") {
                                widget.refresh();
                              } else {
                                widget.showProductWithLessThan(int.parse(newVal.toString()));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFilterDropdown(
                            label: "Select Category:",
                            value: selectedCategory,
                            items: categoriesDropdown,
                            onChanged: (newVal) {
                              setState(() {
                                selectedCategory = newVal.toString();
                              });
                              if (newVal == "All") {
                                widget.refresh();
                              } else {
                                widget.onCategoryDropdownChange(newVal.toString());
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}