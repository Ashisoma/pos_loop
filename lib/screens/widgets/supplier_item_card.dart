import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/tables/supplier_table.dart';
import 'package:pos_desktop_loop/providers/people_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_supplier_form.dart';
import 'package:provider/provider.dart';

class SupplierItemCard extends StatefulWidget {
  final SupplierTable supplier;

  const SupplierItemCard({super.key, required this.supplier});

  @override
  State<SupplierItemCard> createState() => _SupplierItemCardState();
}

class _SupplierItemCardState extends State<SupplierItemCard> {
  bool _isExpanded = false;

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: Text(
              widget.supplier.companyName?[0]?.toUpperCase() ?? '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(widget.supplier.companyName ?? 'Unknown Supplier'),
          subtitle: Text(widget.supplier.phone ?? ''),
          onTap: _toggleExpanded,
        ),
        if (_isExpanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.supplier.contactPerson != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Contact: ${widget.supplier.contactPerson}'),
                  ),
                if (widget.supplier.address != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Address: ${widget.supplier.address}'),
                  ),
                if (widget.supplier.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Notes: ${widget.supplier.description}'),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text('Edit'),
                      onPressed: () => _navigateToEdit(context),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete'),
                      onPressed: () => _deleteSupplier(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewSupplierForm(isEdit: true, data: widget.supplier),
      ),
    ).then((_) {
      Provider.of<PeopleProvider>(context, listen: false).refreshData();
    });
  }

  Future<void> _deleteSupplier(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this supplier?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<PeopleProvider>(context, listen: false);
        await provider.deleteSupplier(widget.supplier.supplierId!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete supplier: $e')),
        );
      }
    }
  }
}
