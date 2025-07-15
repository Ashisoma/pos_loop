import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';
import 'package:pos_desktop_loop/providers/user_provider.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName = "Admin User"; // Replace with actual user name

  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final initials = ;
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(userProvider.user!),

            // Account Section
            _buildSectionCard(
              title: 'Account Settings',
              children: [
                _buildProfileTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  subtitle: 'Update your profile details',
                  onTap: () {},
                ),
                _buildProfileTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your login credentials',
                  onTap: () {},
                ),
                _buildProfileTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notification Preferences',
                  subtitle: 'Manage app notifications',
                  onTap: () {},
                ),
              ],
            ),

            // Preferences Section
            _buildSectionCard(
              title: 'Preferences',
              children: [
                _buildProfileTile(
                  icon: Icons.color_lens_outlined,
                  title: 'App Theme',
                  subtitle: 'Change color scheme',
                  onTap: () {},
                ),
                _buildProfileTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'Set app language',
                  onTap: () {},
                ),
              ],
            ),

            // Actions Section
            _buildSectionCard(
              title: 'Actions',
              children: [
                _buildProfileTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Contact our support team',
                  onTap: () {},
                ),
                _buildProfileTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () {},
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserTable user) {
    var initials = user.fullName;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with initials
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.8),
                  AppColors.primaryGreen,
                ],
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User Name
          Text(
            user.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          // User Role
          Text(
            user.role!.toUpperCase(),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primaryGreen).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? AppColors.primaryGreen),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color ?? Colors.grey.shade400,
      ),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (name.isNotEmpty) {
      return name.substring(0, 2).toUpperCase();
    }
    return 'AU';
  }
}
