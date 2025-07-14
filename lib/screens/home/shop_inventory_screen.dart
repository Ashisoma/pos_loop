import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:provider/provider.dart';

class InventoryByShopScreen extends StatelessWidget {
  final int shopId;
  const InventoryByShopScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryByShopProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shop Inventory'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'import') {
                    // Handle import inventory functionality
                    print('Import Inventory');
                    // Implement your import functionality
                  } else if (value == 'add') {
                    // Show add inventory item dialog
                    // You'll need to implement this dialog
                    print('Add Inventory Item');
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'import',
                        child: Text('Import Inventory'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'add',
                        child: Text('Add Inventory Item'),
                      ),
                    ],
              ),
            ],
          ),
          body: Consumer<InventoryByShopProvider>(
            builder: (context, provider, _) {
              final items = provider.inventoryItems;

              if (items.isEmpty) {
                return const Center(child: Text('No inventory found.'));
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                        '${item.shopName} - ${item.quantity} left',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Open edit screen or show dialog to update quantity
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              provider.deleteInventoryItem(item.inventoryId);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Removed floatingActionButton
        );
      },
    );
  }
}

// edit_quantity_dialog.dart
class EditQuantityDialog extends StatefulWidget {
  final int initialQty;
  const EditQuantityDialog({super.key, required this.initialQty});

  @override
  State<EditQuantityDialog> createState() => _EditQuantityDialogState();
}

class _EditQuantityDialogState extends State<EditQuantityDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQty.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Quantity'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Quantity'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = int.tryParse(_controller.text);
            if (qty != null) Navigator.pop(context, qty);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
