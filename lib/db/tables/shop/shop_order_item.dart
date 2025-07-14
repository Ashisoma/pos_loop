import 'package:sqflite/sqflite.dart';

class ShopOrderItemTable {
  static const String tableShopOrderItem = 'shop_order_item';

  final int id;
  final int shopOrderId;
  final int productId;
  final int quantity;
  final int sync;

  ShopOrderItemTable({
    required this.id,
    required this.shopOrderId,
    required this.productId,
    required this.quantity,
    required this.sync,
  });

  factory ShopOrderItemTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return ShopOrderItemTable(
      id: map['id']?.toInt() ?? 0,
      shopOrderId: map['shop_order_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      quantity: map['quantity']?.toInt() ?? 0,
      sync: map['sync']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_order_id': shopOrderId,
      'product_id': productId,
      'quantity': quantity,
      'sync': sync,
    };
  }

  static Future<void> createShopOrderItemTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableShopOrderItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        sync INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> dropShopOrderItemTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableShopOrderItem');
  }

  static Future<List<ShopOrderItemTable>> getAllShopOrderItems(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tableShopOrderItem);
    return List.generate(maps.length, (i) {
      return ShopOrderItemTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> insertShopOrderItem(Database db, ShopOrderItemTable shopOrderItem) async {
    await db.insert(
      tableShopOrderItem,
      shopOrderItem.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateShopOrderItem(Database db, ShopOrderItemTable shopOrderItem) async {
    await db.update(
      tableShopOrderItem,
      shopOrderItem.toJson(),
      where: 'id = ?',
      whereArgs: [shopOrderItem.id],
    );
  }

  static Future<void> deleteShopOrderItem(Database db, int id) async {
    await db.delete(
      tableShopOrderItem,
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  static Future<ShopOrderItemTable?> getShopOrderItemById(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopOrderItem,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ShopOrderItemTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  static Future<List<ShopOrderItemTable>> getShopOrderItemsByShopOrderId(Database db, int shopOrderId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopOrderItem,
      where: 'shop_order_id = ?',
      whereArgs: [shopOrderId],
    );
    return List.generate(maps.length, (i) {
      return ShopOrderItemTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<bool> checkIfShopOrderItemExists(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopOrderItem,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  static Future<void> deleteAllShopOrderItems(Database db) async {
    await db.delete(
      tableShopOrderItem,
    );
  }

  static Future<void> deleteShopOrderItemsByShopOrderId(Database db, int shopOrderId) async {
    await db.delete(
      tableShopOrderItem,
      where: 'shop_order_id = ?',
      whereArgs: [shopOrderId],
    );
  }

  static Future<void> deleteShopOrderItemsByProductId(Database db, int productId) async {
    await db.delete(
      tableShopOrderItem,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  
}
