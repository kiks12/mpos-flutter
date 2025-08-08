import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart';

class DashboardSummary extends StatefulWidget {
  const DashboardSummary({Key? key}) : super(key: key);

  @override
  State<DashboardSummary> createState() => _DashboardSummaryState();
}

class _DashboardSummaryState extends State<DashboardSummary> with TickerProviderStateMixin {
  late double salesToday;
  late double cashSalesToday;
  late double gcashSalesToday;
  late double foodpandaSalesToday;
  late double grabSalesToday;
  late int transactionCount;
  late int itemsSold;
  late int packagesSold;
  late DateTime dateNow;
  late String formattedDateNow;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    setState(() {
      dateNow = DateTime.now();
      formattedDateNow = DateFormat('yyyy-MM-dd').format(dateNow);
    });
    fetchSalesToday();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchSalesToday() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final salesQuery = objectBox.saleBox.query(Sale_.date.equalsDate(DateTime.parse(formattedDateNow))).build();
      final sales = salesQuery.find();
      
      setState(() {
        salesToday = sales.fold(0.0, (double prev, element) => prev + element.totalAmount);
        cashSalesToday = sales.where((sale) => sale.paymentMethod == "Cash").fold(0.0, (double prev, element) => prev + element.totalAmount);
        gcashSalesToday = sales.where((sale) => sale.paymentMethod == "GCash").fold(0.0, (double prev, element) => prev + element.totalAmount);
        foodpandaSalesToday = sales.where((sale) => sale.paymentMethod == "Foodpanda").fold(0.0, (double prev, element) => prev + element.totalAmount);
        grabSalesToday = sales.where((sale) => sale.paymentMethod == "Grab").fold(0.0, (double prev, element) => prev + element.totalAmount);
        transactionCount = sales.length;
        itemsSold = sales.fold(0, (int prev, element) => prev + element.products.length + element.packages.map((package) => package.quantity).fold(0, (int prev, element) => prev + element));
        packagesSold = sales.fold(0, (int prev, element) => prev + element.packages.length);
      });
      
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    int animationDelay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (animationDelay * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    if (subtitle != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodCard({
    required String method,
    required double amount,
    required IconData icon,
    required Color color,
    int animationDelay = 0,
  }) {
    final percentage = salesToday > 0 ? (amount / salesToday * 100) : 0.0;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (animationDelay * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
            padding: const EdgeInsets.all(16),
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
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(symbol: '₱').format(amount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading dashboard data...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.dashboard_outlined,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Today's Summary",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(dateNow),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          _animationController.reset();
                          fetchSalesToday();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: Theme.of(context).primaryColor,
                        ),
                        tooltip: 'Refresh Data',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main Summary Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    // Desktop/Tablet layout - 2x2 grid
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: "Total Sales",
                                value: NumberFormat.currency(symbol: '₱').format(salesToday),
                                icon: Icons.monetization_on_outlined,
                                color: Colors.green,
                                subtitle: "Today",
                                animationDelay: 0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                title: "Transactions",
                                value: transactionCount.toString(),
                                icon: Icons.receipt_long_outlined,
                                color: Colors.blue,
                                subtitle: "Count",
                                animationDelay: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: "Items Sold",
                                value: itemsSold.toString(),
                                icon: Icons.inventory_2_outlined,
                                color: Colors.orange,
                                subtitle: "Units",
                                animationDelay: 2,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                title: "Packages Sold",
                                value: packagesSold.toString(),
                                icon: Icons.card_giftcard_outlined,
                                color: Colors.purple,
                                subtitle: "Bundles",
                                animationDelay: 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout - single column
                    return Column(
                      children: [
                        _buildSummaryCard(
                          title: "Total Sales",
                          value: NumberFormat.currency(symbol: '₱').format(salesToday),
                          icon: Icons.monetization_on_outlined,
                          color: Colors.green,
                          subtitle: "Today",
                          animationDelay: 0,
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard(
                          title: "Transactions",
                          value: transactionCount.toString(),
                          icon: Icons.receipt_long_outlined,
                          color: Colors.blue,
                          subtitle: "Count",
                          animationDelay: 1,
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard(
                          title: "Items Sold",
                          value: itemsSold.toString(),
                          icon: Icons.inventory_2_outlined,
                          color: Colors.orange,
                          subtitle: "Units",
                          animationDelay: 2,
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard(
                          title: "Packages Sold",
                          value: packagesSold.toString(),
                          icon: Icons.card_giftcard_outlined,
                          color: Colors.purple,
                          subtitle: "Bundles",
                          animationDelay: 3,
                        ),
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 32),

              // Payment Methods Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Payment Methods Breakdown",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        _buildPaymentMethodCard(
                          method: "Cash",
                          amount: cashSalesToday,
                          icon: Icons.money,
                          color: Colors.green,
                          animationDelay: 0,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentMethodCard(
                          method: "GCash",
                          amount: gcashSalesToday,
                          icon: Icons.phone_android,
                          color: Colors.blue,
                          animationDelay: 1,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentMethodCard(
                          method: "Foodpanda",
                          amount: foodpandaSalesToday,
                          icon: Icons.delivery_dining,
                          color: Colors.pink,
                          animationDelay: 2,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentMethodCard(
                          method: "Grab",
                          amount: grabSalesToday,
                          icon: Icons.local_taxi,
                          color: Colors.orange,
                          animationDelay: 3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}