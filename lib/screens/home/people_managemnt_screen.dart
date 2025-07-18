import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';
import 'package:pos_desktop_loop/db/tables/supplier_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';
import 'package:pos_desktop_loop/providers/people_provider.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_customer_form.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_supplier_form.dart';
import 'package:pos_desktop_loop/screens/home/forms/new_user_form_screen.dart';
import 'package:pos_desktop_loop/screens/home/imports/import_customer_screen.dart';
import 'package:pos_desktop_loop/screens/home/imports/import_supplier_screen.dart';
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
  String _searchQuery = '';

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
                ? _buildSearchField()
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
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer<PeopleProvider>(
            builder: (context, provider, _) {
              final users = _searchUsers(provider.users, _searchQuery);
              return ListView.builder(
                itemCount: users.length,
                itemBuilder:
                    (_, index) => UserItemCard(
                      user: users[index],
                      onUpdate: provider.refreshData,
                    ),
              );
            },
          ),

          // Customers Tab
          Consumer<PeopleProvider>(
            builder: (context, provider, _) {
              final customers = _searchCustomers(
                provider.customers,
                _searchQuery,
              );
              return ListView.builder(
                itemCount: customers.length,
                itemBuilder:
                    (_, index) => CustomerItemCard(
                      customer: customers[index],
                      // onUpdate: provider.refreshData,
                    ),
              );
            },
          ),

          // Suppliers Tab
          Consumer<PeopleProvider>(
            builder: (context, provider, _) {
              final suppliers = _searchSuppliers(
                provider.suppliers,
                _searchQuery,
              );
              return ListView.builder(
                itemCount: suppliers.length,
                itemBuilder:
                    (_, index) => SupplierItemCard(
                      supplier: suppliers[index],
                      // onUpdate: provider.refreshData,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search...",
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _toggleSearch,
        ),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  

  List<UserTable> _searchUsers(List<UserTable> users, String query) {
    if (query.isEmpty) return users;
    return users
        .where(
          (user) =>
              user.fullName.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  List<CustomerTable> _searchCustomers(
    List<CustomerTable> customers,
    String query,
  ) {
    if (query.isEmpty) return customers;
    return customers
        .where(
          (customer) =>
              customer.name!.toLowerCase().contains(query.toLowerCase()) ||
              customer.phone!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  List<SupplierTable> _searchSuppliers(
    List<SupplierTable> suppliers,
    String query,
  ) {
    if (query.isEmpty) return suppliers;
    return suppliers
        .where(
          (supplier) =>
              supplier.companyName!.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              supplier.contactPerson!.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              supplier.phone!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
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

      if (currentTabIndex == 1) {
        // Customers tab
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImportCustomersPage()),
        );
      } else if (currentTabIndex == 2) {
        // Suppliers tab
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImportSuppliersPage()),
        );
      } else {
        // Users tab (index 0)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Import not available for ${tabNames[currentTabIndex]}',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
