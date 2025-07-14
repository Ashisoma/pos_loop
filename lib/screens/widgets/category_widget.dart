import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_category_screen.dart';
import 'package:provider/provider.dart';

class CategoryItemCard extends StatefulWidget {
  const CategoryItemCard({
    super.key,
    required this.category,
    required this.width,
    required this.height,
    required this.index,
  });

  final double width;
  final double height;
  final int index;
  final CategoriesTable category;

  @override
  State<CategoryItemCard> createState() => _CategoryItemCardState();
}

class _CategoryItemCardState extends State<CategoryItemCard> {
  bool _isExpanded = false;

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  Future<void> _deleteItem(int? id) async {
    if (id == null) return;
    final provider = Provider.of<InventoryByShopProvider>(
      context,
      listen: false,
    );
    await provider.deleteCategory(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category deleted successfully'),
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
            subtitle:
                widget.category.description.isNotEmpty
                    ? Text(
                      widget.category.description,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                    : null,
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
                if (widget.category.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Description: ${widget.category.description}',
                      style: TextStyle(color: Colors.grey.shade700),
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
                                (_) => NewCategoryScreen(
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
