import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_find_service.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';
import 'package:pos_desktop_loop/providers/inventory_provider.dart';
import 'package:pos_desktop_loop/providers/product_provider.dart';
import 'package:provider/provider.dart';

class NewProductScreen extends StatefulWidget {
  final bool isEdit;
  final int shopId;
  final bool isService;
  final ProductsTable? product;
  const NewProductScreen({
    super.key,
    required this.isEdit,
    this.product,
    required this.shopId,
    required this.isService,
  });

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  bool _isLoading = false;
  bool _dataLoaded = false;
  bool _isSaving = false;
  bool _isOnOffer = false;
  final _formKey = GlobalKey<FormState>();
  final _offerPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _restockController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _retailPriceController = TextEditingController();
  final _nameController = TextEditingController();

  var localInsertService = LocalInsertService();
  var localFindService = LocalFindService();
  List<TaxCategoryTable> taxCategories = [];
  List<CategoriesTable> categories = [];
  CategoriesTable? _selectedCategory;
  TaxCategoryTable? _selectedTaxCategory;

  bool _isService = false;

  @override
  void initState() {
    super.initState();
    _isService = widget.isService == 1;
    initialiseData().then((_) {
      if (widget.isEdit && widget.product != null) {
        initialiseForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isService == 1
              ? (widget.isEdit ? 'Edit Service' : 'New Service')
              : (widget.isEdit ? 'Edit Product' : 'New Product'),
        ),
      ),
      body:
          _isLoading && !_dataLoaded
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        readOnly: _isSaving,
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _buildTaxCategoryDropdown(),
                      if (!_isService) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _restockController,
                          decoration: const InputDecoration(
                            labelText: 'Restock Level',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity*',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !widget.isEdit,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _wholesalePriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Wholesale Price',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _buyingPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Buying Price*',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter buying price';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _retailPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Retail Price*',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (!_isOnOffer) {
                                  _offerPriceController.text = value;
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter retail price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _offerPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Offer Price',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (_isOnOffer &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter offer price';
                                }
                                if (value != null &&
                                    double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _isOnOffer,
                            onChanged: (value) {
                              setState(() {
                                _isOnOffer = value ?? false;
                              });
                            },
                          ),
                          const Text('Is on Offer'),
                          if (!widget.isEdit) ...[
                            const SizedBox(width: 20),
                            Checkbox(
                              value: _isService,
                              onChanged: (value) {
                                setState(() {
                                  _isService = value ?? false;
                                });
                              },
                            ),
                            const Text('Is Service'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed:
                                _isSaving
                                    ? null
                                    : () => _addProductToDb(context),
                            child:
                                _isSaving
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      widget.isEdit ? 'UPDATE' : 'SUBMIT',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<CategoriesTable>(
            decoration: const InputDecoration(
              labelText: 'Category*',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            hint: const Text('Select Category'),
            items:
                categories.map((category) {
                  return DropdownMenuItem<CategoriesTable>(
                    value: category,
                    child: Text(category.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
            isExpanded: true,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add, color: AppColors.primaryGreen),
          onPressed: () => _showAddCategoryDialog(context),
        ),
      ],
    );
  }

  Widget _buildTaxCategoryDropdown() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<TaxCategoryTable>(
            decoration: const InputDecoration(
              labelText: 'Tax Category*',
              border: OutlineInputBorder(),
            ),
            value: _selectedTaxCategory,
            hint: const Text('Select Tax Category'),
            items:
                taxCategories.map((taxCategory) {
                  return DropdownMenuItem<TaxCategoryTable>(
                    value: taxCategory,
                    child: Text(
                      '${taxCategory.name} (${taxCategory.taxPercentage}%)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTaxCategory = value;
              });
            },
            validator:
                widget.isService == 1
                    ? null
                    : (value) {
                      if (value == null) {
                        return 'Please select a tax category';
                      }
                      return null;
                    },
            isExpanded: true,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add, color: AppColors.primaryGreen),
          onPressed: () => _showAddTaxCategoryDialog(context),
        ),
      ],
    );
  }

  Future<void> _addProductToDb(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    if (widget.isEdit) {
      await _updateProductInDb(context);
    } else {
      await _insertProductToDb(context);
    }
  }

  void initialiseForm() {
    if (widget.isEdit && widget.product != null) {
      final product = widget.product!; // Non-null assertion since we checked

      _nameController.text = product.name;
      _restockController.text = product.restockLevel?.toString() ?? '0';
      _offerPriceController.text = product.offerPrice?.toString() ?? '0';
      _retailPriceController.text = product.retailPrice?.toString() ?? '0';
      _buyingPriceController.text = product.buyingPrice?.toString() ?? '0';
      _isOnOffer =
          (product.offerPrice ?? 0) > 0; // Null check before comparison

      if (!(widget.isService == 1)) {
        _quantityController.text = product.quantity?.toString() ?? '0';
        _wholesalePriceController.text =
            product.wholesalePrice?.toString() ?? '0';
        _unitPriceController.text = product.unitPrice?.toString() ?? '0';
      }

      // Set selected category
      if (categories.isNotEmpty) {
        _selectedCategory = categories.firstWhere(
          (c) => c.id == product.categoryId,
          orElse: () => categories.first,
        );
      }

      // Set selected tax category if it exists
      if (taxCategories.isNotEmpty && product.taxCategory != null) {
        _selectedTaxCategory = taxCategories.firstWhere(
          (t) => t.id == product.taxCategory,
          orElse:
              () => taxCategories.firstWhere(
                (t) => t.id == 1,
                orElse: () => taxCategories.first,
              ),
        );
      }
    }
  }

  Future<void> _updateProductInDb(BuildContext context) async {
    try {
      var updatedProduct = ProductsTable(
        id: widget.product!.id,
        name: _nameController.text,
        restockLevel: int.parse(_restockController.text),
        offerPrice: _isOnOffer ? double.parse(_offerPriceController.text) : 0,
        retailPrice: double.parse(_retailPriceController.text),
        taxCategory: _selectedTaxCategory?.id ?? 0,
        categoryId: _selectedCategory?.id ?? 0,
        isService: _isService,
        quantity: _isService ? 0 : int.parse(_quantityController.text),
        wholesalePrice:
            _isService ? 0.0 : double.parse(_wholesalePriceController.text),
        unitPrice: _isService ? 0.0 : double.parse(_unitPriceController.text),
        shopId: widget.shopId,
        buyingPrice: double.parse(_buyingPriceController.text),
        barcode: widget.product!.barcode,
        isOffer: _isOnOffer,
      );

      await localInsertService.editProduct(updatedProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_isService ? 'Service' : 'Product'} updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _insertProductToDb(BuildContext context) async {
    try {
      var newProduct = ProductsTable(
        name: _nameController.text,
        offerPrice: _isOnOffer ? double.parse(_offerPriceController.text) : 0,
        retailPrice: double.parse(_retailPriceController.text),
        taxCategory: _selectedTaxCategory?.id ?? 0,
        categoryId: _selectedCategory?.id ?? 0,
        isService: _isService,
        quantity: _isService ? 0 : int.parse(_quantityController.text),
        wholesalePrice:
            _isService ? 0.0 : double.parse(_wholesalePriceController.text),
        unitPrice: _isService ? 0.0 : double.parse(_unitPriceController.text),
        shopId: widget.shopId,
        buyingPrice: double.parse(_buyingPriceController.text),
        restockLevel: int.tryParse(_restockController.text) ?? 0,
        isOffer: _isOnOffer,
      );

      await localInsertService.insertProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_isService ? 'Service' : 'Product'} added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> initialiseData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final taxlist = await localFindService.getAllTaxCategories();
      final list = await localFindService.getAllCategories();

      if (mounted) {
        setState(() {
          taxCategories = taxlist;
          categories = list;
          _dataLoaded = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
          _dataLoaded = true;
        });
      }
    }
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Category'),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    ).then((result) async {
      if (result == true) {
        final provider = Provider.of<InventoryByShopProvider>(
          context,
          listen: false,
        );
        final newCategory = await provider.addCategory(
          CategoriesTable(
            name: nameController.text,
            description: descController.text,
          ),
        );

        if (newCategory == 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category already exists'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        final category = await provider.getCategoryByName(nameController.text);

        if (category != null && mounted) {
          setState(() {
            _selectedCategory = category;
            categories.add(category);
          });
        }
      }
    });
  }

  Future<void> _showAddTaxCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Tax Category'),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tax Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tax Rate (%)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a tax rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    ).then((result) async {
      if (result == true) {
        final provider = Provider.of<ProductsProvider>(context, listen: false);
        final newCategory = await provider.addTaxCategory(
          TaxCategoryTable(
            name: nameController.text,
            taxPercentage: double.parse(rateController.text),
            description: descController.text,
          ),
        );

        if (newCategory == 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tax category already exists'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        final category = provider.getTaxCategoryByName(nameController.text);

        if (newCategory != 0 && category != null && mounted) {
          setState(() {
            _selectedTaxCategory = category;
            taxCategories.add(category);
          });
        }
      }
    });
  }
}
