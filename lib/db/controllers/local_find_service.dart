import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/tables/business_table.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/db/tables/stock/inventory_table.dart';
import 'package:pos_desktop_loop/db/tables/supplier_table.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';

class LocalFindService {
  var authService = AuthService();

  // get all products
  Future<List<ProductsTable>> getAllProducts() async {
    return await ProductsTable.getAllProducts();
  }

  // get all products by category id
  Future<List<ProductsTable>> getProductsByCategoryId(int categoryId) async {
    return await ProductsTable.getAllProductsByCategoryId(categoryId);
  }

  Future<List<ProductsTable>> getProductsByShopId(int shopId) async {
    return await InventoryTable.getProductsByShopId(shopId);
  }

  // get all categories
  Future<List<CategoriesTable>> getAllCategories() async {
    return await CategoriesTable.getAllCategories();
  }

  // get all tax categories
  Future<List<TaxCategoryTable>> getAllTaxCategories() async {
    return await TaxCategoryTable.getAllTaxCategories();
  }

  // get all shops
  Future<List<ShopTable>> getAllShops() async {
    return await ShopTable.getAllShops();
  }

  // get all suppliers or customers by role
  Future<List<SupplierTable>> getAllSuppliers() async {
    return await SupplierTable.getAllSuppliers();
  }

  // get all custommers
  Future<List<CustomerTable>> getAllCustomers() async {
    return await CustomerTable.getAllcustomers();
  }

  // get all users
  Future<List<UserTable>> getAllUsers() async {
    return await UserTable.getAllUsers();
  }

  //get all product for the cart
  Future<List<ProductsTable>> getAllProductsForCart() async {
    // get shop where manager id is current user id
    var currentUser = await authService.getCurrentUser();
    var shops = await ShopTable.getShopByManagerId(currentUser!.id!);
    if (shops == null || shops.shopId == null) {
      return [];
    }
    // get al
    return await InventoryTable.getProductByShopId(shops.shopId!);
  }

  // get all products for the cart when it is admin or owner
  Future<List<ProductsTable>> getAllProductsForCartForAdmin() async {
    // get shop where manager id is current user id
    return await InventoryTable.getProductByShopIdForAdmin();
  }

  // get all products by shop id
  Future<List<ProductsTable>> getAllProductsByShopId(int shopId) async {
    return await InventoryTable.getProductByShopId(shopId);
  }

  // get inventory by shopId
  Future<List<InventoryTable>> getInventoryByShopId(int shopId) async {
    return await InventoryTable.getInventoryByShopId(shopId);
  }

  Future<List<Business>> getAllBusinesses() async {
    return await Business.getAllBusinesses();
  }


  Future<InventoryTable?> getInventoryItem(int productId, int shopId) async {
    return await InventoryTable.getInventoryItem(productId, shopId);
    
  }

  /// Get all inventory records for a specific product
  Future<List<InventoryTable>> getInventoryByProductId(int productId) async {
    
    return await InventoryTable.getInventoryByProductId(productId);
  }

}
