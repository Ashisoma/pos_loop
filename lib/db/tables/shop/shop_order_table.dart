import 'package:sqflite/sqflite.dart';

class ShopOrderTable {
  static const String tableName = 'shop_order';

  final int id;
  final int shopId;
  final DateTime orderDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopOrderTable({
    required this.id,
    required this.shopId,
    required this.orderDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopOrderTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return ShopOrderTable(
      id: map['id']?.toInt() ?? 0,
      shopId: map['shop_id']?.toInt() ?? 0,
      orderDate: DateTime.parse(map['order_date'] ?? DateTime.now().toString()),
      status: map['status'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static Future<void> createShopOrderTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER NOT NULL,
        order_date TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> dropShopOrderTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  static Future<List<ShopOrderTable>> getAllShopOrders(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return ShopOrderTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> insertShopOrder(Database db, ShopOrderTable shopOrder) async {
    await db.insert(
      tableName,
      shopOrder.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateShopOrder(Database db, ShopOrderTable shopOrder) async {
    await db.update(
      tableName,
      shopOrder.toJson(),
      where: 'id = ?',
      whereArgs: [shopOrder.id],
    );
  }


  static Future<void> deleteShopOrder(Database db, int id) async {
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<ShopOrderTable?> getShopOrderById(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ShopOrderTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  // check if the item exists
  static Future<bool> checkIfShopOrderExists(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  static Future<void> deleteAllShopOrders(Database db) async {
    await db.delete(
      tableName,
    );
  }

  
}
