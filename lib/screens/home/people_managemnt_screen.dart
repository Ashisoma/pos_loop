import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';
import 'package:pos_desktop_loop/providers/people_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_customer_form.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_supplier_form.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_user_form_screen.dart';
import 'package:pos_desktop_loop/screens/home/import_customer_screen.dart';
import 'package:pos_desktop_loop/screens/home/import_supplier_screen.dart';
import 'package:pos_desktop_loop/screens/widgets/custom_drawer.dart';
import 'package:pos_desktop_loop/screens/widgets/customer_item_card.dart';
import 'package:pos_desktop_loop/screens/widgets/supplier_item_card.dart';
import 'package:pos_desktop_loop/screens/widgets/user_item_card.dart';
import 'package:provider/provider.dart';

class PeopleManagementScreen extends StatefulWidget {
  const PeopleManagementScreen({super.key});

  @override
  State<PeopleManagementScreen> createState() => _PeopleManagementScreenState();
}

class _PeopleManagementScreenState extends State<PeopleManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  int? businessId;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PeopleProvider>(context, listen: false).fetchPeopleData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: width * 0.02),
        toolbarHeight: height * 0.08,
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: Colors.black,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Customers'),
            Tab(text: 'Suppliers'),
          ],
        ),
        title:
            _isSearching
                ? TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleSearch,
                    ),
                  ),
                )
                : const Text(
                  'People Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: _toggleSearch,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (context) {
              // Create a list with the "Add New" option
              final menuItems = [
                const PopupMenuItem(value: 'add', child: Text('Add New')),
              ];

              // Only add the "Import" option if we're not on the Users tab (index 0)
              if (_tabController.index != 0) {
                menuItems.add(
                  PopupMenuItem(
                    value: 'import',
                    child: Text(
                      'Import ${['Customers', 'Suppliers'][_tabController.index - 1]}',
                    ),
                  ),
                );
              }

              return menuItems;
            },
          ),
        ],
      ),
      drawer: const CustomDrawerWidget(),
      body: Consumer<PeopleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(
                items: provider.users,
                builder:
                    (item) => UserItemCard(
                      user: item,
                      onUpdate:
                          () => provider.refreshData(), // Add this callback
                    ),
              ),
              _buildTabContent(
                items: provider.customers,
                builder: (item) => CustomerItemCard(customer: item),
              ),
              _buildTabContent(
                items: provider.suppliers,
                builder: (item) => SupplierItemCard(supplier: item),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabContent<T>({
    required List<T> items,
    required Widget Function(T) builder,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) => builder(items[index]),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == 'add') {
      final routes = [
        () => MaterialPageRoute(
          builder: (_) => const NewUserFormScreen(isEdit: false),
        ),
        () => MaterialPageRoute(
          builder: (_) => const NewCustomerForm(isEdit: false),
        ),
        () => MaterialPageRoute(
          builder: (_) => const NewSupplierForm(isEdit: false),
        ),
      ];

      Navigator.push(context, routes[_tabController.index]()).then(
        (_) =>
            Provider.of<PeopleProvider>(context, listen: false).refreshData(),
      );
    } else if (value == 'import') {
  final currentTabIndex = _tabController.index;
  final tabNames = ['Users', 'Customers', 'Suppliers'];
  
  if (currentTabIndex == 1) { // Customers tab
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportCustomersPage(),
      ),
    );
  } else if (currentTabIndex == 2) { // Suppliers tab
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportSuppliersPage(),
      ),
    );
  } else { // Users tab (index 0)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Import not available for ${tabNames[currentTabIndex]}'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
  }
}
