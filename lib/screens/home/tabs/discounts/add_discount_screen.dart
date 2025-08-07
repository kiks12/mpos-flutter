import 'package:flutter/material.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/objectbox.g.dart';

class AddDiscountScreen extends StatefulWidget {
  const AddDiscountScreen({Key? key}) : super(key: key);

  @override
  State<AddDiscountScreen> createState() => _AddDiscountScreenState();
}

class _AddDiscountScreenState extends State<AddDiscountScreen> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  late TabController _categoriesTabController;
  final List<String> _categories = [];
  List<String> _products = [];
  
  static const discountOperations = ['PERCENTAGE', 'FIXED'];
  static const discountTypes = ['SPECIFIC', 'TOTAL'];
  
  var _selectedOperation = "";
  var _selectedDiscountType = "";
  var _selectedProducts = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeCategories();
    _categoriesTabController = TabController(length: _categories.length, initialIndex: 0, vsync: this);
    _categoriesTabController.addListener(() {
      initializeProductsAndPackages();
    });
    initializeProductsAndPackages();
    _selectedOperation = discountOperations[0];
    _selectedDiscountType = discountTypes[0];
    setState(() {});
  }

  void initializeCategories() {
    _categories.add("All");
    final query = objectBox.productBox.query().build();
    PropertyQuery<String> pq = query.property(Product_.category);
    pq.distinct = true;
    pq.find().forEach((element) { _categories.add(element); });
    setState(() {});
  }

  void initializeProductsAndPackages() {
    _products = [];
    final category = _categories[_categoriesTabController.index];
    final productQuery = objectBox.productBox.query().build();
    final packageQuery = objectBox.packagedProductBox.query().build();
    
    if (category == "All") {
      packageQuery.find().forEach((package) { _products.add(package.name); });
      productQuery.find().forEach((product) { _products.add(product.name); });
    } else {
      packageQuery.find().where((element) => element.category.contains(category)).forEach((package) { _products.add(package.name); });
      productQuery.find().where((element) => element.category == category).forEach((product) { _products.add(product.name); });
    }
    setState(() {});
  }

  void navigateToPreviousScreen() {
    Navigator.of(context).pop();
  }

  Future<void> createDiscount() async {
    if (!formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final newDiscount = Discount(
        title: titleController.text,
        operation: _selectedOperation,
        value: int.parse(valueController.text),
        category: "",
        type: _selectedDiscountType,
        products: _selectedProducts
      );
      
      objectBox.discountBox.put(newDiscount);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Discount "${titleController.text}" created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating discount: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isNumber = false,
    String? helperText,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prefixIcon != null)
          Row(
            children: [
              Icon(prefixIcon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          )
        else
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: validator,
          decoration: InputDecoration(
            hintText: "Enter $label",
            helperText: helperText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          )
        else
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 15),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildProductSelection() {
    if (_selectedDiscountType != "SPECIFIC") return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Select Products & Packages", icon: Icons.inventory_2_outlined),
        
        // Category Tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select products that apply to this discount",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            _selectedProducts = "";
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text("Clear All"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            final productList = <String>[];
                            for (var element in _products) {
                              productList.add(element);
                            }
                            _selectedProducts = productList.join("___");
                            setState(() {});
                          },
                          icon: const Icon(Icons.select_all, size: 16),
                          label: const Text("Select All"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Selected count indicator
              if (_selectedProducts.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${_selectedProducts.split('___').where((s) => s.isNotEmpty).length} products selected",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              // Category Tabs
              TabBar(
                controller: _categoriesTabController,
                isScrollable: true,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Theme.of(context).primaryColor,
                tabs: _categories.map((category) => Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                )).toList(),
              ),
              
              // Products Grid
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _categoriesTabController,
                  children: _categories.map((category) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: _products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No products found in this category",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 4,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                final isSelected = _selectedProducts.contains(product);
                                
                                return GestureDetector(
                                  onTap: () {
                                    final productsList = _selectedProducts.split("___");
                                    if (productsList.contains(product)) {
                                      productsList.remove(product);
                                    } else {
                                      productsList.add(product);
                                    }
                                    _selectedProducts = productsList.join("___");
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected 
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (val) {
                                            final productsList = _selectedProducts.split("___");
                                            if (productsList.contains(product)) {
                                              productsList.remove(product);
                                            } else {
                                              productsList.add(product);
                                            }
                                            _selectedProducts = productsList.join("___");
                                            setState(() {});
                                          },
                                          activeColor: Theme.of(context).primaryColor,
                                        ),
                                        Expanded(
                                          child: Text(
                                            product,
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                              color: isSelected 
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.grey[800],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create New Discount'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            margin: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.discount_outlined,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Create New Discount",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                "Set up a new discount for your products",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Basic Information
                      _buildSectionHeader("Basic Information", icon: Icons.info_outline),
                      
                      _buildTextFormField(
                        label: "Discount Title",
                        controller: titleController,
                        prefixIcon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a discount title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Discount Configuration
                      _buildSectionHeader("Discount Configuration", icon: Icons.settings_outlined),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: "Discount Type",
                              value: _selectedDiscountType,
                              items: discountTypes,
                              onChanged: (value) {
                                _selectedDiscountType = value.toString();
                                setState(() {});
                              },
                              icon: Icons.category_outlined,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildDropdownField(
                              label: "Operation",
                              value: _selectedOperation,
                              items: discountOperations,
                              onChanged: (value) {
                                _selectedOperation = value!;
                                setState(() {});
                              },
                              icon: Icons.calculate_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Value Input
                      _buildTextFormField(
                        label: "Discount Value ${_selectedOperation == 'PERCENTAGE' ? '(%)' : '(₱)'}",
                        controller: valueController,
                        isNumber: true,
                        prefixIcon: Icons.monetization_on_outlined,
                        helperText: _selectedOperation == 'PERCENTAGE' 
                            ? "Enter percentage value (1-100)"
                            : "Enter fixed amount in pesos",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a discount value';
                          }
                          final numValue = int.tryParse(value);
                          if (numValue == null || numValue <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          if (_selectedOperation == 'PERCENTAGE' && numValue > 100) {
                            return 'Percentage cannot exceed 100%';
                          }
                          return null;
                        },
                      ),

                      // Product Selection (conditional)
                      _buildProductSelection(),

                      const SizedBox(height: 48),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : navigateToPreviousScreen,
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text("Cancel"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : createDiscount,
                            icon: _isLoading 
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.add, size: 18),
                            label: Text(_isLoading ? "Creating..." : "Create Discount"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoriesTabController.dispose();
    titleController.dispose();
    valueController.dispose();
    super.dispose();
  }
}