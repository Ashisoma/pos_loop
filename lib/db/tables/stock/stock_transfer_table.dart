import 'package:sqflite/sqflite.dart';

class StockTransfer {
  static const String tableStockTranser = 'stock_transfer';

  final int id;
  final int fromShopId;
  final int toShopId;
  final DateTime transferDate;
  final String status;
  final int sync;
  final int quantityTotal;
  final int createdBy;
  final int updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int cancelledBy;
  final DateTime cancelledAt;
  final String cancelledReason;

  StockTransfer({
    required this.id,
    required this.fromShopId,
    required this.toShopId,
    required this.transferDate,
    required this.status,
    required this.quantityTotal,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.cancelledBy,
    required this.cancelledAt,
    required this.cancelledReason,
    required this.sync,
  });

  factory StockTransfer.fromSqfliteDataBase(Map<String, dynamic> map) {
    return StockTransfer(
      id: map['id']?.toInt() ?? 0,
      fromShopId: map['from_shop_id']?.toInt() ?? 0,
      toShopId: map['to_shop_id']?.toInt() ?? 0,
      transferDate: DateTime.parse(map['transfer_date'] ?? DateTime.now().toString()),
      status: map['status'] ?? '',
      quantityTotal: map['quantity_total']?.toInt() ?? 0,
      createdBy: map['created_by']?.toInt() ?? 0,
      updatedBy: map['updated_by']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toString()),
      cancelledBy: map['cancelled_by']?.toInt() ?? 0,
      cancelledAt: DateTime.parse(map['cancelled_at'] ?? DateTime.now().toString()),
      cancelledReason: map['cancelled_reason'] ?? '',
      sync: map['sync']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_shop_id': fromShopId,
      'to_shop_id': toShopId,
      'transfer_date': transferDate.toIso8601String(),
      'status': status,
      'quantity_total': quantityTotal,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancelled_at': cancelledAt.toIso8601String(),
      'cancelled_reason': cancelledReason,
      'sync': sync,
    };
  }

  static Future<void> createStockTransferTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableStockTranser (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_shop_id INTEGER NOT NULL,
        to_shop_id INTEGER NOT NULL,
        transfer_date TEXT NOT NULL,
        status TEXT NOT NULL,
        quantity_total INTEGER NOT NULL,
        created_by INTEGER NOT NULL,
        updated_by INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        cancelled_by INTEGER NOT NULL,
        cancelled_at TEXT NOT NULL,
        cancelled_reason TEXT NOT NULL,
        sync INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> dropStockTransferTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableStockTranser');
  }

  static Future<List<StockTransfer>> getAllStockTransfers(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tableStockTranser);
    return List.generate(maps.length, (i) {
      return StockTransfer.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> insertStockTransfer(Database db, StockTransfer stockTransfer) async {
    await db.insert(
      tableStockTranser,
      stockTransfer.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateStockTransfer(Database db, StockTransfer stockTransfer) async {
    await db.update(
      tableStockTranser,
      stockTransfer.toJson(),
      where: 'id = ?',
      whereArgs: [stockTransfer.id],
    );
  }

  static Future<void> deleteStockTransfer(Database db, int id) async {
    await db.delete(
      tableStockTranser,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAllStockTransfers(Database db) async {
    await db.delete(
      tableStockTranser,
    );
  }

  static Future<void> deleteStockTransferByFromShopId(Database db, int fromShopId) async {
    await db.delete(
      tableStockTranser,
      where: 'from_shop_id = ?',
      whereArgs: [fromShopId],
    );
  }

  static Future<void> deleteStockTransferByToShopId(Database db, int toShopId) async {
    await db.delete(
      tableStockTranser,
      where: 'to_shop_id = ?',
      whereArgs: [toShopId],
    );
  }

  static Future<void> deleteStockTransferByFromShopIdAndToShopId(Database db, int fromShopId, int toShopId) async {
    await db.delete(
      tableStockTranser,
      where: 'from_shop_id = ? AND to_shop_id = ?',
      whereArgs: [fromShopId, toShopId],
    );
  }

  static Future<void> deleteStockTransferById(Database db, int id) async {
    await db.delete(
      tableStockTranser,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteStockTransferByStatus(Database db, String status) async {
    await db.delete(
      tableStockTranser,
      where: 'status = ?',
      whereArgs: [status],
    );
  }

  static Future<void> deleteStockTransferByStatusAndFromShopId(Database db, String status, int fromShopId) async {
    await db.delete(
      tableStockTranser,
      where: 'status = ? AND from_shop_id = ?',
      whereArgs: [status, fromShopId],
    );
  }

  static Future<void> deleteStockTransferByStatusAndToShopId(Database db, String status, int toShopId) async {
    await db.delete(
      tableStockTranser,
      where: 'status = ? AND to_shop_id = ?',
      whereArgs: [status, toShopId],
    );
  }

  static Future<void> deleteStockTransferByStatusAndFromShopIdAndToShopId(Database db, String status, int fromShopId, int toShopId) async {
    await db.delete(
      tableStockTranser,
      where: 'status = ? AND from_shop_id = ? AND to_shop_id = ?',
      whereArgs: [status, fromShopId, toShopId],
    );
  }
}
