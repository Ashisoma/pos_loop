import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';

class ImportTaxCategoriesPage extends StatefulWidget {
  const ImportTaxCategoriesPage({super.key});

  @override
  _ImportTaxCategoriesPageState createState() =>
      _ImportTaxCategoriesPageState();
}

class _ImportTaxCategoriesPageState extends State<ImportTaxCategoriesPage> {
  bool _isLoading = false;
  int _successCount = 0;
  int _errorCount = 0;
  int _duplicateCount = 0;
  List<String> _errors = [];
  List<String> _duplicates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Tax Categories')),
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
                      _buildImportGuide(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Excel File'),
                onPressed: _isLoading ? null : _importTaxCategories,
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

  Widget _buildImportGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Prepare your Excel file with these columns in order:'),
        SizedBox(height: 8),
        Text('1. Tax Category Name (required)'),
        Text('2. Tax Percentage (required, numeric)'),
        Text('3. Description (optional)'),
        SizedBox(height: 8),
        Text('Notes:'),
        Text('- Duplicate tax category names will be skipped'),
        Text('- Percentage should be numeric (e.g., 16.0 for 16%)'),
      ],
    );
  }

  Future<void> _importTaxCategories() async {
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
      final sheet = excelFile.tables[excelFile.tables.keys.first]!;

      int rowNumber = 0;

      for (var row in sheet.rows) {
        rowNumber++;
        if (rowNumber == 1) continue; // skip header

        try {
          String name = row[0]?.value?.toString().trim() ?? '';
          String percentageStr = row[1]?.value?.toString().trim() ?? '';
          String description =
              row.length > 2 ? row[2]?.value?.toString().trim() ?? '' : '';

          if (name.isEmpty || percentageStr.isEmpty) {
            throw Exception('Missing required fields (Name or Tax Percentage)');
          }

          double taxPercentage = double.tryParse(percentageStr) ?? double.nan;
          if (taxPercentage.isNaN) {
            throw Exception('Invalid tax percentage format');
          }

          // Check for duplicate
          bool exists = await _taxCategoryExists(name);
          if (exists) {
            _duplicateCount++;
            _duplicates.add(name);
            continue;
          }

          // Create tax category
          final taxCategory = TaxCategoryTable(
            name: name,
            taxPercentage: taxPercentage,
            description:
                description.isNotEmpty ? description : 'Imported tax category',
          );

          final result = await TaxCategoryTable.insertTaxCategory(taxCategory);
          if (result > 0) {
            _successCount++;
          } else {
            throw Exception('Insert failed');
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
          content: Text('Error importing tax categories: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _taxCategoryExists(String name) async {
    final existing = await TaxCategoryTable.getCategoryByName(name);
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
                '✅ $_successCount tax categories imported successfully',
                style: const TextStyle(color: Colors.green),
              ),
            if (_duplicateCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ $_duplicateCount duplicates skipped',
                style: TextStyle(color: Colors.orange.shade700),
              ),
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
            if (_errorCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '❌ $_errorCount rows had errors',
                style: const TextStyle(color: Colors.red),
              ),
              ..._errors
                  .take(3)
                  .map(
                    (e) =>
                        Text('• $e', style: const TextStyle(color: Colors.red)),
                  ),
              if (_errors.length > 3)
                Text(
                  '... and ${_errors.length - 3} more',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
