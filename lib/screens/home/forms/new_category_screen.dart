import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';

class NewCategoryScreen extends StatefulWidget {
  final bool isEdit;
  final CategoriesTable? category;
  const NewCategoryScreen({super.key, required this.isEdit, this.category});

  @override
  State<NewCategoryScreen> createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _descriptController = TextEditingController();
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
          widget.isEdit ? 'Edit Category' : 'New Category',
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
                controller: _categoryController,
                label: 'Category Name',
                hint: 'Enter category name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
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
                validator: (value) => null, // Optional field
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
          enabled: !_isLoading,
        ),
      ],
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
        final editCategory = CategoriesTable(
          id: widget.category!.id,
          name: _categoryController.text,
          description: _descriptController.text,
        );

        final res = await _localInsertService.editCategory(editCategory);
        _showResultSnackbar(
          res > 0,
          'Category updated successfully',
          'Failed to update category',
        );
      } else {
        final category = CategoriesTable(
          name: _categoryController.text,
          description: _descriptController.text,
        );

        final res = await _localInsertService.insertCategory(category);
        _showResultSnackbar(
          res > 0,
          'Category added successfully',
          'Failed to add category',
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
      _categoryController.text = widget.category!.name;
      _descriptController.text = widget.category!.description ?? '';
    }
  }
}
