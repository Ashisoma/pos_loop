import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';
import 'package:pos_desktop_loop/providers/people_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_user_form_screen.dart';
import 'package:provider/provider.dart';

class UserItemCard extends StatefulWidget {
  final UserTable user;
  final VoidCallback onUpdate;

  const UserItemCard({super.key, required this.user, required this.onUpdate});

  @override
  State<UserItemCard> createState() => _UserItemCardState();
}

class _UserItemCardState extends State<UserItemCard> {
  bool _isUpdating = false;

  Future<void> _toggleUserStatus() async {
    setState(() => _isUpdating = true);
    try {
      final newStatus = !widget.user.isActive;
      final success = await Provider.of<PeopleProvider>(
        context,
        listen: false,
      ).updateUserStatus(widget.user.id!, newStatus);

      if (success) {
        widget.onUpdate(); // Notify parent to refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${newStatus ? 'activated' : 'deactivated'}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.user.fullName),
      subtitle: Text('${widget.user.email} • ${widget.user.role}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _navigateToEdit(context),
          ),
          if (_isUpdating)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: widget.user.isActive,
              onChanged: (_) => _toggleUserStatus(),
              activeColor: AppColors.primaryGreen,
            ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewUserFormScreen(isEdit: true, data: widget.user),
      ),
    ).then((_) => widget.onUpdate());
  }
}
