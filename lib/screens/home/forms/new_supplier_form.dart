import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/business_table.dart';
import 'package:pos_desktop_loop/db/tables/supplier_table.dart';
import 'package:pos_desktop_loop/screens/home/people_managemnt_screen.dart';

class NewSupplierForm extends StatefulWidget {
  final bool isEdit;
  final SupplierTable? data;
  const NewSupplierForm({super.key, this.data, required this.isEdit});

  @override
  State<NewSupplierForm> createState() => _NewSupplierFormState();
}

class _NewSupplierFormState extends State<NewSupplierForm> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _contactPersonController = TextEditingController();
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
    _phoneController.dispose();
    _companyController.dispose();
    _contactPersonController.dispose();
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
          widget.isEdit ? 'Edit Supplier' : 'Add New Supplier',
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
                const SizedBox(height: 16),
                Text(
                  _isLoading
                      ? widget.isEdit
                          ? 'Updating supplier...'
                          : 'Adding supplier...'
                      : '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name*',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Please enter company name'
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
                      controller: _contactPersonController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Person',
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
                                    widget.isEdit
                                        ? 'Save Changes'
                                        : 'Add Supplier',
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final business = await Business.getAllBusinesses();
      final supplier = SupplierTable(
        address: _addressController.text,
        phone: _phoneController.text,
        description: _descriptionController.text,
        companyName: _companyController.text,
        contactPerson: _contactPersonController.text,
        businessId: business.isNotEmpty ? business.first.id : null,
        supplierId: widget.isEdit ? widget.data!.supplierId : null,
      );

      if (widget.isEdit) {
        await localInsertService.editSupplier(supplier);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier updated successfully')),
        );
      } else {
        await localInsertService.registerSupplier(supplier);
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier added successfully')),
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PeopleManagementScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _addressController.clear();
    _phoneController.clear();
    _companyController.clear();
    _descriptionController.clear();
    _contactPersonController.clear();
  }

  void _setUpForm() {
    if (widget.isEdit && widget.data != null) {
      final data = widget.data!;
      _phoneController.text = data.phone ?? '';
      _addressController.text = data.address ?? '';
      _descriptionController.text = data.description ?? '';
      _companyController.text = data.companyName ?? '';
      _contactPersonController.text = data.contactPerson ?? '';
    }
  }
}
