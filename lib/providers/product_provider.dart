import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/controllers/local_find_service.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';

class ProductsProvider extends ChangeNotifier {
  List<ProductsTable> _products = [];

  List<ProductsTable> _serviceProducts = [];
  List<TaxCategoryTable> _taxCategories = [];
  List<TaxCategoryTable> get taxCategories => _taxCategories;

  bool isLoading = false;

  List<ProductsTable> get products => _products;

  List<ProductsTable> get serviceProducts => _serviceProducts;

  /// Fetch all products from the database
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      _products = await ProductsTable.getAllProducts();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// fetch service products from the database
  Future<void> fetchServiceProducts() async {
    isLoading = true;
    notifyListeners();
    try {
      _serviceProducts = await ProductsTable.getServiceProducts();
    } catch (e) {
      debugPrint("Error fetching service products: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  /// fetch tax categories from the database
  Future<void> fetchTaxCategories() async {
    isLoading = true;
    notifyListeners();
    try {
      _taxCategories = await LocalFindService().getAllTaxCategories();
    } catch (e) {
      debugPrint("Error fetching tax categories: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  /// Add a new product and refresh the list
  Future<void> addProduct(ProductsTable product) async {
    await ProductsTable.insertProduct(product);
    await fetchProducts(); // refresh list
  }

  // update service products
  Future<void> updateServiceProducts(ProductsTable serviceProduct) async {
    await ProductsTable.updateProductsTable(serviceProduct);
    _serviceProducts =
        _serviceProducts.map((p) {
          if (p.id == serviceProduct.id) {
            return serviceProduct;
          }
          return p;
        }).toList();
    notifyListeners();
  }

  /// Update an existing product
  Future<void> updateProduct(ProductsTable updatedProduct) async {
    await ProductsTable.updateProductsTable(updatedProduct);
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  /// Delete a product by ID
  Future<void> deleteProduct(int productId) async {
    await ProductsTable.deleteProduct(productId);
    _products.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  /// Get a product by name
  ProductsTable? getProductByName(String name) {
    try {
      return _products.firstWhere((product) => product.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get a product by ID
  ProductsTable? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// insert a new tax category
  Future<int?> addTaxCategory(TaxCategoryTable taxCategory) async {
    var taxCat = await LocalInsertService().insertTaxCategory(taxCategory);
    if (taxCat != 0) {
      _taxCategories.add(taxCategory);
      notifyListeners();
    }
    return taxCat;
  }

  /// Get a tax category by name
  TaxCategoryTable? getTaxCategoryByName(String name) {
    try {
      return _taxCategories.firstWhere((tax) => tax.name == name);
    } catch (e) {
      return null;
    }
  }

  // delete tax category by id
  Future<int?> deleteTaxCategory(int id) async {
    var res = await TaxCategoryTable.deleteTaxCategory(id);
    if (res != 0) {
      _taxCategories.removeWhere((tax) => tax.id == id);
      notifyListeners();
    }
    return res;
  }
}
