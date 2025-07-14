import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/providers/product_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_product_screen.dart';
import 'package:pos_desktop_loop/screens/home/inventory_management_screen.dart';
import 'package:provider/provider.dart';

class ProductItemCard extends StatefulWidget {
  const ProductItemCard({
    super.key,
    required this.product,
    required this.width,
    required this.height,
    required this.index,
  });

  final double width;
  final double height;
  final int index;
  final ProductsTable product;

  @override
  State<ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard> {
  bool _isExpanded = false;

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  Future<void> _deleteProduct(int? id) async {
    if (id == null) return;
    final productProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );
    await productProvider.deleteProduct(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product deleted successfully'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnOffer = (widget.product.offerPrice ?? 0) > 0;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: ListTile(
            title: Text(
              widget.product.name ?? 'Unknown Product',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Retail: KSh ${widget.product.retailPrice?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    Text(
                      'Cost: KSh ${widget.product.buyingPrice?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey.shade600,
            ),
            onTap: _toggleExpanded,
          ),
        ),
        if (_isExpanded)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.product.isService == 1)
                  const Text('Type: Service')
                else ...[
                  Text('Quantity: ${widget.product.quantity ?? 'N/A'}'),
                  Text(
                    'Wholesale Price: KSh ${widget.product.wholesalePrice?.toStringAsFixed(2) ?? '0.00'}',
                  ),
                ],
                if (isOnOffer)
                  Text(
                    'Offer Price: KSh ${widget.product.offerPrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(color: Colors.green),
                  ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => NewProductScreen(
                                  isEdit: true,
                                  product: widget.product,
                                  isService:
                                      widget.product.isService ==
                                      1, // Convert to bool
                                  shopId: widget.product.shopId,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => _deleteProduct(widget.product.id),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
