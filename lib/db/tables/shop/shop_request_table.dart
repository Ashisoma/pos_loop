import 'package:sqflite/sqflite.dart';

class ShopRequestTable {
  static const String tableShopRequest = 'shop_request';

  final int id;
  final int shopId;
  final DateTime requestDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sync;

  ShopRequestTable({
    required this.id,
    required this.shopId,
    required this.requestDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.sync,
  });

  factory ShopRequestTable.fromSqfliteDataBase(Map<String, dynamic> map) {
    return ShopRequestTable(
      id: map['id']?.toInt() ?? 0,
      shopId: map['shop_id']?.toInt() ?? 0,
      requestDate: DateTime.parse(map['request_date'] ?? DateTime.now().toString()),
      status: map['status'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toString()),
      sync: map['sync']?.toInt() ?? 0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'request_date': requestDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync': sync,
    };
  }

  static Future<void> createShopRequestTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableShopRequest (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER NOT NULL,
        request_date TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> dropShopRequestTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableShopRequest');
  }

  static Future<List<ShopRequestTable>> getAllShopRequests(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tableShopRequest);
    return List.generate(maps.length, (i) {
      return ShopRequestTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<void> insertShopRequest(Database db, ShopRequestTable shopRequest) async {
    await db.insert(
      tableShopRequest,
      shopRequest.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateShopRequest(Database db, ShopRequestTable shopRequest) async {
    await db.update(
      tableShopRequest,
      shopRequest.toJson(),
      where: 'id = ?',
      whereArgs: [shopRequest.id],
    );
  }

  static Future<void> deleteShopRequest(Database db, int id) async {
    await db.delete(
      tableShopRequest,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<ShopRequestTable?> getShopRequestById(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopRequest,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ShopRequestTable.fromSqfliteDataBase(maps.first);
    }
    return null;
  }

  static Future<List<ShopRequestTable>> getShopRequestsByShopId(Database db, int shopId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopRequest,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return List.generate(maps.length, (i) {
      return ShopRequestTable.fromSqfliteDataBase(maps[i]);
    });
  }

  static Future<bool> checkIfShopRequestExists(Database db, int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableShopRequest,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  static Future<void> deleteAllShopRequests(Database db) async {
    await db.delete(
      tableShopRequest,
    );
  }

  static Future<void> updateShopRequestSyncStatus(Database db, int id, int sync) async {
    await db.update(
      tableShopRequest,
      {'sync': sync},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteShopRequestsByShopId(Database db, int shopId) async {
    await db.delete(
      tableShopRequest,
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
  }


  static Future<void> deleteShopRequestsByStatus(Database db, String status) async {
    await db.delete(
      tableShopRequest,
      where: 'status = ?',
      whereArgs: [status],
    );
  }

  static Future<void> deleteShopRequestsByDate(Database db, DateTime date) async {
    await db.delete(
      tableShopRequest,
      where: 'request_date = ?',
      whereArgs: [date.toIso8601String()],
    );
  }

  
}
