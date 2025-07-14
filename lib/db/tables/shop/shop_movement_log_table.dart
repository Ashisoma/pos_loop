import 'package:sqflite/sqflite.dart';

class StockMovementLogTable {
  static const String tableStockMovementLog = 'stock_movement_log';

  final int id;
  final int shopId;
  final int productId;
  final int quantity;
  final String movemementType; //  PO_RECEIPT, TRANSFER_OUT, TRANSFER_IN, ORDER_FULFILL, ADJUSTMENT
  final int relatedId; // PO id, Transfer id, Order id
  final String relatedType;
  final String quantityType; // + or -
  final String status; // PENDING, COMPLETED
  final String sync; // 0 or 1
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;


  StockMovementLogTable({
    required this.id,
    required this.shopId,
    required this.productId,
    required this.quantity,
    required this.movemementType,
    required this.relatedId,
    required this.relatedType,
    required this.quantityType,
    required this.status,
    required this.sync,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockMovementLogTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return StockMovementLogTable(
      id: map['id']?.toInt() ?? 0,
      shopId: map['shop_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      quantity: map['quantity']?.toInt() ?? 0,
      movemementType: map['movemement_type'] ?? '',
      relatedId: map['related_id']?.toInt() ?? 0,
      relatedType: map['related_type'] ?? '',
      quantityType: map['quantity_type'] ?? '',
      status: map['status'] ?? '',
      sync: map['sync'] ?? '',
      createdBy: map['created_by']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toString()),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'product_id': productId,
      'quantity': quantity,
      'movemement_type': movemementType,
      'related_id': relatedId,
      'related_type': relatedType,
      'quantity_type': quantityType,
      'status': status,
      'sync': sync,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static Future<void> createStockMovementLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableStockMovementLog (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        movemement_type TEXT NOT NULL,
        related_id INTEGER NOT NULL,
        related_type TEXT NOT NULL,
        quantity_type TEXT NOT NULL,
        status TEXT NOT NULL,
        sync TEXT NOT NULL,
        created_by INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> dropStockMovementLogTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableStockMovementLog');
  }

  static Future<List<StockMovementLogTable>> getAllStockMovementLogs(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tableStockMovementLog);
    return List.generate(maps.length, (i) {
      return StockMovementLogTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<StockMovementLogTable>> getStockMovementLogsByShopId(Database db, int shopId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockMovementLog,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return List.generate(maps.length, (i) {
      return StockMovementLogTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<StockMovementLogTable>> getStockMovementLogsByProductId(Database db, int productId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockMovementLog,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return List.generate(maps.length, (i) {
      return StockMovementLogTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<List<StockMovementLogTable>> getStockMovementLogsByShopIdAndProductId(Database db, int shopId, int productId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockMovementLog,
      where: 'shop_id = ? AND product_id = ?',
      whereArgs: [shopId, productId],
    );
    return List.generate(maps.length, (i) {
      return StockMovementLogTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> insertStockMovementLog(Database db, StockMovementLogTable stockMovementLog) async {
    await db.insert(
      tableStockMovementLog,
      stockMovementLog.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateStockMovementLog(Database db, StockMovementLogTable stockMovementLog) async {
    await db.update(
      tableStockMovementLog,
      stockMovementLog.toJson(),
      where: 'id = ?',
      whereArgs: [stockMovementLog.id],
    );
  }

  static Future<void> deleteStockMovementLog(Database db, int id) async {
    await db.delete(
      tableStockMovementLog,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<StockMovementLogTable?> getStockMovementLogById(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockMovementLog,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return StockMovementLogTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  static Future<bool> checkIfStockMovementLogExists(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockMovementLog,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  static Future<void> deleteAllStockMovementLogs(Database db) async {
    await db.delete(
      tableStockMovementLog,
    );
  }

  static Future<void> deleteStockMovementLogsByShopId(Database db, int shopId) async {
    await db.delete(
      tableStockMovementLog,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
  }

  static Future<void> deleteStockMovementLogsByProductId(Database db, int productId) async {
    await db.delete(
      tableStockMovementLog,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  // get by shop id and product id
  static Future<void> deleteStockMovementLogsByShopIdAndProductId(Database db, int shopId, int productId) async {
    await db.delete(
      tableStockMovementLog,
      where: 'shop_id = ? AND product_id = ?',
      whereArgs: [shopId, productId],
    );
  }

  // get by created by id
  static Future<List<StockMovementLogTable>> getStockMovementLogsByCreatedById(Database db, int createdById) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableStockMovementLog,
      where: 'created_by = ?',
      whereArgs: [createdById],
    );
    return List.generate(maps.length, (i) {
      return StockMovementLogTable.fromSqfliteDataBase(maps[i]);
    });
  }
}
