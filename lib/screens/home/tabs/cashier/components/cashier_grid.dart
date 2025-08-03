import 'package:flutter/material.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_grid_package_item.dart';
import 'package:mpos/screens/home/tabs/cashier/components/cashier_grid_product_item.dart';

class CashierGrid extends StatefulWidget {
  const CashierGrid({
    Key? key,
    required this.categoriesList,
    required this.productsList,
    required this.packageList,
    required this.addToCart,
    required this.addPackageToCart,
    required this.setSelectedCategory,
    required this.selectedCategory,
    required this.quantity,
    this.isLoading = false,
  }) : super(key: key);

  final void Function(Product) addToCart;
  final void Function(PackagedProduct) addPackageToCart;
  final void Function(String) setSelectedCategory;
  final List<String> categoriesList;
  final List<Product> productsList;
  final List<PackagedProduct> packageList;
  final String selectedCategory;
  final int quantity;
  final bool isLoading;

  @override
  State<CashierGrid> createState() => _CashierGridState();
}

class _CashierGridState extends State<CashierGrid> {
  int _getCrossAxisCount(double width) {
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }

  double _getChildAspectRatio(double width) {
    if (width > 1200) return 0.85;
    if (width > 900) return 0.8;
    if (width > 600) return 0.75;
    return 0.7;
  }

  Widget _buildCategoriesSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: widget.categoriesList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = widget.categoriesList[index];
                final isSelected = category == widget.selectedCategory;
                
                return FilterChip(
                  selected: isSelected,
                  label: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Colors.grey[100],
                  selectedColor: Theme.of(context).primaryColor,
                  onSelected: (selected) {
                    widget.setSelectedCategory(category);
                  },
                  elevation: isSelected ? 4 : 0,
                  pressElevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
        
        // Combine packages and products
        final allItems = <Widget>[
          ...widget.packageList.map((package) => _buildPackageItem(package)),
          ...widget.productsList.map((product) => _buildProductItem(product)),
        ];

        if (allItems.isEmpty && !widget.isLoading) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: allItems.length,
          itemBuilder: (context, index) => allItems[index],
        );
      },
    );
  }

  Widget _buildProductItem(Product product) {
    return CashierGridProductItem(product: product, addToCart: widget.addToCart, quantity: widget.quantity);
  }

  Widget _buildPackageItem(PackagedProduct package) {
    return CashierGridPackageItem(package: package, products: widget.productsList, addPackageToCart: widget.addPackageToCart);
  }

  Widget _buildProductIcon() {
    return Icon(
      Icons.shopping_bag,
      color: Colors.grey[400],
      size: 32,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.selectedCategory.isNotEmpty
                ? 'No products in "${widget.selectedCategory}" category'
                : 'Try selecting a different category or search for products',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildCategoriesSection(),
            Expanded(
              child: widget.isLoading 
                  ? _buildLoadingState()
                  : _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }
}