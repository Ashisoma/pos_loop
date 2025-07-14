import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/providers/user_provider.dart';
import 'package:pos_desktop_loop/screens/auth/login_screen.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_order_screen.dart';
import 'package:pos_desktop_loop/screens/home/home_screen.dart';
import 'package:pos_desktop_loop/screens/home/people_managemnt_screen.dart';
import 'package:pos_desktop_loop/screens/home/products_list_screen.dart';
import 'package:pos_desktop_loop/screens/home/select_shop_screen.dart';
import 'package:pos_desktop_loop/screens/home/settings_screen.dart';
import 'package:pos_desktop_loop/screens/home/shope_list_management_screen.dart';
import 'package:provider/provider.dart';

class CustomDrawerWidget extends StatelessWidget {
  const CustomDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final loading = Provider.of<UserProvider>(context).isLoading;
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              loading ? 'Loading...' : user!.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(loading ? '' : user!.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                loading ? '' : user!.fullName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text("Sales Point"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectShopScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Reports"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecting to Dashboard')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text("Shops"),
            onTap: () {
              final inventoryProvider = Provider.of<InventoryByShopProvider>(
                context,
                listen: false,
              );
              if (inventoryProvider.shops.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShopeListManagementScreen(),
                  ),
                );
              } else if (inventoryProvider.shops.length == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => NewOrderScreen(
                          shopId: inventoryProvider.shops.first.shopId!,
                        ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShopeListManagementScreen(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Products"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductsListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text("Stock"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecting to Dashboard')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text("Sales"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecting to Dashboard')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text("Financials"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Financials feature coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("People"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PeopleManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService.logout();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
