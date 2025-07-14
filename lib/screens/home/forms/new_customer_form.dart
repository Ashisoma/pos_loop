import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/business_table.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';

class NewCustomerForm extends StatefulWidget {
  final bool isEdit;
  final CustomerTable? data;
  const NewCustomerForm({super.key, this.data, required this.isEdit});

  @override
  State<NewCustomerForm> createState() => _NewCustomerFormState();
}

class _NewCustomerFormState extends State<NewCustomerForm> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final localInsertService = LocalInsertService();

  @override
  void initState() {
    super.initState();
    _setUpForm();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.isEdit ? 'Edit Customer' : 'Add New Customer',
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name*',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter customer name'
                              : null,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number*',
                    hintText: '0712345678 or 254712345678',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter phone number'
                              : null,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  enabled: !_isLoading,
                ),
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
                      onPressed: _isLoading ? null : _handleSubmit,
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
                                widget.isEdit ? 'Save Changes' : 'Add Customer',
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final businessId = await Business.getAllBusinesses();
      final customer = CustomerTable(
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        companyName: _companyController.text,
        businessId: businessId.isNotEmpty ? businessId.first.id : null,
        description: _descriptionController.text,
        customerId: widget.isEdit ? widget.data!.customerId : null,
      );

      if (widget.isEdit) {
        await localInsertService.editCustomer(customer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer updated successfully')),
        );
      } else {
        await localInsertService.registerCustomer(customer);
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _companyController.clear();
  }

  void _setUpForm() {
    if (widget.isEdit && widget.data != null) {
      final data = widget.data!;
      _nameController.text = data.name ?? '';
      _phoneController.text = data.phone ?? '';
      _addressController.text = data.address ?? '';
      _companyController.text = data.companyName ?? '';
    }
  }
}
