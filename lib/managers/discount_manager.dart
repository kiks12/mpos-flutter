
// Create a new file: lib/services/discount_calculator.dart
import 'package:mpos/models/discounts.dart';
import 'package:mpos/models/inventory.dart';

class DiscountResult {
  final double totalDiscount;
  final Map<String, double> discountBreakdown;
  final List<String> errors;

  DiscountResult({
    required this.totalDiscount,
    required this.discountBreakdown,
    required this.errors,
  });
}

class DiscountCalculator {
  static DiscountResult calculateDiscounts({
    required List<Discount> appliedDiscounts,
    required List<Product> cartProducts,
    required List<PackagedProduct> cartPackages,
    required double subtotal,
  }) {
    double totalDiscount = 0.0;
    Map<String, double> discountBreakdown = {};
    List<String> errors = [];

    // Validate discounts first
    final validationErrors = _validateDiscounts(appliedDiscounts);
    if (validationErrors.isNotEmpty) {
      return DiscountResult(
        totalDiscount: 0.0,
        discountBreakdown: {},
        errors: validationErrors,
      );
    }

    // Calculate each discount
    for (final discount in appliedDiscounts) {
      try {
        final discountAmount = _calculateSingleDiscount(
          discount: discount,
          cartProducts: cartProducts,
          cartPackages: cartPackages,
          subtotal: subtotal,
        );
        
        totalDiscount += discountAmount;
        discountBreakdown[discount.title] = discountAmount;
      } catch (e) {
        errors.add('Error calculating ${discount.title}: $e');
      }
    }

    // Ensure discount doesn't exceed subtotal
    if (totalDiscount > subtotal) {
      totalDiscount = subtotal;
      errors.add('Total discount capped at subtotal amount');
    }

    return DiscountResult(
      totalDiscount: totalDiscount,
      discountBreakdown: discountBreakdown,
      errors: errors,
    );
  }

  static double _calculateSingleDiscount({
    required Discount discount,
    required List<Product> cartProducts,
    required List<PackagedProduct> cartPackages,
    required double subtotal,
  }) {
    switch (discount.type) {
      case "TOTAL":
        return _calculateTotalDiscount(discount, subtotal);
      case "SPECIFIC":
        return _calculateSpecificDiscount(discount, cartProducts, cartPackages);
      default:
        throw Exception('Unknown discount type: ${discount.type}');
    }
  }

  static double _calculateTotalDiscount(Discount discount, double subtotal) {
    switch (discount.operation) {
      case "FIXED":
        return discount.value.toDouble();
      case "PERCENTAGE":
        return subtotal * (discount.value / 100);
      default:
        throw Exception('Unknown discount operation: ${discount.operation}');
    }
  }

  static double _calculateSpecificDiscount(
    Discount discount,
    List<Product> cartProducts,
    List<PackagedProduct> cartPackages,
  ) {
    double discountAmount = 0.0;

    // Calculate discount for individual products
    for (final product in cartProducts) {
      if (discount.products.contains(product.name)) {
        switch (discount.operation) {
          case "FIXED":
            discountAmount += discount.value * product.quantity;
            break;
          case "PERCENTAGE":
            discountAmount += product.totalPrice * (discount.value / 100);
            break;
        }
      }
    }

    // Calculate discount for packages
    for (final package in cartPackages) {
      if (discount.products.contains(package.name)) {
        switch (discount.operation) {
          case "FIXED":
            discountAmount += discount.value;
            break;
          case "PERCENTAGE":
            discountAmount += package.price * (discount.value / 100);
            break;
        }
      }

      // Check products within packages
      for (final product in package.productsList) {
        if (discount.products.contains(product.name)) {
          switch (discount.operation) {
            case "FIXED":
              discountAmount += discount.value * product.quantity;
              break;
            case "PERCENTAGE":
              discountAmount += product.totalPrice * (discount.value / 100);
              break;
          }
        }
      }
    }

    return discountAmount;
  }

  static List<String> _validateDiscounts(List<Discount> discounts) {
    List<String> errors = [];
    
    // Check for duplicate discounts
    final discountTitles = discounts.map((d) => d.title).toList();
    final uniqueTitles = discountTitles.toSet();
    if (discountTitles.length != uniqueTitles.length) {
      errors.add('Duplicate discounts detected');
    }

    // Add more validation rules as needed
    // Example: Check for conflicting discount types
    final totalDiscounts = discounts.where((d) => d.type == "TOTAL").length;
    if (totalDiscounts > 1) {
      errors.add('Only one total discount can be applied');
    }

    return errors;
  }
}

// Enhanced Discount Manager for state management
class DiscountManager {
  List<Discount> _appliedDiscounts = [];
  DiscountResult? _lastResult;

  List<Discount> get appliedDiscounts => List.unmodifiable(_appliedDiscounts);
  double get totalDiscount => _lastResult?.totalDiscount ?? 0.0;
  Map<String, double> get discountBreakdown => _lastResult?.discountBreakdown ?? {};
  List<String> get errors => _lastResult?.errors ?? [];

  bool addDiscount(Discount discount) {
    // Check if discount already exists
    if (_appliedDiscounts.any((d) => d.title == discount.title)) {
      return false;
    }
    
    _appliedDiscounts.add(discount);
    return true;
  }

  bool removeDiscount(String discountTitle) {
    final initialLength = _appliedDiscounts.length;
    _appliedDiscounts.removeWhere((d) => d.title == discountTitle);
    return _appliedDiscounts.length < initialLength;
  }

  void clearDiscounts() {
    _appliedDiscounts.clear();
    _lastResult = null;
  }

  DiscountResult calculateDiscounts({
    required List<Product> cartProducts,
    required List<PackagedProduct> cartPackages,
    required double subtotal,
  }) {
    _lastResult = DiscountCalculator.calculateDiscounts(
      appliedDiscounts: _appliedDiscounts,
      cartProducts: cartProducts,
      cartPackages: cartPackages,
      subtotal: subtotal,
    );
    return _lastResult!;
  }
}