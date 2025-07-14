import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';

class NewTaxCategoryFormScreen extends StatefulWidget {
  final bool isEdit;
  final TaxCategoryTable? category;
  const NewTaxCategoryFormScreen({
    super.key,
    required this.isEdit,
    this.category,
  });

  @override
  State<NewTaxCategoryFormScreen> createState() =>
      _NewTaxCategoryFormScreenState();
}

class _NewTaxCategoryFormScreenState extends State<NewTaxCategoryFormScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptController = TextEditingController();
  final _taxPercentageController = TextEditingController();
  final _localInsertService = LocalInsertService();

  @override
  void initState() {
    super.initState();
    initialiseForm();
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
          widget.isEdit ? 'Edit Tax Category' : 'New Tax Category',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildInputField(
                controller: _nameController,
                label: 'Tax Category Name',
                hint: 'Enter tax category name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _taxPercentageController,
                label: 'Tax Percentage',
                hint: 'Enter percentage (e.g. 15)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tax percentage';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _descriptController,
                label: 'Description',
                hint: 'Enter description (optional)',
                maxLines: 2,
              ),
              const Spacer(),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled && !_isLoading,
      validator: validator,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _addCategoryToDb,
        child:
            _isLoading
                ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                : Text(
                  widget.isEdit ? 'UPDATE' : 'SUBMIT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
      ),
    );
  }

  Future<void> _addCategoryToDb() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.isEdit) {
        final editCategory = TaxCategoryTable(
          id: widget.category!.id,
          name: _nameController.text,
          taxPercentage: double.parse(_taxPercentageController.text),
          description: _descriptController.text,
          sync: widget.category!.sync,
        );

        final res = await _localInsertService.editTaxCategory(editCategory);
        _showResultSnackbar(
          res > 0,
          'Tax category updated successfully',
          'Failed to update tax category',
        );
      } else {
        final taxCategory = TaxCategoryTable(
          name: _nameController.text,
          description: _descriptController.text,
          taxPercentage: double.parse(_taxPercentageController.text),
        );

        final res = await _localInsertService.insertTaxCategory(taxCategory);
        _showResultSnackbar(
          res > 0,
          'Tax category added successfully',
          'Failed to add tax category',
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultSnackbar(bool success, String successMsg, String errorMsg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMsg : errorMsg),
        backgroundColor: success ? AppColors.primaryGreen : Colors.red,
      ),
    );
  }

  void initialiseForm() {
    if (widget.isEdit && widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptController.text = widget.category!.description ?? '';
      _taxPercentageController.text = widget.category!.taxPercentage.toString();
    }
  }
}
