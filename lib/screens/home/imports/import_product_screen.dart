import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImportProductsPage extends StatefulWidget {
  const ImportProductsPage({super.key});

  @override
  _ImportProductsPageState createState() => _ImportProductsPageState();
}

class _ImportProductsPageState extends State<ImportProductsPage> {
  bool _isLoading = false;
  int _successCount = 0;
  int _errorCount = 0;
  int _duplicateCount = 0;
  List<String> _errors = [];
  List<String> _duplicates = [];
  int? _shopId;

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shopId = prefs.getInt('_shopIdKey');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Products')),
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
                      _buildProductImportGuide(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Excel File'),
                onPressed: _isLoading ? null : _importProducts,
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

  Widget _buildProductImportGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prepare your Excel file with these columns in order:'),
        const SizedBox(height: 8),
        const Text('1. Product Name (required)'),
        const Text('2. Category Name (required)'),
        const Text('3. Unit Price (required)'),
        const Text('4. Retail Price (optional)'),
        const Text('5. Wholesale Price (optional)'),
        const Text('6. Barcode (optional)'),
        const Text('7. Quantity (optional)'),
        const Text('8. Is Service (true/false, defaults to false)'),
        const Text('9. Tax Category (optional)'),
        const Text('10. Description (optional)'),
        const SizedBox(height: 8),
        const Text('Notes:'),
        const Text('- Shop ID will be automatically taken from your current shop'),
        const Text('- Category will be matched by name (case insensitive)'),
        const Text('- If category doesn\'t exist, it will be created'),
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
                '✅ $_successCount products imported successfully',
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

  Future<void> _importProducts() async {
    if (_shopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop ID not found. Please select a shop first')),
      );
      return;
    }

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
      final provider = Provider.of<ProductsProvider>(context, listen: false);
      int rowNumber = 0;

      for (var row in sheet.rows) {
        rowNumber++;
        if (rowNumber == 1) continue; // Skip header row

        try {
          String productName = row[0]?.value?.toString() ?? '';
          String categoryName = row[1]?.value?.toString() ?? '';
          String unitPriceStr = row[2]?.value?.toString() ?? '0';
          String retailPriceStr = row[3]?.value?.toString() ?? '';
          String wholesalePriceStr = row[4]?.value?.toString() ?? '';
          String barcode = row[5]?.value?.toString() ?? '';
          String quantityStr = row[6]?.value?.toString() ?? '';
          String isServiceStr = row[7]?.value?.toString() ?? 'false';
          String taxCategory = row[8]?.value?.toString() ?? '';
          String description = row[9]?.value?.toString() ?? '';

          if (productName.isEmpty || categoryName.isEmpty || unitPriceStr.isEmpty) {
            throw Exception('Missing required fields (Name, Category or Unit Price)');
          }

          // Parse numeric values
          double unitPrice = double.tryParse(unitPriceStr) ?? 0;
          double retailPrice = double.tryParse(retailPriceStr) ?? unitPrice;
          double wholesalePrice = double.tryParse(wholesalePriceStr) ?? unitPrice;
          int quantity = int.tryParse(quantityStr) ?? 0;
          bool isService = isServiceStr.toLowerCase() == 'true';

          // Get or create category
          int categoryId = await _getOrCreateCategory(categoryName, description);

          // Check for duplicate product name in same category
          bool exists = await _productExists(productName, categoryId);
          if (exists) {
            _duplicateCount++;
            _duplicates.add('$productName in $categoryName');
            continue;
          }

          // Create product
          ProductsTable product = ProductsTable(
            name: productName,
            categoryId: categoryId,
            unitPrice: unitPrice,
            retailPrice: retailPrice,
            wholesalePrice: wholesalePrice,
            barcode: barcode.isNotEmpty ? barcode : null,
            quantity: quantity,
            isService: isService,
            taxCategory: taxCategory.isNotEmpty ? int.parse(taxCategory) : null,
            shopId: _shopId!,
          );

          // Insert product
          final result = await provider.addProduct(product);
          if (result != null && result > 0) {
            _successCount++;
          } else {
            throw Exception('Failed to insert product');
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
          content: Text('Error importing products: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<int> _getOrCreateCategory(String name, String description) async {
    final existing = await CategoriesTable.getCategoryByName(name);
    if (existing != null) return existing.id!;

    // Create new category if not exists
    final newCategory = CategoriesTable(
      name: name,
      description: description.isNotEmpty ? description : 'Imported category',
    );
    return await CategoriesTable.insertCategory(newCategory);
  }

  Future<bool> _productExists(String name, int categoryId) async {
    final insertService = LocalInsertService();
    return await insertService.productExists(name, categoryId, _shopId!);
  }

  
}
