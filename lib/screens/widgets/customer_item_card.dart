import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';
import 'package:pos_desktop_loop/providers/people_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_customer_form.dart';
import 'package:provider/provider.dart';

class CustomerItemCard extends StatefulWidget {
  final CustomerTable customer;

  const CustomerItemCard({super.key, required this.customer});

  @override
  State<CustomerItemCard> createState() => _CustomerItemCardState();
}

class _CustomerItemCardState extends State<CustomerItemCard> {
  bool _isExpanded = false;

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: Text(
              widget.customer.name?[0]?.toUpperCase() ?? '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(widget.customer.name ?? 'Unknown Customer'),
          subtitle: Text(widget.customer.phone ?? ''),
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
                if (widget.customer.companyName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Company: ${widget.customer.companyName}'),
                  ),
                if (widget.customer.address != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Address: ${widget.customer.address}'),
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
                      onPressed: () => _deleteCustomer(context),
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
        builder: (_) => NewCustomerForm(isEdit: true, data: widget.customer),
      ),
    ).then((_) {
      Provider.of<PeopleProvider>(context, listen: false).refreshData();
    });
  }

  Future<void> _deleteCustomer(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this customer?',
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
      final provider = Provider.of<PeopleProvider>(context, listen: false);
      provider
          .deleteCustomer(widget.customer.customerId!)
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Customer deleted successfully')),
            );
          })
          .catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete customer: $e')),
            );
          });
    }
  }
}
