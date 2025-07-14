import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';
import 'package:pos_desktop_loop/screens/home/people_managemnt_screen.dart';

class NewUserFormScreen extends StatefulWidget {
  final bool isEdit;
  final UserTable? data;

  const NewUserFormScreen({super.key, required this.isEdit, this.data});

  @override
  State<NewUserFormScreen> createState() => _NewUserFormScreenState();
}

class _NewUserFormScreenState extends State<NewUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _visiblePassword = false;
  List<ShopTable> _selectedShops = [];

  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  RoleItem? _selectedRole;
  List<ShopTable> shops = [];
  bool _isLoadingShops = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    __loadShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.isEdit ? 'Edit User' : 'Add New User',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  _isLoading
                      ? widget.isEdit
                          ? 'Updating user...'
                          : 'Creating user...'
                      : '',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Name*',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Please enter full name'
                                  : null,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email*',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                        ).hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_visiblePassword,
                      decoration: InputDecoration(
                        labelText: 'Password*',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _visiblePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              () => setState(
                                () => _visiblePassword = !_visiblePassword,
                              ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RoleItem>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role*',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          RoleItem.items.map((role) {
                            return DropdownMenuItem<RoleItem>(
                              value: role,
                              child: Text(role.name),
                            );
                          }).toList(),
                      onChanged:
                          _isLoading
                              ? null
                              : (value) =>
                                  setState(() => _selectedRole = value),
                      validator:
                          (value) =>
                              value == null ? 'Please select a role' : null,
                    ),
                    if (_selectedRole?.value != 'admin') ...[
                      const SizedBox(height: 16),
                      const Text('Assign Shops:'),
                      _isLoadingShops
                          ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          )
                          : Column(
                            children:
                                shops.map((shop) {
                                  return CheckboxListTile(
                                    title: Text(
                                      '${shop.name} - ${shop.branch}',
                                    ),
                                    value: _selectedShops.contains(shop),
                                    onChanged:
                                        _isLoading
                                            ? null
                                            : (bool? selected) {
                                              setState(() {
                                                if (selected == true) {
                                                  _selectedShops.add(shop);
                                                } else {
                                                  _selectedShops.remove(shop);
                                                }
                                              });
                                            },
                                  );
                                }).toList(),
                          ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              _isLoading ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _registerUser,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(120, 48),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    widget.isEdit ? 'Save Changes' : 'Add User',
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = UserTable(
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole?.value ?? 'cashier',
        fullName: _fullNameController.text.trim(),
        sync: 0,
        isActive: true,
      );
      int? res = await AuthService.register(user);

      // assign user to a shop if role is not admin
      if (_selectedRole?.value != 'admin') {
        int shopId =
            _selectedShops.isNotEmpty ? _selectedShops.first.shopId! : 0;
        if (shopId > 0) {
          int? rest = await AuthService.assignUserToShop(res!, shopId);
          if (rest == null || rest <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to assign user to shop')),
            );
            return;
          }
        }
      }

      if (res! > 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PeopleManagementScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User already exists')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  _fetchData() {
    if (widget.isEdit && widget.data != null) {
      // Editing an existing user - populate all fields including role
      _phoneController.text = widget.data!.phoneNumber;
      _passwordController.text = widget.data!.password;
      _emailController.text = widget.data!.email;
      _fullNameController.text = widget.data!.fullName;

      // Set role to the user's current role
      _selectedRole = RoleItem.items.firstWhere(
        (role) => role.value == widget.data!.role,
        orElse: () => RoleItem(name: 'Cashier', value: 'cashier'),
      );
    } else {
      // Adding a new user - set default role to Cashier
      _selectedRole = RoleItem.items.firstWhere(
        (role) => role.value == 'cashier',
        orElse: () => RoleItem(name: 'Cashier', value: 'cashier'),
      );
    }
  }

  void __loadShops() async {
    setState(() => _isLoadingShops = true);
    try {
      var dbShops = await ShopTable.getAllShops();
      setState(() {
        shops = dbShops;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading shops: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoadingShops = false);
    }
  }
}

class RoleItem {
  final String name;
  final String value;

  RoleItem({required this.name, required this.value});

  @override
  String toString() => name;

  static List<RoleItem> get items => [
    RoleItem(name: 'Cashier', value: 'cashier'),
    RoleItem(name: 'Shop Manager', value: 'manager'),
    RoleItem(name: 'Admin', value: 'admin'),
  ];
}
