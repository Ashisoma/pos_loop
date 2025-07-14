import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';
import 'package:pos_desktop_loop/providers/product_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_tax_category_form_screen.dart';
import 'package:provider/provider.dart';

class TaxCategoryItemCard extends StatefulWidget {
  const TaxCategoryItemCard({
    super.key,
    required this.category,
    required this.width,
    required this.height,
    required this.index,
  });

  final double width;
  final double height;
  final int index;
  final TaxCategoryTable category;

  @override
  State<TaxCategoryItemCard> createState() => _TaxCategoryItemCardState();
}

class _TaxCategoryItemCardState extends State<TaxCategoryItemCard> {
  bool _isExpanded = false;

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  Future<void> _deleteItem(int? id) async {
    if (id == null) return;
    final provider = Provider.of<ProductsProvider>(context, listen: false);
    await provider.deleteTaxCategory(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tax category deleted successfully'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: ListTile(
            title: Text(
              widget.category.name,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            subtitle: Text(
              '${widget.category.taxPercentage.toStringAsFixed(2)}% Tax',
              style: TextStyle(color: Colors.grey.shade600),
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
                Text(
                  'Description: ${widget.category.description?.isNotEmpty == true ? widget.category.description! : 'No description'}',
                  style: TextStyle(
                    color:
                        widget.category.description?.isNotEmpty == true
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                  ),
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
                                (_) => NewTaxCategoryFormScreen(
                                  isEdit: true,
                                  category: widget.category,
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
                      onPressed: () => _deleteItem(widget.category.id),
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
