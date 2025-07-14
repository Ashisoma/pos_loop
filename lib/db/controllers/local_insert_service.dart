import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/db/tables/costomer_table.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/db/tables/stock/inventory_table.dart';
import 'package:pos_desktop_loop/db/tables/supplier_table.dart';
import 'package:pos_desktop_loop/db/tables/tax_category_table.dart';
import 'package:pos_desktop_loop/db/tables/user_table.dart';

class LocalInsertService {
  // This class is responsible for inserting data into the local database.

  // insert a new customer to database
  Future<int?> registerSupplier(SupplierTable user) async {
    bool exists = await supplierExists(user.phone!);
    if (exists) return 0; // user already exists

    return await insertSupplier(user);
  }

  Future<int?> registerCustomer(CustomerTable user) async {
    bool exists = await customerExists(user.phone!);
    if (exists) return 0; // user already exists

    return await insertCustomer(user);
  }

  // edit an existing customer or supplier
  Future<int> editSupplier(SupplierTable user) async {
    return await SupplierTable.updateSupplier(user);
  }

  Future<int> editCustomer(CustomerTable user) async {
    return await CustomerTable.updatecustomer(user);
  }

  // delete a customer or supplier
  Future<int> deleteCustomerOrSupplier(int supplierId) async {
    return await SupplierTable.deleteSupplier(supplierId);
  }

  Future<int> deleteCustomer(int supplierId) async {
    return await CustomerTable.deletecustomer(supplierId);
  }

  // add a new product to the database and check if it already exists
  Future<int?> registerProduct(ProductsTable product) async {
    bool exists = await ProductsTable.productExists(product.name);
    if (exists) return 0; // product already exists

    return await insertProduct(product);
  }

  // edit an existing product
  Future<int?> editProduct(ProductsTable product) async {
    return await ProductsTable.updateProductsTable(product);
  }

  // delete a product
  Future<int> deleteProduct(int productId) async {
    return await ProductsTable.deleteProduct(productId);
  }

  // delete a product
  Future<int> deleteUser(int userId) async {
    // check if user has token and log them out if deleted
    var user = await UserTable.getUserById(userId);
    var authUser = await AuthService().getCurrentUser();
    if (user == authUser) {
      AuthService.logout();
      return UserTable.deleteUser(userId);
    } else {
      return await UserTable.deleteUser(userId);
    }
  }

  // add a category to the database
  Future<int> addCategory(CategoriesTable category) async {
    bool exists = await CategoriesTable.categoryExists(category.name);
    if (exists) return 0; // product already exists

    return await insertCategory(category);
  }

  Future<int> insertInventory(InventoryTable inventory) async {
    return await InventoryTable.insertInventory(inventory);
  }

  // edit a category
  Future<int> editCategory(CategoriesTable category) async {
    return await CategoriesTable.updateCategory(category);
  }

  // delete a category
  Future<int> deleteCategory(int categoryId) async {
    return await CategoriesTable.deleteCategory(categoryId);
  }

  // insert a shop
  Future<int> insertShop(ShopTable shop) async {
    bool exists = await shopExists(shop.name);
    if (exists) return 0; // shop already exists

    return await insertNewShop(shop);
  }

  // insert tax category
  Future<int> insertTaxCategory(TaxCategoryTable taxCategory) async {
    return await TaxCategoryTable.insertTaxCategory(taxCategory);
  }

  // edit tax category
  Future<int> editTaxCategory(TaxCategoryTable taxCategory) async {
    print(taxCategory);
    return await TaxCategoryTable.updateTaxCategory(taxCategory);
  }

  // edit an existing shop
  Future<int> editShop(ShopTable shop) async {
    return await ShopTable.updateShop(shop);
  }

  // delete a shop
  Future<int> deleteShop(int shopId) async {
    return await ShopTable.deleteShop(shopId);
  }

  // insert a new shop
  Future<int> insertNewShop(ShopTable shop) async {
    return await ShopTable.insertShop(shop);
  }

  Future<bool> shopExists(String phone) async {
    return await ShopTable.shopExists(phone);
  }

  Future<int> insertSupplier(SupplierTable user) =>
      SupplierTable.insertSupplier(user);

  Future<int> insertCustomer(CustomerTable user) =>
      CustomerTable.insertcustomer(user);

  Future<int> insertProduct(ProductsTable product) =>
      ProductsTable.insertProduct(product);
  Future<int> insertCategory(CategoriesTable category) =>
      CategoriesTable.insertCategory(category);
  // check if the user already exists
  Future<bool> userExists(String phone) async {
    return await SupplierTable.supplierExists(phone);
  }

  Future<bool> customerExists(String phone) async {
    return await CustomerTable.customerExists(phone);
  }


  Future<bool> supplierExists(String phone) async {
    return await SupplierTable.supplierExists(phone);
  }

  //   Future<List<ProductsTable>> fetchProductsByShop(int shopId) async {
  //   final inventoryList = await LocalFindService().getInventoryByShopId(shopId);
  //   final productIds = inventoryList.map((e) => e.productId).toList();
  //   return await LocalFindService().getPr(productIds);
  // }
}
