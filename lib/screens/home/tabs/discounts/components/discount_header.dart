import 'package:flutter/material.dart';

class DiscountScreenHeader extends StatefulWidget {
  const DiscountScreenHeader({
    Key? key,
    required this.searchController,
    required this.refresh,
    required this.search,
    required this.deleteAll,
    required this.addDiscount,
  }) : super(key: key);

  final TextEditingController searchController;
  final void Function() refresh;
  final void Function() search;
  final void Function() deleteAll;
  final void Function() addDiscount;

  @override
  State<DiscountScreenHeader> createState() => _DiscountScreenHeaderState();
}

class _DiscountScreenHeaderState extends State<DiscountScreenHeader> {
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
              onFieldSubmitted: (_) => widget.search(),
              decoration: InputDecoration(
                hintText: "Search discounts...",
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
            onPressed: widget.search,
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
            onPressed: widget.addDiscount,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Discount'),
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
          // Title and Search/Refresh Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                // Desktop/Tablet layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        Text(
                          'Discounts',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
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
                        Text(
                          'Discounts',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSearchAndActions(constraints.maxWidth),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),
          // Action Buttons Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                // Desktop/Tablet layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Empty space to push buttons to the right
                    const Spacer(),
                    _buildActionButtons(),
                  ],
                );
              } else {
                // Mobile layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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