
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';

class ImportCategoriesPage extends StatefulWidget {
  const ImportCategoriesPage({super.key});

  @override
  _ImportCategoriesPageState createState() => _ImportCategoriesPageState();
}

class _ImportCategoriesPageState extends State<ImportCategoriesPage> {
  bool _isLoading = false;
  int _successCount = 0;
  int _errorCount = 0;
  int _duplicateCount = 0;
  List<String> _errors = [];
  List<String> _duplicates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Categories')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Import Guide',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryImportGuide(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Excel File'),
                onPressed: _isLoading ? null : _importCategories,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (_isLoading) const LinearProgressIndicator(),
              if (_successCount > 0 || _errorCount > 0 || _duplicateCount > 0)
                _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImportGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prepare your Excel file with these columns in order:'),
        const SizedBox(height: 8),
        const Text('1. Category Name (required)'),
        const Text('2. Description (optional)'),
        const SizedBox(height: 8),
        const Text('Notes:'),
        const Text('- Duplicate category names will be skipped'),
      ],
    );
  }

  Future<void> _importCategories() async {
    setState(() {
      _isLoading = true;
      _successCount = 0;
      _errorCount = 0;
      _duplicateCount = 0;
      _errors = [];
      _duplicates = [];
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null) {
        setState(() => _isLoading = false);
        return;
      }

      PlatformFile file = result.files.first;
      if (file.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected or empty file')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final excelFile = excel.Excel.decodeBytes(file.bytes!);
      final sheetNames = excelFile.tables.keys;

      if (sheetNames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No sheets found in Excel file')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final sheet = excelFile.tables[sheetNames.first]!;
      int rowNumber = 0;

      for (var row in sheet.rows) {
        rowNumber++;
        if (rowNumber == 1) continue; // Skip header row

        try {
          String categoryName = row[0]?.value?.toString() ?? '';
          String description = row[1]?.value?.toString() ?? '';

          if (categoryName.isEmpty) {
            throw Exception('Missing required field (Category Name)');
          }

          // Check for duplicate category
          bool exists = await _categoryExists(categoryName);
          if (exists) {
            _duplicateCount++;
            _duplicates.add(categoryName);
            continue;
          }

          // Create category
          CategoriesTable category = CategoriesTable(
            name: categoryName,
            description: description.isNotEmpty ? description : 'Imported category',
          );

          // Insert category
          final result = await CategoriesTable.insertCategory(category);
          if (result > 0) {
            _successCount++;
          } else {
            throw Exception('Failed to insert category');
          }
        } catch (e) {
          _errorCount++;
          _errors.add('Row $rowNumber: $e');
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing categories: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _categoryExists(String name) async {
    final existing = await CategoriesTable.getCategoryByName(name);
    return existing != null;
  }

  Widget _buildResultsSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_successCount > 0)
            Text(
              '✅ $_successCount categories imported successfully',
              style: const TextStyle(color: Colors.green),
            ),
          if (_duplicateCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '⚠️ $_duplicateCount duplicates skipped',
              style: TextStyle(color: Colors.orange.shade700),
            ),
            if (_duplicates.isNotEmpty) ...[
              const SizedBox(height: 4),
              ..._duplicates
                  .take(3)
                  .map(
                    (d) => Text(
                      '• $d',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
              if (_duplicates.length > 3)
                Text(
                  '... and ${_duplicates.length - 3} more',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
            ],
          ],
          if (_errorCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '❌ $_errorCount rows had errors',
              style: const TextStyle(color: Colors.red),
            ),
            if (_errors.isNotEmpty) ...[
              const SizedBox(height: 4),
              ..._errors
                  .take(3)
                  .map(
                    (e) => Text(
                      '• $e',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              if (_errors.length > 3)
                Text(
                  '... and ${_errors.length - 3} more',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ],
        ],
      ),
    ),
  );
}
}