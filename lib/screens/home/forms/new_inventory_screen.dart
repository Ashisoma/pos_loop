import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/db/tables/stock/inventory_table.dart';
import 'package:pos_desktop_loop/models/inventory_model.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/providers/product_provider.dart';
import 'package:provider/provider.dart';

class NewInventoryScreen extends StatefulWidget {
  final bool isEdit;
  final InventoryItemModel? data;
  const NewInventoryScreen({super.key, required this.isEdit, this.data});

  @override
  State<NewInventoryScreen> createState() => _NewInventoryScreenState();
}

class _NewInventoryScreenState extends State<NewInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  final _insertService = LocalInsertService();
  ProductsTable? _selectedProduct;
  ShopTable? _selectedShop;
  List<ProductsTable> products = [];
  List<ShopTable> shops = [];

  @override
  void initState() {
    super.initState();
    _setupForm();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _setupForm() async {
    if (widget.isEdit && widget.data != null) {
      final productsProvider = Provider.of<ProductsProvider>(
        context,
        listen: false,
      );
      final shopsProvider = Provider.of<InventoryByShopProvider>(
        context,
        listen: false,
      );

      _quantityController.text = widget.data!.quantity.toString();
      // _priceController.text = widget.data!.price?.toString() ?? '';

      final product = productsProvider.getProductByName(
        widget.data!.productName,
      );
      final shop = await shopsProvider.getShopByName(widget.data!.shopName);

      setState(() {
        _selectedProduct = product;
        _selectedShop = shop;
      });
    }

    final productsDB = await ProductsTable.getAllProducts();
    final shopDB = await ShopTable.getAllShops();

    setState(() {
      products = productsDB;
      shops = shopDB;
    });
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEdit ? 'Edit Inventory' : 'Add Inventory Item',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Shop Dropdown
              _buildDropdown<ShopTable>(
                label: 'Shop',
                value: _selectedShop,
                items: shops,
                displayText: (shop) => shop.name,
                onChanged: (value) => setState(() => _selectedShop = value),
                validator:
                    (value) => value == null ? 'Please select a shop' : null,
              ),
              const SizedBox(height: 16),

              // Product Dropdown
              _buildDropdown<ProductsTable>(
                label: 'Product',
                value: _selectedProduct,
                items: products,
                displayText: (product) => product.name,
                onChanged: (value) => setState(() => _selectedProduct = value),
                validator:
                    (value) => value == null ? 'Please select a product' : null,
              ),
              const SizedBox(height: 16),

              // Quantity Field
              _buildInputField(
                controller: _quantityController,
                label: 'Quantity',
                hint: 'Enter quantity',
                keyboardType: TextInputType.number,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Price Field
              // _buildInputField(
              //   controller: _priceController,
              //   label: 'Price',
              //   hint: 'Enter price',
              //   keyboardType: TextInputType.number,
              //   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              // ),
              const Spacer(),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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
              ),
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
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
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
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayText(item),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<InventoryByShopProvider>();
      final item = InventoryTable(
        id: widget.isEdit ? widget.data!.inventoryId : null,
        productId: _selectedProduct!.id!,
        shopId: _selectedShop!.shopId!,
        quantity: int.parse(_quantityController.text),

        sync: 0,
      );

      if (widget.isEdit) {
        await provider.updateInventoryItem(item);
      } else {
        await _insertService.insertInventory(item);
        provider.fetchAllInventory();
      }

      if (mounted) Navigator.pop(context);
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
}
