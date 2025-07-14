import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/business_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/screens/home/home_screen.dart';

class NewShopScreen extends StatefulWidget {
  final bool isEdit;
  final ShopTable? data;
  const NewShopScreen({super.key, required this.isEdit, this.data});

  @override
  State<NewShopScreen> createState() => _NewShopScreenState();
}

class _NewShopScreenState extends State<NewShopScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _branchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _sloganController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _pinNumberController = TextEditingController();
  final _localInsertService = LocalInsertService();
  int? _selectedManagerId;

  @override
  void initState() {
    super.initState();
    _setUpForm();
  }

  @override
  void dispose() {
    _branchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _sloganController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _vatNumberController.dispose();
    _pinNumberController.dispose();
    _selectedManagerId = null;
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Edit Shop' : 'Add New Shop',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shop Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the shop name';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Branch Field
              TextFormField(
                controller: _branchController,
                decoration: const InputDecoration(
                  labelText: 'Branch*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the branch';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Slogan Field
              TextFormField(
                controller: _sloganController,
                decoration: const InputDecoration(
                  labelText: 'Slogan',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Website Field
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // VAT Number Field
              TextFormField(
                controller: _vatNumberController,
                decoration: const InputDecoration(
                  labelText: 'VAT Number',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // PIN Number Field
              TextFormField(
                controller: _pinNumberController,
                decoration: const InputDecoration(
                  labelText: 'PIN Number',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addShopToDb,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
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
                                widget.isEdit ? 'Save Changes' : 'Add Shop',
                              ),
                    ),
                  ),
                ],
              ),

              if (_isLoading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  widget.isEdit ? 'Updating shop...' : 'Creating shop...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addShopToDb() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var business = await Business.getAllBusinesses();
      var user = await AuthService().getCurrentUser();
      final shop = ShopTable(
        name: _nameController.text,
        branch: _branchController.text,
        phone: _phoneController.text,
        managerId: _selectedManagerId,
        createdAt: DateTime.now(),
        createdBy: user!.id!,
        businessId: business.first.id,
        isActive: true,
        website: _websiteController.text,
        email: _emailController.text,
        vatNumber: _vatNumberController.text,
        pinNumber: _pinNumberController.text,
        slogan: _sloganController.text,
      );

      final res =
          widget.isEdit
              ? await _localInsertService.editShop(shop)
              : await _localInsertService.insertNewShop(shop);

      if (res > 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Shop updated successfully'
                  : 'Shop added successfully',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setUpForm() {
    if (widget.isEdit && widget.data != null) {
      _nameController.text = widget.data!.name;
      _branchController.text = widget.data!.branch ?? '';
      _phoneController.text = widget.data!.phone ?? '';
      _selectedManagerId = widget.data!.managerId;
      _sloganController.text = widget.data!.slogan ?? '';
      _websiteController.text = widget.data!.website ?? '';
      _emailController.text = widget.data!.email ?? '';
      _vatNumberController.text = widget.data!.vatNumber ?? '';
      _pinNumberController.text = widget.data!.pinNumber ?? '';
    }
  }
}
