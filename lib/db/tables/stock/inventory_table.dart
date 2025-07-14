import 'package:pos_desktop_loop/db/helpers/database_helper.dart';
import 'package:pos_desktop_loop/db/tables/product/products_table.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/models/inventory_model.dart';
import 'package:sqflite/sqflite.dart';

class InventoryTable {
  static const String tableInverntory = 'inventory';

  final int? id;
  final int productId;
  final int shopId;
  final int quantity;
  final String? description;
  final DateTime? lastRestocked;
  final int? sync;

  InventoryTable({
     this.id,
    required this.productId,
    required this.shopId,
    required this.quantity,
    this.description,
    this.lastRestocked,
     this.sync,
  });

  factory InventoryTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return InventoryTable(
      id: map['id'] ?? 0,
      productId: map['product_id'] != null ? map['product_id'] as int : 0,
      shopId: map['shop_id'] != null ? map['shop_id'] as int : 0,
      quantity: map['quantity'] != null ? map['quantity'] as int : 0,
      description: map['description']?.toString() ?? '',
      lastRestocked: map['lastRestocked'] != null
          ? DateTime.tryParse(map['lastRestocked'].toString())
          : null,
      sync: map['sync'] != null ? map['sync'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'shop_id': shopId,
      'quantity': quantity,
      'description': description,
      'lastRestocked': lastRestocked?.toIso8601String(),
      'sync': sync,
    };
  }

  static Future<void> createInventoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableInverntory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        shop_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        description TEXT,
        lastRestocked DATETIME,
        sync INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> dropInventoryTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableInverntory');
  }

  static Future<List<InventoryTable>> getAllInventory() async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.query(tableInverntory);
    return List.generate(maps.length, (i) {
      return InventoryTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<int> insertInventory(InventoryTable inventory) async {
    Database db = await DatabaseHelper().database;
    return await db.insert(
      tableInverntory,
      inventory.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateInventory(InventoryTable inventory) async {
    Database db = await DatabaseHelper().database;
    await db.update(
      tableInverntory,
      inventory.toJson(),
      where: 'id = ?',
      whereArgs: [inventory.id],
    );
  }

  static Future<void> deleteInventory(int id) async {
    Database db = await DatabaseHelper().database;

    await db.delete(tableInverntory, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteInventoryByProductId(int productId) async {
    Database db = await DatabaseHelper().database;
    await db.delete(
      tableInverntory,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  static Future<void> deleteInventoryByShopId(int shopId) async {
    Database db = await DatabaseHelper().database;
    await db.delete(tableInverntory, where: 'shop_id = ?', whereArgs: [shopId]);
  }

  static Future<void> deleteInventoryByProductIdAndShopId(
    int productId,
    int shopId,
  ) async {
    Database db = await DatabaseHelper().database;
    await db.delete(
      tableInverntory,
      where: 'product_id = ? AND shop_id = ?',
      whereArgs: [productId, shopId],
    );
  }

  // get all products in inventory by shop id returna a list of Products
  static Future<List<ProductsTable>> getProductByShopId(int shopId) async {
    final db = await DatabaseHelper().database;

    final maps = await db.query(
      tableInverntory,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );

    final inventoryList =
        maps.map((m) => InventoryTable.fromSqfliteDataBase(m)).toList();

    final productFutures = inventoryList.map(
      (inv) => ProductsTable.getProductById(inv.productId),
    );
    final productResults = await Future.wait(productFutures);

    return productResults.whereType<ProductsTable>().toList();
  }

  static Future<List<ProductsTable>> getProductsByShopId(int shopId) async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT p.*
    FROM $tableInverntory i
    JOIN products p ON i.product_id = p.id
    WHERE i.shop_id = ?
  ''',
      [shopId],
    );

    return result.map((map) => ProductsTable.fromSqfliteDataBase(map)).toList();
  }

  // get all products in inventory by shop id returna a list of Products
  static Future<List<ProductsTable>> getProductByShopIdForAdmin() async {
    final db = await DatabaseHelper().database;

    final maps = await db.query(tableInverntory);

    final inventoryList =
        maps.map((m) => InventoryTable.fromSqfliteDataBase(m)).toList();

    final productFutures = inventoryList.map(
      (inv) => ProductsTable.getProductById(inv.productId),
    );
    final productResults = await Future.wait(productFutures);

    return productResults.whereType<ProductsTable>().toList();
  }

  static Future<List<InventoryTable>> getInventoryByShopId(int shopId) async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> result = await db.query(
      tableInverntory, // table name
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );

    return result.map((e) => InventoryTable.fromSqfliteDataBase(e)).toList();
  }

  Future<List<InventoryItemModel>> getAllInventoryWithDetails() async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> inventoryList = await db.query(
      tableInverntory,
    ); // or your inventory table name

    List<InventoryItemModel> detailedList = [];

    for (var item in inventoryList) {
      final product = await ProductsTable.getProductById(item['productId']);
      final shop = await ShopTable.getShopById(item['shopId']);

      detailedList.add(
        InventoryItemModel(
          inventoryId: item['id'],
          productName: product!.name,
          shopName: shop!.name,
          quantity: item['quantity'],
        ),
      );
    }

    return detailedList;
  }

  static Future<InventoryTable?> getInventoryItem(int productId, int shopId) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableInverntory,
      where: 'product_id = ? AND shop_id = ?',
      whereArgs: [productId, shopId],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return InventoryTable.fromSqfliteDataBase(result.first);
    }
    return null;
  }

  static Future<List<InventoryTable>> getInventoryByProductId(int productId) async {
    
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      tableInverntory,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    
    return result.map((e) => InventoryTable.fromSqfliteDataBase(e)).toList();
  }
}
