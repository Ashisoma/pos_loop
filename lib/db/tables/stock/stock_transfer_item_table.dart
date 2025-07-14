import 'package:sqflite/sqflite.dart';

class StockTransferItemTable {

  static const String tableName = 'stock_transfer_item';

  static const String id = 'id';
  final String stockTransferId;
  final String productId ;
  final String quantity;
  final String transferId;
  final String updatedAt;
  final String createdAt;

  StockTransferItemTable({
    required this.stockTransferId,
    required this.productId,
    required this.quantity,
    required this.transferId,
    required this.updatedAt,
    required this.createdAt,
  });

  factory StockTransferItemTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return StockTransferItemTable(
      stockTransferId: map['stock_transfer_id']?.toString() ?? '',
      productId: map['product_id']?.toString() ?? '',
      quantity: map['quantity']?.toString() ?? '',
      transferId: map['transfer_id']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stock_transfer_id': stockTransferId,
      'product_id': productId,
      'quantity': quantity,
      'transfer_id': transferId,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }

  static Future<void> createStockTransferItemTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stock_transfer_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity TEXT NOT NULL,
        transfer_id TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> dropStockTransferItemTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  static Future<List<StockTransferItemTable>> getAllStockTransferItems(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return StockTransferItemTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> insertStockTransferItem(Database db, StockTransferItemTable stockTransferItem) async {
    await db.insert(
      tableName,
      stockTransferItem.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateStockTransferItem(Database db, StockTransferItemTable stockTransferItem) async {
    await db.update(
      tableName,
      stockTransferItem.toJson(),
      where: '$id = ?',
      whereArgs: [stockTransferItem.stockTransferId],
    );
  }

  static Future<void> deleteStockTransferItem(Database db, String id) async {
    await db.delete(
      tableName,
      where: '$id = ?',
      whereArgs: [id],
    );
  }

  static Future<StockTransferItemTable?> getStockTransferItemById(Database db, String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return StockTransferItemTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  static Future<void> deleteAllStockTransferItems(Database db) async {
    await db.delete(
      tableName,
    );
  }

  static Future<List<StockTransferItemTable>> getStockTransferItemsByTransferId(Database db, String transferId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'transfer_id = ?',
      whereArgs: [transferId],
    );
    return List.generate(maps.length, (i) {
      return StockTransferItemTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> deleteStockTransferItemsByTransferId(Database db, String transferId) async {
    await db.delete(
      tableName,
      where: 'transfer_id = ?',
      whereArgs: [transferId],
    );
  }

  static Future<void> deleteStockTransferItemsByStockTransferId(Database db, String stockTransferId) async {
    await db.delete(
      tableName,
      where: 'stock_transfer_id = ?',
      whereArgs: [stockTransferId],
    );
  }

  static Future<void> deleteStockTransferItemsByProductId(Database db, String productId) async {
    await db.delete(
      tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  static Future<void> deleteStockTransferItemsByProductIdAndTransferId(Database db, String productId, String transferId) async {
    await db.delete(
      tableName,
      where: 'product_id = ? AND transfer_id = ?',
      whereArgs: [productId, transferId],
    );
  }
}