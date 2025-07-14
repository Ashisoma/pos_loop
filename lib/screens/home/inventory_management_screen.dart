import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/models/inventory_model.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_inventory_screen.dart';
import 'package:provider/provider.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    await context.read<InventoryByShopProvider>().fetchAllInventory();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryByShopProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryGreen,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (String result) {
              switch (result) {
                case 'new_inventory':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const NewInventoryScreen(isEdit: false),
                    ),
                  );
                  break;
                case 'import_inventory':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Import inventory coming soon!'),
                    ),
                  );
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'new_inventory',
                    child: Text('New Inventory'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'import_inventory',
                    child: Text('Import Inventory'),
                  ),
                ],
          ),
        ],
      ),
      body: Container(
        color: AppColors.naturalBackground,
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(InventoryByShopProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.inventoryItems.isEmpty) {
      return const Center(
        child: Text(
          "No inventory items found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: Colors.white,
      onRefresh: _loadInventory,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.inventoryItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = provider.inventoryItems[index];
          return SingleChildScrollView(
            child: InventoryItemCard(
              item: item,
              onDelete: () {
                provider.deleteInventoryItem(item.inventoryId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inventory item deleted successfully'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
                _loadInventory();
              },
              onEdit: () => _navigateToEditScreen(context, item),
            ),
          );
        },
      ),
    );
  }

  void _navigateToAddScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewInventoryScreen(isEdit: false),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, InventoryItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewInventoryScreen(isEdit: true, data: item),
      ),
    );
  }
}

class InventoryItemCard extends StatefulWidget {
  final InventoryItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<InventoryItemCard> createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends State<InventoryItemCard> {
  bool _isExpanded = false;

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    const collapsedHeight = 90.0;
    const expandedHeight = 150.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: _isExpanded ? expandedHeight : collapsedHeight,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _toggleExpanded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),

            // Expanded content
            if (_isExpanded)
              ExpandedSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Shop: ${widget.item.shopName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${widget.item.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),

                    // Action buttons
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            color: AppColors.primaryGreen,
                            onPressed: widget.onEdit,
                          ),
                          const SizedBox(width: 50),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            color: Colors.red.shade400,
                            onPressed: widget.onDelete,
                          ),
                        ],
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class ExpandedSection extends StatelessWidget {
  final Widget child;

  const ExpandedSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(child: child),
            ),
          );
        },
      ),
    );
  }
}
