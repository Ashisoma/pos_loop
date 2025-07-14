import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/db/controllers/local_find_service.dart';
import 'package:pos_desktop_loop/db/controllers/local_insert_service.dart';
import 'package:pos_desktop_loop/db/tables/categories_table.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/db/tables/stock/inventory_table.dart';
import 'package:pos_desktop_loop/models/inventory_model.dart';

class InventoryByShopProvider extends ChangeNotifier {
  List<InventoryItemModel> _inventoryItems = [];

  List<InventoryItemModel> get inventoryItems => _inventoryItems;

  List<ShopTable> _shops = [];
  List<CategoriesTable> _categories = [];

  List<ShopTable> get shops => _shops;
  List<CategoriesTable> get categories => _categories;
  bool isLoading = false;

  Future<void> fetchInventory(int shopId) async {
    List<InventoryTable> inventoryTables = await LocalFindService()
        .getInventoryByShopId(shopId);

    _inventoryItems = await Future.wait(
      inventoryTables.map((item) async {
        final product = await ProductsTable.getProductById(item.productId);
        final shop = await ShopTable.getShopById(item.shopId);

        return InventoryItemModel(
          inventoryId: item.id!,
          productName: product!.name,
          shopName: shop!.name,
          quantity: item.quantity,
        );
      }),
    );

    notifyListeners();
  }

  Future<void> fetchAllInventory() async {
    List<InventoryTable> inventoryTables =
        await InventoryTable.getAllInventory();

    _inventoryItems = await Future.wait(
      inventoryTables.map((item) async {
        final product = await ProductsTable.getProductById(item.productId);
        final shop = await ShopTable.getShopById(item.shopId);

        return InventoryItemModel(
          inventoryId: item.id!,
          productName: product!.name,
          shopName: shop!.name,
          quantity: item.quantity,
        );
      }),
    );

    notifyListeners();
  }

  Future<void> deleteInventoryItem(int inventoryId) async {
    await InventoryTable.deleteInventory(inventoryId);
    _inventoryItems.removeWhere((item) => item.inventoryId == inventoryId);
    notifyListeners();
  }

  Future<void> updateInventoryItem(InventoryTable updatedItem) async {
    var item = InventoryTable(
      id: updatedItem.id,
      productId: updatedItem.productId,
      shopId: updatedItem.shopId,
      quantity: updatedItem.quantity,
      sync: 0,
    );

    await InventoryTable.updateInventory(item);

    final index = _inventoryItems.indexWhere(
      (item) => item.inventoryId == updatedItem.id,
    );
    if (index != -1) {
      final product = await ProductsTable.getProductById(item.productId);
      final shop = await ShopTable.getShopById(item.shopId);

      var updatedItm = InventoryItemModel(
        inventoryId: item.id!,
        productName: product!.name,
        shopName: shop!.name,
        quantity: item.quantity,
      );

      _inventoryItems[index] = updatedItm;
      notifyListeners();
    }
  }

  // 🏪 Fetch all shops
  Future<void> fetchShops() async {
    _shops = await ShopTable.getAllShops();
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _categories = await CategoriesTable.getAllCategories();
    notifyListeners();
  }

  // ✏️ Update a shop
  Future<void> updateShop(ShopTable shop) async {
    await ShopTable.updateShop(shop);
    await fetchShops(); // refresh shop list
  }

  // ❌ Delete a shop
  Future<void> deleteShop(int shopId) async {
    await ShopTable.deleteShop(shopId);
    await fetchShops(); // refresh after deletion
  }

  // ❌ Delete a shop
  Future<ShopTable> getShopByName(String name) async {
    return await ShopTable.getShopByName(name);
  }

  // delete category
  Future<void> deleteCategory(int categoryId) async {
    await CategoriesTable.deleteCategory(categoryId);
    _categories.removeWhere((category) => category.id == categoryId);
    notifyListeners();
  }

  // insert a new category
  Future<int> addCategory(CategoriesTable category) async {
    // returns the category id if successful, 0 if it already exists 
    var cat = await LocalInsertService().addCategory(category);
    if (cat != 0) {
      _categories.add(category);
      notifyListeners();
    }
    return cat;
  }

  // get a category by name
  Future<CategoriesTable?> getCategoryByName(String name) async {
    return await CategoriesTable.getCategoryByName(name);
  }


   Future<List<InventoryItemModel>> getProductInventory(int productId) async {
    List<InventoryTable> inventoryTables = 
        await LocalFindService().getInventoryByProductId(productId);

    return await Future.wait(
      inventoryTables.map((item) async {
        final product = await ProductsTable.getProductById(item.productId);
        final shop = await ShopTable.getShopById(item.shopId);

        return InventoryItemModel(
          inventoryId: item.id!,
          productName: product!.name,
          shopName: shop!.name,
          quantity: item.quantity,
        );
      }),
    );
  }

  /// Transfer inventory between shops
  Future<void> transferInventory({
    required int productId,
    required int fromShopId,
    required int toShopId,
    required int quantity,
  }) async {
    if (quantity <= 0) throw Exception("Quantity must be positive");
    
    // Remove from source shop
    await adjustInventory(
      productId: productId,
      shopId: fromShopId,
      quantity: -quantity,
    );
    
    // Add to destination shop
    await adjustInventory(
      productId: productId,
      shopId: toShopId,
      quantity: quantity,
    );
    
    notifyListeners();
  }

  /// Adjust inventory (add or remove)
  Future<void> adjustInventory({
    required int productId,
    required int shopId,
    required int quantity, // can be negative to remove
  }) async {
    // Get current inventory
    var inventory = await LocalFindService().getInventoryItem(productId, shopId);
    
    if (inventory == null) {
      // Create new inventory record if it doesn't exist
      if (quantity > 0) {
        await LocalInsertService().insertInventory(InventoryTable(
          productId: productId,
          shopId: shopId,
          quantity: quantity,
          sync: 0,
        ));
      } else {
        throw Exception("Cannot have negative inventory for new item");
      }
    } else {
      // Update existing inventory
      int newQuantity = inventory.quantity + quantity;
      if (newQuantity < 0) {
        throw Exception("Insufficient inventory in shop");
      }
      
      await InventoryTable.updateInventory(InventoryTable(
        id: inventory.id,
        productId: productId,
        shopId: shopId,
        quantity: newQuantity,
        sync: 0,
      ));
    }
    
    // Refresh the inventory list
    await fetchInventory(shopId);
  }

}
