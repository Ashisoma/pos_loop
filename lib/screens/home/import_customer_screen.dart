import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/business_table.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';

class ImportCustomersPage extends StatefulWidget {
  const ImportCustomersPage({super.key});

  @override
  _ImportCustomersPageState createState() => _ImportCustomersPageState();
}

class _ImportCustomersPageState extends State<ImportCustomersPage> {
  bool _isLoading = false;
  int _successCount = 0;
  int _errorCount = 0;
  int _duplicateCount = 0;
  List<String> _errors = [];
  List<String> _duplicates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Customers')),
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
                onPressed: _isLoading ? null : _importCustomers,
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
      children: [
        const Text('Prepare your Excel file with these columns in order:'),
        const SizedBox(height: 8),
        const Text('1. Customer Name (required)'),
        const Text('2. Phone Number (required, must be unique)'),
        const Text('3. Company (optional)'),
        const Text('4. Address (optional)'),
        const Text('5. Notes (optional)'),
        const SizedBox(height: 8),
        const Text(
          'Duplicate phone numbers will be automatically skipped during import',
        ),
        const SizedBox(height: 8),
        const Text('Phone Number Formats Accepted:'),
        const Text('- 0712345678 (will become +254712345678)'),
        const Text('- 712345678 (will become +254712345678)'),
        const Text('- 254712345678 (will become +254712345678)'),
        const Text('- +254712345678 (will remain unchanged)'),
      ],
    );
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
                '✅ $_successCount customers imported successfully',
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

  Future<void> _importCustomers() async {
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

      List<CustomerTable> customersToImport = [];
      List<String> phoneNumbersToCheck = [];
      int rowNumber = 0;

      for (var row in sheet.rows) {
        rowNumber++;
        if (rowNumber == 1) continue; // Skip header row

        try {
          String customerName = row[0]?.value?.toString() ?? '';
          String rawPhone = row[1]?.value?.toString() ?? '';
          String company = row[2]?.value?.toString() ?? '';
          String address = row[3]?.value?.toString() ?? '';
          String notes = row[4]?.value?.toString() ?? '';

          if (customerName.isEmpty || rawPhone.isEmpty) {
            throw Exception('Missing required fields (Name and Phone)');
          }

          String phoneNumber = _formatPhoneNumber(rawPhone);
          // if (!RegExp(r'^\+254[17]\d{8}$').hasMatch(phoneNumber)) {
          //   throw Exception('Invalid phone number format');
          // }

          phoneNumbersToCheck.add(phoneNumber);
          var business = await Business.getAllBusinesses();
          customersToImport.add(
            CustomerTable(
              name: customerName,
              phone: phoneNumber,
              companyName: company,
              address: address,
              description: notes,
              businessId: business.first.id,
            ),
          );
        } catch (e) {
          _errorCount++;
          _errors.add('Row $rowNumber: $e');
        }
      }

      // Check for duplicates in SQLite
      if (phoneNumbersToCheck.isNotEmpty) {
        final existingNumbers = await _checkExistingPhoneNumbers(
          phoneNumbersToCheck,
        );

        customersToImport =
            customersToImport.where((customer) {
              if (existingNumbers.contains(customer.phone)) {
                _duplicateCount++;
                _duplicates.add('${customer.name} (${customer.phone})');
                return false;
              }
              return true;
            }).toList();
      }

      // Insert valid customers
      if (customersToImport.isNotEmpty) {
        final insertService = LocalInsertService();
        for (var customer in customersToImport) {
          final result = await insertService.registerCustomer(customer);
          if (result != null && result > 0) {
            _successCount++;
          } else {
            _errorCount++;
            _errors.add(
              'Failed to insert ${customer.name} (${customer.phone})',
            );
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing customers: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;

    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.startsWith('254')) {
      return '+$digits';
    }

    if (digits.startsWith('7') && digits.length == 9) {
      return '+254$digits';
    }

    if (digits.startsWith('07') && digits.length == 10) {
      return '+254${digits.substring(1)}';
    }

    return phone;
  }

  Future<Set<String>> _checkExistingPhoneNumbers(
    List<String> phoneNumbers,
  ) async {
    final insertService = LocalInsertService();
    Set<String> existingNumbers = {};

    for (var phone in phoneNumbers) {
      bool exists = await insertService.customerExists(phone);
      if (exists) {
        existingNumbers.add(phone);
      }
    }

    return existingNumbers;
  }
}
